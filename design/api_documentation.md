# Documentación de la API — H2O Chimal

Este documento describe los endpoints, estructuras de datos requeridas, validaciones, flujos de trabajo y medidas de seguridad de la API REST implementada en `backend/`.

## Resumen técnico
- Backend: Django REST Framework
- Base de datos: PostgreSQL
- Storage de archivos: S3 compatible (Ceph / MinIO) mediante `django-storages` + `boto3`
- Autenticación principal: Token en cookie HTTPOnly (`auth_token`) usando `rest_framework.authtoken`. También hay endpoints JWT (`simplejwt`) disponibles.
- Despliegue: Docker + docker-compose + NGINX (proxy)

## Variables de entorno relevantes
- `SECRET_KEY`, `DEBUG`, `ALLOWED_HOSTS`
- Postgres: `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`
- Ceph/S3: `CEPH_ENDPOINT`, `CEPH_ACCESS_KEY`, `CEPH_SECRET_KEY`, `CEPH_BUCKET`, `CEPH_REGION`

## Autenticación y seguridad

- El flujo principal devuelve un token de tipo `Token` (DRF authtoken) y lo almacena como cookie HTTPOnly llamada `auth_token` con `samesite='Lax'` y `max_age=30 días`.
- `api.auth.CookieTokenAuthentication` lee la cookie `auth_token` y, en ausencia de cookie, cae en la cabecera `Authorization: Token <key>`.
- Recomendaciones de producción:
  - Servir siempre sobre HTTPS y usar `secure=True` al setear la cookie.
  - Limitar intentos de login (rate limit) y bloqueo temporal tras múltiples fallos.
  - Poner `DEBUG=False` y activar logging de errores y auditoría.

## Validaciones globales
- `email`: formato de correo válido.
- `password`: mínimo 8 caracteres.
- `curp`: patrón regex: `^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$` (se valida en el register).
- `phone`: solo dígitos, 10 caracteres.
- `postal_code`: solo dígitos, 5 caracteres.
- Archivos: validar `Content-Type` (MIME) y tamaño máximo en el frontend o en middleware; actualmente la API guarda archivos en el storage configurado y registra `storage_key`.

## Estructuras principales (resumen)
- `User` (modelo personalizado `api.User`)
  - id (UUID), email, curp, name, phone, postal_code, colonia, street, block, exterior_number, role (`citizen|operator|admin`)
- `Service` (tramites/servicios)
  - id (UUID), name, description, response_time
- `DocumentType` — tipos de documentos requeridos
- `ServiceRequirement` — rel. service ↔ document_type (required, notes)
- `Document` — objetos subidos
  - id (UUID), user, service, document_type, storage_key, filename, mime_type, size, metadata, uploaded_at
- `Report` — reporte de fugas
  - id (UUID), user, folio (se autogenera incremental), location (lat/long), report_type, description, status, assigned_operator_id
- `Tramite` — solicitud de servicio (folio, status, service, user)
- `AuditLog` — registros de acciones críticas (user, action, target, metadata)

## Endpoints principales

Base: `/api/`

### Auth

- `POST /api/auth/register/` — Registrar usuario
  - Body (JSON): `email`, `password`, `curp`, `name`, `phone`, `postal_code`, `colonia`, `street`, `block`, `exterior_number`
  - Validaciones: `password` >=8, `curp` regex, `phone` 10 dígitos, `postal_code` 5 dígitos.
  - Respuesta: `201` + `{ id, email }` y cookie `auth_token` HTTPOnly.

- `POST /api/auth/login/` — Login (cookie)
  - Body: `email`, `password`
  - Respuesta: `200` + `{ user: { ... } }` y cookie `auth_token` HTTPOnly.

- `POST /api/auth/logout/` — Logout
  - Requiere autenticación por cookie o token en header.
  - Borra el token del servidor y elimina la cookie `auth_token`.

- JWT endpoints (opcional): `/api/auth/token/`, `/api/auth/token/refresh/` (simplejwt).

### Services

- `GET /api/services/` — Lista de servicios
  - Respuesta: array de servicios (id, name, description, response_time).

- `GET /api/services/{id}/` — Detalle de servicio
  - Respuesta incluye `requirements`: lista de documentos necesarios (document_type_id, document_type_name, required, notes).

### Reports (fugas)

- `GET /api/reports/` — Listar reportes
  - Autenticación requerida.
  - Citizens ven solo sus reportes; operators ven los asignados; admins ven todos.

- `POST /api/reports/` — Crear reporte
  - Body: `user` (id) opcional si autenticado, `latitude`, `longitude`, `location_text`, `report_type` (superficial|tuberia|domiciliaria|obstruido), `description`.
  - Respuesta: `201` con datos del reporte y `folio` generado.
  - Validación: se verifica la existencia de fugas duplicadas mediante negocio (se puede agregar lógica espacial: radio 10m).

- `GET /api/reports/{id}/`, `PATCH/PUT`, `DELETE` — CRUD estándar (permisos controlados).

- `POST /api/reports/{id}/assign/` — Asignar operador (permite `operator`/`admin`)
  - Body: `{ "operator_id": "<uuid>" }` → marca `status = 'En atención'` y escribe en `AuditLog`.

- `POST /api/reports/{id}/change_status/` — Cambiar estado (operator/admin)
  - Body: `{ "status": "En revisión", "note": "..." }` → guarda y crea `AuditLog`.

### Documents

- `GET /api/documents/` — Lista documentos del usuario (auth required)
- `POST /api/documents/` — Subir documento / registrar metadata
  - Acepta `multipart/form-data` con campo `file` o un `storage_key` si el archivo ya fue subido.
  - Si se sube `file`, el backend guarda en storage (Ceph) y registra `storage_key`, `filename`, `mime_type`, `size`.
  - Body mínimo: `document_type` (id), opcional: `service`, `user`.
  - Respuesta: `201` con metadata y `presigned_url` (si el storage lo soporta).

- `GET /api/documents/{id}/` — metadata + `presigned_url` para descarga temporal.
- `DELETE /api/documents/{id}/` — Borra metadata y elimina objeto en storage (si permisos permiten).

### Tramites

- `GET /api/tramites/` — listar trámites (auth)
- `POST /api/tramites/` — crear trámite para un servicio
  - Body: `service` (id), `user` (id) (o implícito por autenticación), y `documents` / `storage_keys` según requisitos.

## Ejemplos de uso (curl)

- Registro (ejemplo):

```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"juan@example.com","password":"secreto123","curp":"GODE561231HDFLRN09","name":"Juan","phone":"5512345678","postal_code":"12345","colonia":"Centro","street":"Av. Principal","block":"1","exterior_number":"10"}' \
  -i
```

- Subir documento (multipart):

```bash
curl -X POST http://localhost:8000/api/documents/ \
  -F "file=@/path/to/contrato.pdf" \
  -F "document_type=<document_type_id>" \
  -b "auth_token=<token_cookie_value>"
```

## Flujo de trabajo típico

1. Usuario se registra (`/auth/register/`) y recibe cookie `auth_token`.
2. Usuario crea reporte (`/reports/`), obtiene `folio` y espera asignación.
3. Admin asigna reporte a operador (`/reports/{id}/assign/`) o se asigna automáticamente.
4. Operador actualiza estado y sube evidencia (`/reports/{id}/change_status/` + `/documents/` o `/media/`).
5. Al resolverse, se solicita evaluación al ciudadano y se registra en `Tramite` si procede.

## Auditoría y registros
- Cada asignación y cambio de estado queda registrado en `AuditLog` con `user`, `action`, `target_type`, `target_id` y `metadata`.
- Se recomienda mantener logs de acceso y auditoría centralizados (ELK / Cloud watch) en producción.

## Manejo de archivos y Ceph
- Archivos se guardan en S3 compatible. Configurar bucket en `CEPH_BUCKET`.
- La API puede generar `presigned_url` para descargas temporales (1 hora por defecto).
- Para subidas masivas o performance, implementar presigned PUT URLs y que la app Flutter suba directamente a Ceph.

## Migraciones y arranque
- Crear migraciones y aplicar:

```bash
python manage.py makemigrations api
python manage.py migrate
```

- Para desarrollo con Docker:

```bash
docker-compose up --build
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

## Consideraciones de seguridad y producción
- Usar HTTPS y cookies seguras (`secure=True`).
- Habilitar CORS de forma restrictiva para dominios de la app móvil.
- Establecer límites de tamaño y tipos MIME aceptables en el backend y/o en el storage gateway.
- Hacer backups regulares de PostgreSQL y versionado de los documentos críticos.

## Extensiones y próximos pasos recomendados
- Implementar rate limiting en endpoints de `auth` y `register`.
- Añadir validación espacial para evitar reportes duplicados (10m radius).
- Añadir endpoints para generación de presigned PUT URLs.
- Implementar tests automatizados (unit + integration) para endpoints críticos.

---
Documentación generada automáticamente como apoyo al desarrollo — ajusta ejemplos y tiempos de expiración según políticas locales.
