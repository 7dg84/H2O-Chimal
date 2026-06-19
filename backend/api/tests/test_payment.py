from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from api.models import Service, Tramite, Document, DocumentType, ServicePaymentConfig
from h2o.storage_backends import DocumentStorage
from unittest.mock import patch

User = get_user_model()

class PaymentFeatureTestCase(APITestCase):

    def setUp(self):
        # Create users with different roles
        self.admin_user = User.objects.create_user(
            email="admin_test@example.com",
            password="password123",
            name="Admin User",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX01",
            role="admin"
        )
        self.citizen_user = User.objects.create_user(
            email="citizen_test@example.com",
            password="password123",
            name="Citizen User",
            phone="1234567890",
            postal_code="12345",
            curp="AAAA000000HNEXX02",
            role="citizen"
        )

        # Create some services
        self.service_paid = Service.objects.create(
            name="Paid Service",
            description="Service that requires payment",
            response_time="2 days"
        )
        self.service_free = Service.objects.create(
            name="Free Service",
            description="Service that does not require payment",
            response_time="5 days"
        )

        # Setup payment configuration for Paid Service
        self.payment_config = ServicePaymentConfig.objects.create(
            service=self.service_paid,
            requires_payment=True,
            amount=250.50
        )
        
        # Setup payment configuration for Free Service but with requires_payment = False
        self.free_config = ServicePaymentConfig.objects.create(
            service=self.service_free,
            requires_payment=False,
            amount=0.00
        )

        self.client = APIClient()

    def test_admin_payment_config_crud(self):
        """Test that Admin can manage payment configuration via CRUD endpoint /api/config/"""
        self.client.force_authenticate(user=self.admin_user)
        
        # 1. List config
        response = self.client.get('/api/config/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Should have 2 entries (handles paginated and unpaginated)
        configs_list = response.data.get('results', response.data)
        self.assertEqual(len(configs_list), 2)

        # 2. Retrieve config
        response = self.client.get(f'/api/config/{self.payment_config.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(float(response.data['amount']), 250.50)

        # 3. Create config for a new service
        new_service = Service.objects.create(name="Another Service", description="Test", response_time="1 day")
        data = {
            "service": str(new_service.id),
            "requires_payment": True,
            "amount": "100.00"
        }
        response = self.client.post('/api/config/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(ServicePaymentConfig.objects.filter(service=new_service).exists())

        # 4. Update config
        update_data = {
            "service": str(new_service.id),
            "requires_payment": True,
            "amount": "120.00"
        }
        response = self.client.put(f'/api/config/{response.data["id"]}/', update_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(float(response.data['amount']), 120.00)

    def test_citizen_cannot_access_payment_config(self):
        """Test that Citizen receives 403 Forbidden when trying to access /api/config/"""
        self.client.force_authenticate(user=self.citizen_user)
        
        response = self.client.get('/api/config/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        
        response = self.client.post('/api/config/', {})
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)

    @patch('api.signals.DocumentStorage.delete')
    @patch('api.signals.DocumentStorage.save')
    def test_automatic_payment_document_generation(self, mock_save, mock_delete):
        """Test that creating a Tramite for a service that requires payment generates a PDF document"""
        mock_save.return_value = "dummy_key.pdf"
        # Create a Tramite for the paid service
        # We can create it directly in Python (to trigger post_save)
        tramite = Tramite.objects.create(
            user=self.citizen_user,
            service=self.service_paid,
            status="Creado"
        )
        
        # Verify that a Document of type "Pago" was created automatically
        docs = Document.objects.filter(tramite=tramite)
        self.assertEqual(docs.count(), 1)
        
        payment_doc = docs.first()
        self.assertEqual(payment_doc.document_type.name, "Pago")
        self.assertEqual(payment_doc.mime_type, "application/pdf")
        self.assertTrue(payment_doc.filename.startswith("pago_"))
        self.assertGreater(payment_doc.size, 0)

        # Verify that the Tramite notes were updated
        tramite.refresh_from_db()
        self.assertIn('Hemos adjuntado el pago correspondiente, pagalo y sube el comprobante.', tramite.notes)
        
        # Clean up storage
        if payment_doc.storage_key:
            DocumentStorage().delete(payment_doc.storage_key)

    def test_no_document_generation_for_free_service(self):
        """Test that creating a Tramite for a service that does not require payment does not generate any document"""
        tramite = Tramite.objects.create(
            user=self.citizen_user,
            service=self.service_free,
            status="Creado"
        )
        
        docs = Document.objects.filter(tramite=tramite)
        self.assertEqual(docs.count(), 0)

    def test_no_document_generation_for_unconfigured_service(self):
        """Test that creating a Tramite for a service with no payment configuration does not generate any document"""
        unconfigured_service = Service.objects.create(
            name="Unconfigured Service",
            description="No payment config in DB",
            response_time="3 days"
        )
        
        tramite = Tramite.objects.create(
            user=self.citizen_user,
            service=unconfigured_service,
            status="Creado"
        )
        
        docs = Document.objects.filter(tramite=tramite)
        self.assertEqual(docs.count(), 0)
