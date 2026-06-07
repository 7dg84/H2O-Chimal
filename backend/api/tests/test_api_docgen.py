import os
import json
from datetime import datetime

from django.conf import settings
from rest_framework.test import APITestCase, APIClient


class APIDocGenerationTest(APITestCase):
    """Genera un archivo Markdown con ejemplos de petición/respuesta para la API.

    Usa credenciales fijas para verificar vistas de operador y administrador:
    - operador@mail.com / uno2tres4
    - admin@mail.com / 2tres4cinco
    También crea un usuario de prueba vía el endpoint de registro.
    """

    def _write_section(self, fp, path, method, request_obj, response_obj, cookies=None):
        fp.write(f"## '{path}'\n")
        fp.write(f"{method}:\n")
        if request_obj is not None:
            fp.write("```json\n")
            fp.write(json.dumps(request_obj, default=str, indent=2, ensure_ascii=False))
            fp.write("\n```")
        else:
            fp.write("```json\nrequest:\n```")
        fp.write("\nresponse:\n")
        fp.write("```json\n")
        try:
            fp.write(json.dumps(response_obj, default=str, indent=2, ensure_ascii=False))
        except Exception:
            fp.write(str(response_obj))
        fp.write("\n```") 
        if cookies is not None:
            fp.write("\ncookies:\n")
            for k, v in cookies.items():
                fp.write(f"{k}\n{v}\n")
        fp.write("\n")

    def test_generate_api_doc(self):
        client = APIClient()
        out_path = None
        try:
            base_dir = getattr(settings, 'BASE_DIR', os.getcwd())
            out_dir = os.path.join(base_dir, 'design')
            os.makedirs(out_dir, exist_ok=True)
            out_path = os.path.join(out_dir, 'api_generated.md')

            with open(out_path, 'w', encoding='utf-8') as fp:
                fp.write(f"# API generated on {datetime.utcnow().isoformat()}Z\n\n")

                # 1) Registro de usuario (ciudadano)
                reg_data = {
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
                resp = client.post('/api/auth/register/', reg_data, format='json')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                cookies = {}
                if 'auth_token' in resp.cookies:
                    cookies['auth_token'] = resp.cookies['auth_token'].value
                self._write_section(fp, 'api/auth/register/', 'Post', reg_data, resp_json, cookies=cookies)

                # 2) Login (operador)
                op_credentials = {"email": "operador@mail.com", "password": "uno2tres4"}
                resp = client.post('/api/auth/login/', op_credentials, format='json')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                op_cookie = resp.cookies.get('auth_token').value if 'auth_token' in resp.cookies else ''
                self._write_section(fp, 'api/auth/login/', 'Post', op_credentials, resp_json, cookies={'auth_token': op_cookie})

                # Use operator session to call protected endpoints
                if op_cookie:
                    client.cookies['auth_token'] = op_cookie
                # auth/user
                resp = client.get('/api/auth/user/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/auth/user/', 'Get', None, resp_json)

                # reports list
                resp = client.get('/api/reports/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/reports/', 'Get', None, resp_json)

                # services list (public)
                resp = client.get('/api/services/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/services/', 'Get', None, resp_json)

                # tramites list
                resp = client.get('/api/tramites/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/tramites/', 'Get', None, resp_json)

                # media: try list (likely forbidden for citizens)
                resp = client.get('/api/media/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/media/', 'Get', None, resp_json)

                # 3) Login (admin) and check admin-only views
                admin_credentials = {"email": "admin@mail.com", "password": "2tres4cinco"}
                resp = client.post('/api/auth/login/', admin_credentials, format='json')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                admin_cookie = resp.cookies.get('auth_token').value if 'auth_token' in resp.cookies else ''
                self._write_section(fp, 'api/auth/login/ (admin)', 'Post', admin_credentials, resp_json, cookies={'auth_token': admin_cookie})

                if admin_cookie:
                    client.cookies['auth_token'] = admin_cookie

                # audit-logs (admin)
                resp = client.get('/api/audit-logs/')
                try:
                    resp_json = resp.json()
                except Exception:
                    resp_json = resp.content.decode('utf-8')
                self._write_section(fp, 'api/audit-logs/', 'Get', None, resp_json)

            # assert file created
            assert out_path and os.path.exists(out_path)
        finally:
            # print path for visibility in test output
            if out_path:
                print(f'API documentation generated at: {out_path}')
