# INGENIERIA DE REQUERIMIENTOS

## Requerimientos Funcionales.

|     |     |
| --- | --- |
| Módulo: Registro y autenticación de usuarios |     |
| RF1.- Registrar usuarios ciudadanos mediante correo electrónico, CURP, nombre, número telefónico y domicilio. | RF2.- Implementar un sistema que distinga entre humanos y máquinas para evitar ataques de fuerza bruta. |
| RF3.- Validar que los datos de registro y autenticación tengan un formato valido. | RF4.- Implementar botones accesibles para navegar hacia el login/registro. |
| RF5.- Validar que la contraseña ingresada tenga más de 8 caracteres al registrarse. | RF6.- Debe existir una verificación en dos o más pasos para los usuarios de administrativos. |
| RF7.- Permitir la recuperación de contraseña mediante correo electrónico o número telefónico registrado. | RF8.- Permitir al usuario editar su información de perfil (nombre, teléfono, domicilio) desde su cuenta. |
| Módulo: Reporte de fugas de agua |     |
| RF1.- Registrar datos del ciudadano que hizo el reporte. | RF2.- Registrar la ubicación, hora, así como una evidencia fotográfica de la fuga. |
| RF3.- Permitir al ciudadano clasificar el tipo de fuga (fuga superficial, fuga en tubería, fuga en toma domiciliaria, drenaje obstruido). | RF4.- Permitir agregar una descripción breve de texto libre para detallar la situación de la fuga. |
| RF5.- Generar automáticamente un folio único de reporte al momento del envío y notificarlo al ciudadano. | Validar que no exista un reporte activo duplicado en un radio de 10 metros antes de registrar uno nuevo. |
| Módulo: Seguimiento de reportes |     |
| RF1.- Mostrar al ciudadano el estado actual de su reporte (Recibido, En revisión, En atención, Resuelto, Cerrado). | RF2.- Enviar notificaciones push y/o email/sms al ciudadano cada vez que cambie el estado de su reporte. |
| RF3.- Permitir al ciudadano consultar el historial de todos sus reportes realizados con sus respectivos estados y fechas. | RF4.- Mostrar el tiempo estimado de atención para el reporte según la prioridad y carga de trabajo del municipio. |
| RF5.- Permitir al ciudadano cancelar un reporte propio siempre que este no haya sido asignado a un operador. |     |
| Módulo: Gestión interna (operadores y administración) |     |
| RF1.- Permitir al administrador registrar, editar y dar de baja a operadores de campo, asignándoles roles y zonas de cobertura. | RF2.- Permitir al administrador asignar reportes a operadores específicos o por zona geográfica automáticamente. |
| RF3.- Permitir al operador actualizar el estado del reporte e ingresar notas de trabajo y evidencia fotográfica del avance. | RF4.- Registrar la bitácora de cambios de estado de cada reporte con usuario, fecha y hora. |
| RF5.- Permitir al administrador establecer niveles de prioridad (alta, media, baja) para los reportes según criterios configurables. | RF6.- Enviar alertas internas al supervisor cuando un reporte lleve más tiempo del permitido sin ser atendido. |
| Módulo: Solicitudes de servicios de agua |     |
| RF1.- Permitir al ciudadano realizar solicitudes de servicio como conexión o solicitud de Pipas con agua. | RF2.- Mostrar al ciudadano el catálogo de servicios disponibles con descripción, tiempo estimado y requisitos de cada uno. |
| RF3.- Generar un folio único por solicitud y permitir su seguimiento independiente al módulo de reportes de fuga. | RF4.- Permitir adjuntar documentos o fotografías como requisitos para ciertas solicitudes de servicio. |
| RF5.- Notificar al ciudadano la fecha y hora programada para la atención de su solicitud de servicio. |     |
| Módulo: Mapa y visualización |     |
| RF1.- Mostrar en un mapa interactivo todos los reportes activos del municipio diferenciados por color según su estado. | RF2.- Permitir al ciudadano seleccionar su ubicación desde el mapa o usar el GPS del dispositivo al hacer un reporte. |
| RF3.- Mostrar zonas de alta incidencia de fugas mediante un mapa de calor visible para administradores y operadores. | RF4.- Permitir filtrar reportes en el mapa por colonia, tipo de fuga, fecha y zona geográfica. |
| Módulo: Indicadores y reportes (para administración) |     |
| RF1.- Mostrar un panel con indicadores clave: total de reportes, tiempo promedio de atención y tasa de resolución por periodo. | RF2.- Generar reportes exportables en PDF y Excel con filtros por fecha, zona, tipo de fuga y operador asignado. |
| RF3.- Mostrar gráficas comparativas de reportes por mes, colonia y tipo de incidencia para identificar tendencias. | RF4.- Registrar y mostrar el desempeño individual de cada operador (reportes atendidos, tiempo promedio). |
| Módulo: Evaluación del servicio |     |
| RF1.- Solicitar al ciudadano una calificación del servicio recibido (1-5 estrellas) una vez que el reporte sea marcado como resuelto. | RF2.- Permitir al ciudadano agregar un comentario de texto libre al momento de evaluar la atención recibida. |
| RF3.- Mostrar al administrador el promedio de calificaciones por operador, por zona y por periodo de tiempo. | RF4.- Permitir al ciudadano reabrir un reporte marcado como resuelto si considera que el problema persiste, adjuntando nueva evidencia. |

## Requerimientos No Funcionales

|     |     |
| --- | --- |
| Categoría: Look and feel |     |
| RNF1.- utilizar colores, iconografía y tipografía legibles, acorde a los colores institucionales del municipio. | RNF2.- El diseño debe ser consistente y estético en distintas plataformas (Android, IOS) |
| RNF3.- El sistema debe utilizar iconos intuitivos y universales para las funciones de reporte | RNF4.- Los estados de los reportes deben estar diferenciados visualmente mediante una paleta de colores semántica |
| Categoría: Usabilidad |     |
| RNF1.- El sistema debe permitir que un usuario complete un reporte de fuga en un tiempo máximo de 2 minutos. | RNF2.- La aplicación debe cumplir con las pautas de accesibilidad |
| RNF3.- Los mensajes de error deben ser descriptivos y sugerir una acción correctiva al usuario en lenguaje no técnico. | RNF4.- Las funcionalidades principales, deben ser rápidamente accesibles y fáciles de encontrar. |
| Categoría: Rendimiento |     |
| RNF1.- El tiempo de respuesta del servidor para consultas simples (historial, perfil) no debe exceder los 2 segundos bajo condiciones normales. | RNF2.- El sistema debe soportar una carga concurrente de al menos 500 usuarios activos sin degradación del servicio. |
| RNF3.- La carga del mapa interactivo y sus marcadores debe realizarse en un tiempo máximo de 3 segundos. | RNF4.- El sistema debe guardar los registros de 50,000 ciudadanos sin degradarse. |
| Categoría: Seguridad |     |
| RNF1.- Todas las comunicaciones entre el cliente y el servidor deben estar cifradas. | RNF2.- Las contraseñas de los usuarios deben almacenarse utilizando algoritmos de hash seguros. |
| RNF3.- El sistema debe implementar un mecanismo de bloqueo temporal de cuenta tras 5 intentos fallidos de inicio de sesión. | RNF4.- Los datos sensibles como la CURP y el domicilio deben estar protegidos y solo ser visibles para personal administrativo autorizado. |
| Categoría: Legales / Normativos |     |
| RNF1.- El sistema debe cumplir con la Ley General de Protección de Datos Personales en Posesión de Sujetos Obligados. | RNF2.- Se debe presentar un Aviso de Privacidad integral que el usuario debe aceptar explícitamente antes del registro. |
| RNF3.- El sistema debe generar respaldos (backups) diarios de la base de datos, los cuales deben almacenarse en una ubicación geográfica distinta. | RNF4.- El sistema no debe contener algun tipo de propaganda, especialmente en periodos de veda electoral. |

# IDENTIFICACIÓN DE STAKEHOLDERS

|     |     |
| --- | --- |
| Stakeholder | Función |
| Ciudadanos | Harán uso directo de la aplicación para reportar fugas de agua y solicitar servicios relacionados con el abastecimiento. Su función principal es proporcionar información oportuna y veraz sobre incidencias en la red hidráulica, incluyendo evidencia y ubicación. |
| Operadores | Son los encargados de atender a los reportes de fugas de agua, se les asignaran los reportes y su función será la de resolver el incidente lo antes posible, cuando finalicen deberán reportarlo. |
| Administradores | Los administradores gestionaran la plataforma, la asignación de reportes a operadores, y tendrán acceso a todos los registros de los usuarios y operadores, principalmente se encargarán de gestionar reportes. |
