# H2O Chimal
# H20 Chimal - Especificaciones de la Aplicación

## Descripción
Aplicación móvil para el reporte de fugas de agua y gestión de servicios hídricos en el municipio.

## Stakeholders
- **Ciudadanos:** Usuarios finales que reportan fugas y solicitan servicios.
- **Operadores:** Personal de campo que resuelve las incidencias.
- **Administradores:** Gestionan reportes, operadores y analizan indicadores.

## Módulos Principales
1. **Registro y Autenticación:** Registro con CURP, validación de formato, recuperación de contraseña y edición de perfil.
2. **Reporte de Fugas:** Captura de ubicación (GPS/Mapa), foto, clasificación y descripción. Generación de folio único.
3. **Seguimiento:** Estados del reporte (Recibido, Revisión, Atención, Resuelto, Cerrado), notificaciones push e historial.
4. **Gestión Interna:** Asignación de reportes, actualización de estados por operadores y bitácora de cambios.
5. **Solicitudes de Servicios:** Conexiones, pipas de agua y catálogo de servicios.
6. **Mapa e Indicadores:** Visualización interactiva de reportes y dashboard administrativo con KPIs.
7. **Evaluación:** Calificación de servicio y comentarios.

## Requerimientos Visuales (RNF)
- Colores institucionales del municipio.
- Iconografía universal e intuitiva.
- Paleta de colores semántica para estados (ej. Rojo=Pendiente, Verde=Resuelto).
- Diseño consistente en Android e iOS.

## Requisitos para tramites:
Contrato de agua potable:
- Contrato de compra venta (Documentación que acredite la propiedad)
- Traslado de dominio /boleta predial,
- Croquis de ubicación
- Identificación personal
A recibir: Contrato de agua 13 mm.

Contrato de Drenaje:
- Contrato de compraventa (Documentación que acredite la propiedad)
- Traslado de dominio /boleta predial
- Croquis de ubicación
- Identificación personal
A recibir: Contrato de drenaje con vigencia permanente.

Suministro de agua potable en unidad cisterna:
- Recibo anual de pago de agua
- Ubicación
- Nombre
- Teléfono
A recibir: Reporte firmado por el usuario solicitante, al concluir el servicio

# Tecnologias
- backend - Django REST framework
- base de datos - PostgreSQL
- Proxy - NGINX
- Despliegue - Docker/Docker compose
- APP - Dart/Flutter
- Admin dashboard - ?

## Base de Datos
Entidades principales:
- `users`: usuarios registrados (ciudadanos).
- `reports`: reportes de fugas (folio, ubicación, estado, descripción).
- `documents`: documentos subidos por usuarios (contratos, identificaciones, recibos).
- `services`: catálogo de trámites/servicios (contrato agua, drenaje, cisterna, etc.).
- `document_types`: tipos de documento (identificación, boleta predial, recibo pago, croquis).
- `service_requirements`: qué `document_types` requiere cada `service`.
- `media`: evidencias fotográficas asociadas a `reports`.

users
- id UUID PRIMARY KEY
- email VARCHAR UNIQUE NOT NULL
- curp VARCHAR UNIQUE
- name VARCHAR
- phone VARCHAR
- password_hash VARCHAR
- postal_code VARCHAR
- colonia VARCHAR
- street VARCHAR
- block VARCHAR
- exterior_number VARCHAR
- created_at TIMESTAMP DEFAULT now()
- updated_at TIMESTAMP

document_types
- id SERIAL PRIMARY KEY
- code VARCHAR UNIQUE (ej. contract_sale, id_official, recibo_pago)
- name VARCHAR
- description TEXT

services
- id SERIAL PRIMARY KEY
- code VARCHAR UNIQUE (ej. contrato_agua, contrato_drenaje, cisterna)
- name VARCHAR
- description TEXT
- response_time VARCHAR

service_requirements
- id SERIAL PRIMARY KEY
- service_id INT REFERENCES services(id) ON DELETE CASCADE
- document_type_id INT REFERENCES document_types(id) ON DELETE CASCADE
- required BOOLEAN DEFAULT true
- notes TEXT

documents
- id UUID PRIMARY KEY
- tramite_id UUID REFERENCES tramites
- document_type_id INT REFERENCES document_types(id)
- storage_key VARCHAR NOT NULL -- ruta
- filename VARCHAR
- mime_type VARCHAR
- size BIGINT
- uploaded_at TIMESTAMP DEFAULT now()

media (para fotos de reportes)
- id UUID PRIMARY KEY
- report_id UUID REFERENCES reports(id) ON DELETE CASCADE
- storage_key VARCHAR
- filename VARCHAR
- mime_type VARCHAR
- uploaded_at TIMESTAMP

reports (fugas)
- id UUID PRIMARY KEY
- user_id UUID REFERENCES users(id)
- folio VARCHAR UNIQUE
- reported_at TIMESTAMP DEFAULT now()
- latitude NUMERIC, longitude NUMERIC -- o geometry con PostGIS
- location_text VARCHAR
- report_type VARCHAR CHECK(report_type IN ('superficial','tuberia','domiciliaria','obstruido'))
- description TEXT
- status VARCHAR CHECK(status IN ('Recibido','En revisión','En atención','Resuelto','Cerrado'))
- assigned_operator_id UUID NULL
- estimated_time_interval TEXT
- created_at TIMESTAMP

tramites
- id UUID PRIMARY KEY
- user_id UUID REFERENCES users(id)
- service_id INT REFERENCES services(id)
- folio VARCHAR UNIQUE
- created_at TIMESTAMP DEFAULT now()
- status VARCHAR CHECK(status IN ('Creado','En tramite','Completado'))
- notes TEXT


Índices y constraints recomendados:
- `UNIQUE` en `users.email`, `users.curp`, `reports.folio`.
- Índices en `tramites.user_id`, `tramites.service_id`, `reports.status`, `reports.reported_at`.
- Si usa `PostGIS`, almacenar geometría y crear índice espacial: `CREATE INDEX ON reports USING GIST(geom);`.
- FK con `ON DELETE` pensados para conservar historial (ej. `documents.user_id` ON DELETE SET NULL).

Almacenamiento y seguridad de archivos:
- Guardar archivos en Storage y la `storage_key` en `documents`/`media`.
- Validar MIME, tamaño máximo, escaneo de malware en uploads.
- Control de acceso: URLs firmadas (pre-signed) para descargas temporales.
- Auditoría: tabla de logs para operaciones críticas (subida, eliminación, descargas).

Endpoint de login y registro:
Al hacer inicio de sesion se deben validar las credenciales y regresar un mensaje de exito, junto con un jwtoken en las cookies http0nly con las que se auntenticaran las operaciones del usuario. El token solo debe ser valido durante 1 mes como máximo, este endpoint debe estar limitado a 5 peticiones fallidas por usuario diarias.
Debe existir un endpiont de logout que resete el jwtoken, tanto en el sistema como en las cookies http0nly de la sesión.
Al registrar un nuevo usuario, se debe validar que:
- email sea valido
- curp tenga el formato correcto de 18 caracteres alfanumericos
- name concida con el curp
- phone sea un numero valido de 10 digitos
- postal_code tenga el formato valido (5 numeros)
- colonia no sea un string vacio
- street no sea un string vacio
- block no sea un string vacio
- exterior_number no este vacio

Flujos de uso:
- Al iniciar sesion, validar credenciales, retornar http0nly con jwtoken
- Al solicitar recuperar la contraseña, validar que exista el correo en el registro, enviar correo para reeestablecer contraseña.
- Al mostrar un servicio, leer `service_requirements` para saber qué documentos pedir.
- Al subir un documento, crear entrada en `documents` con `service_id` y `document_type_id`.
- Para un reporte, generar `folio`, guardar `reports` y asociar `media` para fotos.

Notas operativas:
- Usar `UUID` para evitar colisiones y facilitar sincronización móvil.
- Los IDS de tramites y reportes deberan estar en formato de 10 caracteres alfanumericos unicos
- Los tipos de documentos aceptados hasta ahora son:
    - Contrato de compra venta (Documentación que acredite la propiedad)
    - Traslado de dominio /boleta predial,
    - Croquis de ubicación
    - Identificación personal
    - Recibo anual de pago de agua

## API / Backend

Se ha creado un scaffold inicial del backend basado en Django REST Framework, con PostgreSQL como base de datos, NGINX como proxy reverso y despliegue por Docker (ver `docker-compose.yml`).

Rutas principales de la API (base `/api/`):

- `POST /api/auth/register/` : Registrar usuario. Campos: `email`, `password`, `curp`, `name`, `phone`.
- `POST /api/auth/token/` : Obtener token JWT. Campos: `email`, `password`. Responde `access` y `refresh`.
- `POST /api/auth/token/refresh/` : Refrescar token JWT.

- `GET /api/services/` : Listar servicios (contrato agua, drenaje, cisterna, etc.).

- `GET /api/reports/` : Listar reportes (autenticación requerida).
- `POST /api/reports/` : Crear nuevo reporte. Campos: `folio`, `user` (id), `latitude`, `longitude`, `location_text`, `report_type`, `description`.

- `GET /api/documents/` : Listar documentos subidos (autenticación requerida).
- `POST /api/documents/` : Registrar metadata de un documento subido (se espera que el archivo se suba a Storage y la `storage_key` se registre aquí). Campos: `user`, `service`, `document_type`, `storage_key`, `filename`.

- `GET /api/tramites/` : Listar trámites del usuario (autenticación requerida).
- `POST /api/tramites/` : Crear tramite para un `service`.

Notas de implementación:
- Autenticación: JWT (`djangorestframework-simplejwt`) con `ACCESS_TOKEN_LIFETIME=30 días`.
- Modelo de usuario personalizado `api.User` con `UUID` como `id` y campos: `email`, `curp`, `name`, `phone`, dirección mínima.
- Archivos: los binarios no se guardan en la BD; use un storage (S3/Blob). La API guarda `storage_key` y metadata.
- Para producción: ajustar `SECRET_KEY`, `DEBUG=False`, `ALLOWED_HOSTS` y usar HTTPS; habilitar CORS si la app móvil lo requiere.

Ficheros creados importantes:
- `docker-compose.yml` — orquesta `db`, `web`, `nginx`.
- `backend/Dockerfile`, `backend/requirements.txt`, `backend/.env` — configuración del servicio web.
- `backend/h2o/` — proyecto Django.
- `backend/api/` — app con modelos, serializers, views y rutas.

Siguientes pasos recomendados:
- Ejecutar `docker-compose up --build` y luego aplicar migraciones: `docker-compose exec web python manage.py migrate`.
- Implementar subida directa a S3 o presigned URLs para manejar archivos desde la app Flutter.
- Añadir validaciones y límites (size, MIME) en el endpoint de subida.

### Integración con Ceph (S3 compatible)

El backend está configurado para usar un storage S3-compatible (Ceph) mediante `django-storages` y `boto3`.
Variables de entorno relevantes (ver `backend/.env`):

- `CEPH_ENDPOINT`: URL del gateway S3 de Ceph (ej. `http://ceph:9000`).
- `CEPH_ACCESS_KEY`, `CEPH_SECRET_KEY`: credenciales.
- `CEPH_BUCKET`: bucket donde se guardarán archivos.

Comportamiento implementado en la API:

- `POST /api/documents/` : acepta multipart form con campo `file` y metadatos (`service`, `document_type`, `user`), guarda el archivo en Ceph y crea la entrada en `documents` con `storage_key`.
- `GET /api/documents/` : lista documentos; cada objeto incluye `presigned_url` (válido 1 hora) para descargar el archivo desde Ceph.
- `GET /api/documents/{id}/` : devuelve metadata y `presigned_url`.
- `DELETE /api/documents/{id}/` : elimina metadata en la BD y borra el objeto en Ceph.

Detalles técnicos:

- Se usa `DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'` y las variables `AWS_*` apuntan al gateway de Ceph.
- Para descargas, la API genera `presigned_url` (método `generate_presigned_url`) en tiempo real para evitar exponer archivos públicamente.
- Al subir desde la app Flutter se puede:
    - Subir directamente a la API usando `multipart/form-data` (`POST /api/documents/` con `file`).
    - (Opcional) implementar presigned PUT URLs en el backend y que la app suba directamente a Ceph.

### Autenticación por cookie HTTPOnly

Se añadió soporte para autenticación con token en cookie HTTPOnly (`auth_token`) usando el modelo de `Token` de DRF (`rest_framework.authtoken`).

Endpoints y comportamiento:

- `POST /api/auth/login/` : recibir `email` y `password`, valida credenciales y coloca `auth_token` como cookie HTTPOnly (samesite=Lax, max_age=30 días). Responde con datos del usuario.
- `POST /api/auth/logout/` : elimina el token del servidor y borra la cookie `auth_token`.
- `GET /api/auth/user/` : devuelve la información del usuario autenticado (requiere la cookie HTTPOnly con token).

Autenticación automática en vistas:

- Se agregó `api.auth.CookieTokenAuthentication` que primero busca el token en la cookie `auth_token` y, si no existe, cae en la cabecera `Authorization`.

Recomendaciones de seguridad:

- En producción usar `secure=True` en `set_cookie` y servir sobre HTTPS.
- Limitar intentos de login por IP/usuario (rate limit) y habilitar bloqueo temporal tras múltiples fallos.

## Operadores y Administradores (control de acceso)

Se añadió soporte completo para roles y permisos de gestión interna:

- Campo `role` en `api.User`: `citizen`, `operator`, `admin`.
- Grupos automáticos: `Operator` y `Administrator` creados tras aplicar migraciones (seed en `post_migrate`).
- Permisos:
  - Operadores: pueden ver y cambiar reportes asignados, ver trámites y documentos relacionados.
  - Administradores: reciben todos los permisos del app `api` y pueden gestionar operadores, asignaciones y reportes.

Endpoints y acciones nuevas:

- `POST /api/reports/{id}/assign/` : Asignar un `operator_id` a un reporte (permiso `Operator` o `Administrator`).
  - Body: `{ "operator_id": "<uuid>" }`.
- `POST /api/reports/{id}/change_status/` : Cambiar el estado del reporte (nota opcional). Disponible para operadores y administradores.
  - Body: `{ "status": "En atención", "note": "Trabajo en proceso" }`.
- `GET /api/reports/?assigned_to_me=true` : Para operadores ver sus asignaciones.

Auditoría:
- Todas las asignaciones y cambios de estado quedan registrados en `AuditLog` con `user`, `action`, `target_type`, `target_id` y `metadata`.

Control de la UI y permisos:
- El frontend debe ocultar acciones de asignación y cambio de estado para usuarios sin el rol `operator` o `admin`.
- El endpoint de registro público no permite establecer `role`; solo administradores pueden elevar roles (desde admin o endpoints protegidos).

Operaciones recomendadas tras desplegar:
- Ejecutar migraciones: `docker-compose exec web python manage.py makemigrations && docker-compose exec web python manage.py migrate`.
- Crear un usuario administrador con `docker-compose exec web python manage.py createsuperuser` y usar el admin para añadir operadores al grupo `Operator`.


## Despliegue local y pruebas

1. Crear bucket en Ceph/access (o usar un S3 compatible como MinIO para pruebas locales).
2. Configurar credenciales en `backend/.env`.
3. Levantar servicios: `docker-compose up --build`.
4. Ejecutar migraciones: `docker-compose exec web python manage.py migrate`.
5. (Opcional) Crear un superusuario: `docker-compose exec web python manage.py createsuperuser`.

# APP

## Interfaz
Usuarios:
- **Intefaz principal**: con el logo y debajo un boton para iniciar sesion y otro para registrarse
- **Login**: Inicio de sesion con campos para correo electronico y contraseña, asi como un boton para iniciar sesion que validara las credenciales.
- **Registro**: Registro de usuarios con un formulario con campos para correo electrónico, CURP, nombre, numero, contraseña, codigo postal,colonia, calle, manzana, numero exterior, y un boton para guardar el registro asi como un mensaje de confirmacion cuando la cuenta fue creada correctamente, validacion que la contraseña tenga minimo 8 caracteres.
-  **Recuperar cuenta**: Este formulario debe tener un campo para colocar el correo electronico, y un boton para solicitar enviar el correo para recuperar la cuenta.
- **Cuenta**: en esta seccion se podran visualizar los datos del usuario y este podra modificarlos si es necesario, tambien podra ver los reportes que ha realizado, y el status (Recibido, En revisión, En atención, Resuelto, Cerrado) en el que se encuentran, ordenados por fecha, asi como los tramites que ha realizado con su estatus, y ordenados por fecha, cuando se presione en uno de estos reportes o tramites, debe llevar a la pantalla de consulta respectiva.
- **Formulario**: en la primera seccion de datos del usuario, se deberan extraer los datos del usuario que esta haciendo el reporte para auto rellenar esa seccion del reporte, en la segunda seccion debera haber un campo para, hora, ubicacion en el mapa, una evidencia fotografica, el tipo de fuga que es (fuga superficial, fuga en tubería, fuga en toma domiciliaria, drenaje obstruido), y una breve descripcion, al finalizar debera mostrar un mesaje de exito con el folio del reporte, o si existe una fuga cercana, un mensaje explicando el error.
- **Consulta de reporte**: cuando un usuario presiona un reporte dentro de la Seccion de cuenta del usuario, se debera mostrar la fecha del reporte, los datos proporcionados, el estado (Recibido, En revisión, En atención, Resuelto, Cerrado), un tiempo estimado de atencion si no ha sido resuelto, y un boton para cancelar un reporte propio siempre que este no haya sido asignado a un operador.
- **Servicios**: en esta seccion se deben mostrar arriba una barra de busqueda, debajo los ditintos tramites que se pueden realizar en la aplicación (reporte de fugas,  conexión o solicitud de Pipas con agua.) con descripcion, tiempo estimado, y si se expande debe mostrar los requisitos para realizar el tramite, al finalizar un tramite, debera mostrar un mesaje de exito con el folio del reporte, dentro de los formularios de cada tramite debe haber los campos correspondientes para el tramite, los cuales son los siguientes:
| Servicio | Documentos necesarios | Plazo de respuesta |
| --- | --- | --- |
| **Contrato de agua potable (doméstico/no doméstico)** | Identificación oficial, comprobante de domicilio, solicitud escrita | Variable según revisión del expediente |
| **Contrato de drenaje (doméstico/no doméstico)** | Identificación oficial, comprobante de domicilio, solicitud escrita | Variable según revisión del expediente |
| **Suministro de agua potable en unidad cisterna** | Personas físicas: recibo anual de pago, ubicación, nombre y teléfono. Instituciones públicas: ubicación, nombre del usuario e institución, teléfono y solicitud por escrito | Reporte firmado al concluir el servicio. Servicio gratuito |
Asi mismo se puede notificar de cambios en el tramite, mediante notificaciones push.
- **Formulario de tramite**: mostrar campos para poder adjuntar la documentación necesaria dependiendo de cada tipo de tramite. Al terminarlos mostrar una pantalla de confirmacion con el folio del tramite.
- **Consulta de tramite**:cuando un usuario presiona un tramite dentro de la Seccion de cuenta del usuario, se debera mostrar la fecha del reporte, los documentos proporcionados, el estado, las notas que tenga el tramite, un tiempo estimado de atencion si no ha sido resuelto, y un boton para cancelar un reporte propio siempre que este no haya sido completado. Cuando el tramite sea completado, mostrar el documento obtenido y un boton para descargarlo.
- **Mapa**: en esta seccion, se mostraran en un mapa interactivo todos los reportes de fugas activos del municipio diferenciados por color según su estado, se debe permitir al ciudadano seleccionar su ubicación desde el mapa o usar el GPS del dispositivo al hacer un reporte, dirigiendolo al formulario de reporte de fuga con la ubicacion ya rellenada.
- **Evaluacion**: Cuando se notifique al ciudadano de que su reporte fue resuelto, solicitar al ciudadano una calificación del servicio recibido (1-5 estrellas), junto con un comentario opcional, esta seccion podra ser habilitada cuando se reciba una notoficación push de que el reporte fue resuelto, o desde la Seccion de cuenta del usuario, en los reportes resueltos que no han sido calificados
- **Navbar**: En la seccion inferior de todas las pantallas, debe aparecer una barra de navegacion con accesos a Home, Mapa, Servicios, Usuario.
- **Home**: En esta seccion se le da la bienvenida al usuario y se muestran accesos rapidos a reportar una fuga, servicios, mapa, debajo se muestran los reportes de fugas recientres del usuario, debajo de estos los tramites hechos recientemente del usuario, y un pequeño mapa con las zonas afectadas cerca de su domicilio.

La aplicacion debera tener un archivo que permita configurar la url de la api, los colores que usara la applicacion, las credenciales, etc


Operadores:

Admin:
- Gestion interna
- Indicadores y reportes

