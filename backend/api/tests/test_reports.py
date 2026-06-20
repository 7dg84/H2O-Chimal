from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from api.models import Report, Media
import uuid

User = get_user_model()

class ReportCRUDTestCase(APITestCase):

    def setUp(self):
        # Create users
        self.admin_user = User.objects.create_user(
            email="admin_report@example.com",
            password="password123",
            name="Admin User",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX01",
            role="admin"
        )
        self.citizen_user = User.objects.create_user(
            email="citizen_report@example.com",
            password="password123",
            name="Citizen User",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX02",
            role="citizen"
        )
        self.other_citizen = User.objects.create_user(
            email="citizen_other@example.com",
            password="password123",
            name="Other Citizen",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX03",
            role="citizen"
        )
        self.operator_user = User.objects.create_user(
            email="operator_report@example.com",
            password="password123",
            name="Operator User",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX04",
            role="operator"
        )

        # Create a report for testing updates/deletes
        self.report_recibido = Report.objects.create(
            user=self.citizen_user,
            latitude="19.4326077",
            longitude="-99.133208",
            location_text="Zocalo, CDMX",
            report_type="media",
            description="Reporte recibido",
            status="Recibido"
        )

        self.report_en_revision = Report.objects.create(
            user=self.citizen_user,
            latitude="19.4326077",
            longitude="-99.133208",
            location_text="Zocalo, CDMX",
            report_type="alta",
            description="Reporte en revision",
            status="En revisión"
        )

        self.client = APIClient()

    def test_citizen_create_report_restrictions(self):
        """Test that Citizen can create a report but system fields are ignored/forced."""
        self.client.force_authenticate(user=self.citizen_user)
        data = {
            "latitude": "19.4326077",
            "longitude": "-99.133208",
            "location_text": "Calle Falsa 123",
            "report_type": "alta",
            "description": "Fuga de agua",
            # Read-only fields for citizen that should be ignored:
            "user": self.other_citizen.id,
            "status": "Resuelto",
            "notes": "Intento de escribir notas",
            "assigned_operator_id": str(self.operator_user.id),
            "estimated_time_interval": "1 hour"
        }
        response = self.client.post('/api/reports/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify the database entry
        report_id = response.data['id']
        report = Report.objects.get(id=report_id)
        
        # Verify location and details
        self.assertEqual(report.description, "Fuga de agua")
        self.assertEqual(report.report_type, "alta")
        # Verify citizen forced fields
        self.assertEqual(report.user, self.citizen_user) # Not other_citizen
        self.assertEqual(report.status, "Recibido") # Not Resuelto
        self.assertEqual(report.notes, "") # Not what was sent
        self.assertIsNone(report.assigned_operator_id)
        self.assertEqual(report.estimated_time_interval, "")

    def test_citizen_update_restrictions(self):
        """Test that Citizen can update a report in 'Recibido' but not in other statuses."""
        self.client.force_authenticate(user=self.citizen_user)

        # 1. Update 'Recibido' report: OK
        data = {
            "latitude": "19.4326077",
            "longitude": "-99.133208",
            "location_text": "Zocalo, CDMX Modificado",
            "report_type": "baja",
            "description": "Reporte recibido modificado"
        }
        response = self.client.put(f'/api/reports/{self.report_recibido.id}/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.report_recibido.refresh_from_db()
        self.assertEqual(self.report_recibido.location_text, "Zocalo, CDMX Modificado")

        # 2. Update 'En revisión' report: FORBIDDEN/BAD REQUEST
        response = self.client.put(f'/api/reports/{self.report_en_revision.id}/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['error'], 'Only reports in "Recibido" status can be updated')

    def test_citizen_delete_restrictions(self):
        """Test that Citizen can delete a report in 'Recibido' but not in other statuses."""
        self.client.force_authenticate(user=self.citizen_user)

        # 1. Delete 'En revisión' report: FORBIDDEN/BAD REQUEST
        response = self.client.delete(f'/api/reports/{self.report_en_revision.id}/')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['error'], 'Only reports in "Recibido" status can be deleted')

        # 2. Delete 'Recibido' report: OK
        response = self.client.delete(f'/api/reports/{self.report_recibido.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Report.objects.filter(id=self.report_recibido.id).exists())

    def test_admin_full_crud(self):
        """Test that Admin has full CRUD and can write to all fields."""
        self.client.force_authenticate(user=self.admin_user)

        # 1. Admin Create: Can set user, status, notes, assigned operator, and estimated time
        data = {
            "latitude": "19.4326077",
            "longitude": "-99.133208",
            "location_text": "Parque Central",
            "report_type": "extrema",
            "description": "Fuga masiva de gas",
            "user": str(self.citizen_user.id),
            "status": "En revisión",
            "notes": "Notas del administrador iniciales",
            "assigned_operator_id": str(self.operator_user.id),
            "estimated_time_interval": "2 hours"
        }
        response = self.client.post('/api/reports/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        report_id = response.data['id']
        report = Report.objects.get(id=report_id)
        
        self.assertEqual(report.user, self.citizen_user)
        self.assertEqual(report.status, "En revisión")
        self.assertEqual(report.notes, "Notas del administrador iniciales")
        self.assertEqual(report.assigned_operator_id, self.operator_user.id)
        self.assertEqual(report.estimated_time_interval, "2 hours")

        # 2. Admin Update (PUT/PATCH): Can update any report status and all other fields
        update_data = {
            "latitude": "19.4326077",
            "longitude": "-99.133208",
            "location_text": "Parque Central Actualizado",
            "report_type": "alta",
            "description": "Fuga de gas controlada",
            "user": str(self.other_citizen.id),
            "status": "Resuelto",
            "notes": "Resuelto por el administrador",
            "assigned_operator_id": str(self.admin_user.id),
            "estimated_time_interval": "Done"
        }
        # Update report_en_revision (which non-admins cannot update)
        response = self.client.put(f'/api/reports/{self.report_en_revision.id}/', update_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.report_en_revision.refresh_from_db()
        self.assertEqual(self.report_en_revision.location_text, "Parque Central Actualizado")
        self.assertEqual(self.report_en_revision.user, self.other_citizen)
        self.assertEqual(self.report_en_revision.status, "Resuelto")
        self.assertEqual(self.report_en_revision.notes, "Resuelto por el administrador")
        self.assertEqual(self.report_en_revision.assigned_operator_id, self.admin_user.id)
        self.assertEqual(self.report_en_revision.estimated_time_interval, "Done")

        # 3. Admin Delete: Can delete reports in non-'Recibido' status
        response = self.client.delete(f'/api/reports/{self.report_en_revision.id}/')
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Report.objects.filter(id=self.report_en_revision.id).exists())

    def test_folio_not_recalculated_on_update(self):
        """Test that updating a report does not change or increment its original folio."""
        self.client.force_authenticate(user=self.admin_user)
        
        original_folio = self.report_recibido.folio
        
        # Save or update through ViewSet
        data = {
            "description": "Reporte recibido - descripcion modificada",
            "latitude": str(self.report_recibido.latitude),
            "longitude": str(self.report_recibido.longitude),
            "location_text": self.report_recibido.location_text,
            "report_type": self.report_recibido.report_type
        }
        response = self.client.put(f'/api/reports/{self.report_recibido.id}/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        self.report_recibido.refresh_from_db()
        self.assertEqual(self.report_recibido.folio, original_folio)
