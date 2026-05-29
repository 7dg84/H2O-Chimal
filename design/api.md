## 'api/auth/register/'
Post:
```json
request:
{
  "email": "user11@mail.com",
  "password": "uno2tres4",
  "name": "u",
  "phone": "5555555555",
  "postal_code": "11111",
  "colonia": "a",
  "street": "b",
  "block": "1",
  "exterior_number": "2",
  "curp":"XXXX000000HNEXDDA6"
}
response:
{
  "id": "f10104e3-1f91-40ad-8f23-e870ccdcbada",
  "email": "user11@mail.com"
}
cookies:
auth_token
b4ff1836868c89961ee9d5082026091f2ac428e8
```
## 'api/auth/login/'
Post:
```json
request:
{
  "email": "user11@mail.com",
  "password": "uno2tres4"
}
response:
{
  "succes": "ok"
}
cookies:
auth_token
b34f3fa9ba5ade72f35c1db533661c1218d2a62b
```
## 'api/auth/logout/'
Post:
```json
request:
{}
response:
{
  "message": "Logout successful"
}
cookies:
auth_token
""
```
# Autenticacion requerida:
## 'api/auth/user/'
Get:
```json
response:
{
  "id": "f10104e3-1f91-40ad-8f23-e870ccdcbada",
  "email": "user11@mail.com",
  "curp": "XXXX000000HNEXDDA6",
  "name": "u",
  "phone": "5555555555",
  "postal_code": "11111",
  "colonia": "a",
  "street": "b",
  "block": "1",
  "exterior_number": "2"
}
```
## 'api/auth/token/'
## 'api/auth/token/refresh/'
## reports: '/api/reports/'
Get:
```json
Request:
response:
[
  {
    "id": "b9f68bf3-27b6-4b42-9f76-146031e7aa35",
    "media": [
      "a8366a87-b295-42a8-a781-ef3d28e4bd99"
    ],
    "folio": 15,
    "reported_at": "2026-05-24T09:01:54.344187-06:00",
    "latitude": "1.0000000",
    "longitude": "1.0000000",
    "location_text": "colonia, calle, manzana, numero",
    "report_type": "superficial",
    "description": "descripcion",
    "status": "Recibido",
    "assigned_operator_id": null,
    "estimated_time_interval": "",
    "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada"
  }
]
```
Get:
```json
Request: /api/reports/b9f68bf3-27b6-4b42-9f76-146031e7aa35/
Response: {
  "id": "b9f68bf3-27b6-4b42-9f76-146031e7aa35",
  "media": [
      "a8366a87-b295-42a8-a781-ef3d28e4bd99"
    ],
  "folio": 15,
  "reported_at": "2026-05-24T09:01:54.344187-06:00",
  "latitude": "1.0000000",
  "longitude": "1.0000000",
  "location_text": "colonia, calle, manzana, numero",
  "report_type": "superficial",
  "description": "descripcion",
  "status": "Recibido",
  "assigned_operator_id": null,
  "estimated_time_interval": "",
  "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada"
}
```
Post:
```json
Request:
{
  "latitude": "1.0",
  "longitude": "1.0",
  "location_text": "colonia, calle, manzana, numero",
  "report_type": "superficial", // ('superficial','tuberia','domiciliaria','obstruido')
  "description": "descripcion"
}
response:
{
  "id": "b9f68bf3-27b6-4b42-9f76-146031e7aa35",
  "media": [
      "a8366a87-b295-42a8-a781-ef3d28e4bd99"
    ],
  "folio": 15,
  "reported_at": "2026-05-24T09:01:54.344187-06:00",
  "latitude": "1.0000000",
  "longitude": "1.0000000",
  "location_text": "colonia, calle, manzana, numero",
  "report_type": "superficial",
  "description": "descripcion",
  "status": "Recibido",
  "assigned_operator_id": null,
  "estimated_time_interval": "",
  "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada"
}
```
Put:
```json
Request: /api/reports/b9f68bf3-27b6-4b42-9f76-146031e7aa35/
{
  "latitude": "1.1",
  "longitude": "1.1",
  "location_text": "colonia, calle, manzana, numero",
  "report_type": "tuberia",
  "description": "descripcion editada"
}
response:
{
  "id": "b9f68bf3-27b6-4b42-9f76-146031e7aa35",
  "media": [
      "a8366a87-b295-42a8-a781-ef3d28e4bd99"
    ],
  "folio": 16,
  "reported_at": "2026-05-24T09:01:54.344187-06:00",
  "latitude": "1.1000000",
  "longitude": "1.1000000",
  "location_text": "colonia, calle, manzana, numero",
  "report_type": "tuberia",
  "description": "descripcion editada",
  "status": "Recibido",
  "assigned_operator_id": null,
  "estimated_time_interval": "",
  "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada"
}
```
Delete:
```json
Request: /api/reports/b9f68bf3-27b6-4b42-9f76-146031e7aa35/
response:

```
## media: '/api/media/'
Get:
```json
Request:
response:
{
  "error": "Citizens cannot list media directly"
}
```
Get:
```json
Request: /api/media/a8366a87-b295-42a8-a781-ef3d28e4bd99/
response: 
{
  "id": "a8366a87-b295-42a8-a781-ef3d28e4bd99",
  "presigned_url": "http://media.localhost:9000/h2o-media/img_Ba0hYL7.jpg?AWSAccessKeyId=h2o_access&Signature=Q2VF5rWJa1AunouDGs%2FiQgm8TCs%3D&Expires=1779646411",
  "storage_key": "img_Ba0hYL7.jpg",
  "filename": "img.jpg",
  "mime_type": "image/jpeg",
  "uploaded_at": "2026-05-24T11:07:05.165846-06:00",
  "report": "e67fd296-3834-430a-aff3-7aed2ba39fe3"
}
```
Post:
```bash
Request:
curl -X POST "http://localhost:8000/api/media/"   -H "Authorization: Token eae4ff3c8d339446a4bc0fc260590a81aefcc94b"   -F "file=@img.jpg"   -F "report=e67fd296-3834-430a-aff3-7aed2ba39fe3"
```
```json
response: 
{
    "id":"a8366a87-b295-42a8-a781-ef3d28e4bd99",
    "presigned_url":"http://media.localhost:9000/h2o-media/img_Ba0hYL7.jpg?AWSAccessKeyId=h2o_access&Signature=ioiEXJIfHkZ3C2cdvU75YY5K2WI%3D&Expires=1779646025",
    "storage_key":"img_Ba0hYL7.jpg",
    "filename":"img.jpg",
    "mime_type":"image/jpeg",
    "uploaded_at":"2026-05-24T11:07:05.165846-06:00","report":"e67fd296-3834-430a-aff3-7aed2ba39fe3"
}
```
Put:
```json
Request: /api/media/a8366a87-b295-42a8-a781-ef3d28e4bd99/
response: 
{
  "error": "Media updates are not allowed"
}
```
Delete:
```json
Request: /api/media/a8366a87-b295-42a8-a781-ef3d28e4bd99/
response:

```
## services: '/api/services/'
Get:
```json
Request:
response:
[
  {
    "id": "04be0139-e61d-4ca0-afee-ce987b5a7845",
    "requirements": [
      {
        "document_type_id": "66f80579-3d55-45ae-905e-2c5b9f09b794",
        "document_type_name": "INE",
        "required": true,
        "notes": ""
      },
      {
        "document_type_id": "559c494d-2d8b-4a6e-b3f6-89cd729f885f",
        "document_type_name": "Contrado Odapas",
        "required": true,
        "notes": ""
      }
    ],
    "name": "pipa",
    "description": "llevar una pipa",
    "response_time": "2h"
  }
]
```
Get:
```json
Request: /api/services/04be0139-e61d-4ca0-afee-ce987b5a7845/
response:
{
  "id": "04be0139-e61d-4ca0-afee-ce987b5a7845",
  "requirements": [
    {
      "document_type_id": "66f80579-3d55-45ae-905e-2c5b9f09b794",
      "document_type_name": "INE",
      "required": true,
      "notes": ""
    },
    {
      "document_type_id": "559c494d-2d8b-4a6e-b3f6-89cd729f885f",
      "document_type_name": "Contrado Odapas",
      "required": true,
      "notes": ""
    }
  ],
  "name": "pipa",
  "description": "llevar una pipa",
  "response_time": "2h"
}
```
Post:
```json
Request:
{

}
response:
{
  "detail": "Método \"POST\" no permitido."
}
```
Put:
```json
Request: /api/services/04be0139-e61d-4ca0-afee-ce987b5a7845/
response:
{
  "detail": "Método \"PUT\" no permitido."
}
```
Delete:
```json
Request: /api/services/04be0139-e61d-4ca0-afee-ce987b5a7845/
response:
{
  "detail": "Método \"DELETE\" no permitido."
}
```
## tramites: '/api/tramites/'
Get:
```json
Request:
response:
[
  {
    "id": "54d6032e-ba1b-43d3-b8fa-795348fd38f8",
    "documents": [
      {
        "id": "1d33794a-9a1e-432b-9907-c56c544d6dae",
        "filename": "img.jpg"
      }
    ],
    "folio": 18,
    "created_at": "2026-05-24T14:56:53.924019-06:00",
    "status": "Creado",
    "notes": "",
    "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada",
    "service": "04be0139-e61d-4ca0-afee-ce987b5a7845"
  }
]
```
Get: 
```json
Request: /api/tramites/54d6032e-ba1b-43d3-b8fa-795348fd38f8/
response:
{
  "id": "54d6032e-ba1b-43d3-b8fa-795348fd38f8",
  "documents": [
    {
      "id": "1d33794a-9a1e-432b-9907-c56c544d6dae",
      "filename": "img.jpg"
    }
  ],
  "folio": 18,
  "created_at": "2026-05-24T14:56:53.924019-06:00",
  "status": "Creado",
  "notes": "",
  "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada",
  "service": "04be0139-e61d-4ca0-afee-ce987b5a7845"
}
```
Post:
```json
Request:
{
  "service": "04be0139-e61d-4ca0-afee-ce987b5a7845"
}
response:
{
  "id": "10257a61-0b8b-48ad-826d-58c86e44b5ae",
  "documents": [],
  "folio": 19,
  "created_at": "2026-05-29T17:18:22.467372-06:00",
  "status": "Creado",
  "notes": "",
  "user": "f10104e3-1f91-40ad-8f23-e870ccdcbada",
  "service": "04be0139-e61d-4ca0-afee-ce987b5a7845"
}
```
Put:
```json
Request: /api/tramites/10257a61-0b8b-48ad-826d-58c86e44b5ae/
response:
{
  "detail": "Usted no tiene permiso para realizar esta acción."
}
```
Delete:
```json
Request: /api/tramites/10257a61-0b8b-48ad-826d-58c86e44b5ae/
response: 204
```
## documents: '/api/documents/'
Get:
```json
Request: 
response:
{
  "error": "Citizens cannot list documents directly"
}
```
Get:
```json
Request: /api/documents/1d33794a-9a1e-432b-9907-c56c544d6dae/
response:
{
  "id": "1d33794a-9a1e-432b-9907-c56c544d6dae",
  "presigned_url": "http://media.localhost:9000/h2o-reports/img_MuLILRo.jpg?AWSAccessKeyId=h2o_access&Signature=cpyXjffNDpcA1ZklMDWJi0CZS6g%3D&Expires=1780101011",
  "storage_key": "img_MuLILRo.jpg",
  "filename": "img.jpg",
  "mime_type": "image/jpeg",
  "size": 46783,
  "uploaded_at": "2026-05-29T16:36:51.269315-06:00",
  "tramite": "54d6032e-ba1b-43d3-b8fa-795348fd38f8",
  "document_type": "66f80579-3d55-45ae-905e-2c5b9f09b794"
}
```
Post:
```bash
curl -X POST "http://localhost:8000/api/documents/"   -H "Authorization: Token eae4ff3c8d339446a4bc0fc260590a81aefcc94b"   -F "file=@img.jpg"   -F "tramite=54d6032e-ba1b-43d3-b8fa-795348fd38f8" -F "document_type=66f80579-3d55-45ae-905e-2c5b9f09b794"
```
```json
response:
{
  "id":"1d33794a-9a1e-432b-9907-c56c544d6dae",
  "presigned_url":null,
  "storage_key":"img_MuLILRo.jpg",
  "filename":"img.jpg",
  "mime_type":"image/jpeg",
  "size":46783,
  "uploaded_at":"2026-05-29T16:36:51.269315-06:00",
  "tramite":"54d6032e-ba1b-43d3-b8fa-795348fd38f8",
  "document_type":"66f80579-3d55-45ae-905e-2c5b9f09b794"
}
```
Put:
```json
Request: /api/documents/1d33794a-9a1e-432b-9907-c56c544d6dae/
response:
{
  "error": "Document updates are not allowed"
}
```
Delete:
```json
Request: /api/documents/1d33794a-9a1e-432b-9907-c56c544d6dae/
response: 204
```