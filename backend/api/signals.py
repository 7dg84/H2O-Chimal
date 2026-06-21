from django.db.models.signals import post_migrate, post_save
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from django.dispatch import receiver
from django.core.files.base import ContentFile
import uuid

from .models import Tramite, Document, DocumentType, ServicePaymentConfig
from .utils_pdf import generate_payment_pdf, generate_oficio_pdf
from h2o.storage_backends import DocumentStorage


@receiver(post_migrate)
def create_default_groups(sender, **kwargs):
    # Create Operator and Administrator groups and assign sensible permissions
    operator_group, _ = Group.objects.get_or_create(name='Operator')
    admin_group, _ = Group.objects.get_or_create(name='Administrator')

    # Define permissions we want to assign
    perms = []
    try:
        # Reports
        report_ct = ContentType.objects.get(app_label='api', model='report')
        perms += list(Permission.objects.filter(content_type=report_ct, codename__in=['view_report','change_report']))
    except ContentType.DoesNotExist:
        pass

    try:
        tramite_ct = ContentType.objects.get(app_label='api', model='tramite')
        perms += list(Permission.objects.filter(content_type=tramite_ct, codename__in=['view_tramite','change_tramite']))
    except ContentType.DoesNotExist:
        pass

    try:
        doc_ct = ContentType.objects.get(app_label='api', model='document')
        perms += list(Permission.objects.filter(content_type=doc_ct, codename__in=['view_document','add_document']))
    except ContentType.DoesNotExist:
        pass

    # Assign minimal perms to operator
    for p in perms:
        operator_group.permissions.add(p)

    # Administrator gets all permissions for the app
    all_perms = Permission.objects.filter(content_type__app_label='api')
    for p in all_perms:
        admin_group.permissions.add(p)


@receiver(post_save, sender=Tramite)
def handle_tramite_payment_document(sender, instance, created, **kwargs):
    if not created:
        return

    # Check if the service of the tramite is in the ServicePaymentConfig table
    try:
        payment_config = ServicePaymentConfig.objects.get(service=instance.service)
    except ServicePaymentConfig.DoesNotExist:
        # If no config is defined, it does not require payment
        return

    if not payment_config.requires_payment:
        return

    # The service requires payment!
    amount = payment_config.amount
    
    # 1. Get or create the DocumentType for "Pago"
    doc_type, _ = DocumentType.objects.get_or_create(
        name="Pago",
        defaults={"description": "Documento de pago del trámite"}
    )
    
    # 2. Get the user for the document (must not be None)
    user = instance.user
    if not user:
        from django.contrib.auth import get_user_model
        User = get_user_model()
        user = User.objects.filter(is_superuser=True).first() or User.objects.filter(role='admin').first()
        if not user:
            # If no user exists at all, we can't create the Document
            return

    # 3. Generate PDF bytes
    try:
        pdf_bytes = generate_payment_pdf(instance, amount)
    except Exception:
        # Fallback or log if PDF generation fails
        return

    # 4. Save PDF to DocumentStorage
    storage = DocumentStorage()
    filename = f"pago_{instance.folio}_{uuid.uuid4().hex[:8]}.pdf"
    
    try:
        file_content = ContentFile(pdf_bytes)
        storage_key = storage.save(filename, file_content)
    except Exception:
        return

    # 5. Create the Document instance
    Document.objects.create(
        user=user,
        tramite=instance,
        document_type=doc_type,
        storage_key=storage_key,
        filename=filename,
        mime_type="application/pdf",
        size=len(pdf_bytes)
    )
    
    # 6. Add a comment to notify the payment
    new_note = 'Hemos adjuntado el pago correspondiente, pagalo y sube el comprobante.'
    current_notes = instance.notes or ""
    if current_notes:
        updated_notes = f"{current_notes}\n{new_note}"
    else:
        updated_notes = new_note
    
    Tramite.objects.filter(pk=instance.id).update(notes=updated_notes)
    instance.notes = updated_notes


@receiver(post_save, sender=Document)
def handle_oficio_document_generation(sender, instance, created, **kwargs):
    if not created:
        return

    # Document type UUIDs as specified by user
    COMPROBANTE_PAGO_ID = uuid.UUID('3911bbe8-45b7-4c72-9989-bd585d620d15')
    OFICIO_ID = uuid.UUID('9c1a9967-2fa1-4963-a72a-acea41835404')

    # Get or create document types with the specified UUIDs
    comprobante_type, _ = DocumentType.objects.get_or_create(
        id=COMPROBANTE_PAGO_ID,
        defaults={
            "name": "Comprobante de pago",
            "description": "Comprobante de pago del trámite"
        }
    )
    oficio_type, _ = DocumentType.objects.get_or_create(
        id=OFICIO_ID,
        defaults={
            "name": "Oficio",
            "description": "Oficio de trámite"
        }
    )

    # Check if the saved document is of type "Comprobante de pago"
    if instance.document_type_id != COMPROBANTE_PAGO_ID:
        return

    tramite = instance.tramite
    if not tramite:
        return

    # Update Tramite status to "En tramite"
    Tramite.objects.filter(pk=tramite.id).update(status='En tramite')
    tramite.status = 'En tramite'

    # Check if an Oficio document already exists for this tramite to avoid duplicates
    if Document.objects.filter(tramite=tramite, document_type_id=OFICIO_ID).exists():
        return

    # Generate the Oficio PDF
    try:
        pdf_bytes = generate_oficio_pdf(tramite)
    except Exception:
        return

    # Save to storage
    storage = DocumentStorage()
    filename = f"oficio_{tramite.folio}_{uuid.uuid4().hex[:8]}.pdf"

    try:
        file_content = ContentFile(pdf_bytes)
        storage_key = storage.save(filename, file_content)
    except Exception:
        return

    # Create the Oficio Document instance
    user = instance.user or tramite.user
    if not user:
        from django.contrib.auth import get_user_model
        User = get_user_model()
        user = User.objects.filter(is_superuser=True).first() or User.objects.filter(role='admin').first()
        if not user:
            return

    Document.objects.create(
        user=user,
        tramite=tramite,
        document_type=oficio_type,
        storage_key=storage_key,
        filename=filename,
        mime_type="application/pdf",
        size=len(pdf_bytes)
    )



