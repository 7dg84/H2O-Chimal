# API generated on 2026-06-07T00:34:52.550988Z

## 'api/auth/register/'
Post:
```json
{
  "email": "testuser_generated@mail.com",
  "password": "uno2tres4",
  "name": "Test User",
  "phone": "5550000000",
  "postal_code": "11111",
  "colonia": "Colonia",
  "street": "Calle",
  "block": "1",
  "exterior_number": "2",
  "curp": "AAAA000000HNEXX00"
}
```
response:
```json
{
  "curp": "CURP inválida"
}
```
cookies:

## 'api/auth/login/'
Post:
```json
{
  "email": "operador@mail.com",
  "password": "uno2tres4"
}
```
response:
```json
{
  "detail": "No User matches the given query."
}
```
cookies:
auth_token


## 'api/auth/user/'
Get:
```json
request:
```
response:
```json
{
  "detail": "Las credenciales de autenticación no se proveyeron."
}
```
## 'api/reports/'
Get:
```json
request:
```
response:
```json
{
  "detail": "Las credenciales de autenticación no se proveyeron."
}
```
## 'api/services/'
Get:
```json
request:
```
response:
```json
{
  "count": 0,
  "next": null,
  "previous": null,
  "results": []
}
```
## 'api/tramites/'
Get:
```json
request:
```
response:
```json
{
  "detail": "Las credenciales de autenticación no se proveyeron."
}
```
## 'api/media/'
Get:
```json
request:
```
response:
```json
{
  "detail": "Las credenciales de autenticación no se proveyeron."
}
```
## 'api/auth/login/ (admin)'
Post:
```json
{
  "email": "admin@mail.com",
  "password": "2tres4cinco"
}
```
response:
```json
{
  "detail": "No User matches the given query."
}
```
cookies:
auth_token


## 'api/audit-logs/'
Get:
```json
request:
```
response:
```json
{
  "detail": "Las credenciales de autenticación no se proveyeron."
}
```
