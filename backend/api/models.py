import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager


class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True)
    curp = models.CharField(max_length=18, unique=True, null=True, blank=False)
    name = models.CharField(max_length=200, blank=False)
    phone = models.CharField(max_length=30, blank=False)
    postal_code = models.CharField(max_length=10, blank=False)
    colonia = models.CharField(max_length=200, blank=False)
    street = models.CharField(max_length=200, blank=False)
    block = models.CharField(max_length=50, blank=False)
    exterior_number = models.CharField(max_length=10, blank=False)
    ROLE_CHOICES = [
        ('citizen', 'Ciudadano'),
        ('operator', 'Operador'),
        ('admin', 'Administrador')
    ]
    role = models.CharField(
        max_length=20, choices=ROLE_CHOICES, default='citizen')
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email


class Service(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200, blank=False)
    description = models.TextField(blank=False)
    response_time = models.CharField(max_length=100, blank=False)

    def __str__(self):
        return self.name


class DocumentType(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name


class ServiceRequirement(models.Model):
    service = models.ForeignKey(Service, on_delete=models.CASCADE)
    document_type = models.ForeignKey(DocumentType, on_delete=models.CASCADE)
    required = models.BooleanField(default=True)
    notes = models.TextField(blank=True)


class Report(models.Model):
    REPORT_TYPES = [('superficial', 'superficial'), ('tuberia', 'tuberia'),
                    ('domiciliaria', 'domiciliaria'), ('obstruido', 'obstruido')]
    STATUS_CHOICES = [('Recibido', 'Recibido'), ('En revisión', 'En revisión'), (
        'En atención', 'En atención'), ('Resuelto', 'Resuelto'), ('Cerrado', 'Cerrado')]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, null=True, on_delete=models.SET_NULL)
    folio = models.PositiveBigIntegerField(unique=True, editable=False)
    reported_at = models.DateTimeField(auto_now_add=True)
    latitude = models.DecimalField(
        max_digits=14, decimal_places=10, null=False, blank=False)
    longitude = models.DecimalField(
        max_digits=14, decimal_places=10, null=False, blank=False)
    location_text = models.CharField(max_length=300, blank=False)
    report_type = models.CharField(
        max_length=50, choices=REPORT_TYPES, blank=False)
    description = models.TextField(blank=False)
    status = models.CharField(
        max_length=50, choices=STATUS_CHOICES, default='Recibido')
    notes = models.TextField(blank=True)
    assigned_operator_id = models.UUIDField(null=True, blank=True)
    estimated_time_interval = models.CharField(max_length=200, blank=True)

    def save(self, *args, **kwargs):
        last = Report.objects.order_by('-folio').first()
        self.folio = (last.folio + 1) if last else 1
        super().save(*args, **kwargs)

    def __str__(self):
        return f"ID {self.id} Report {self.folio} by {self.user}"


class Media(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    report = models.ForeignKey(Report, on_delete=models.CASCADE)
    storage_key = models.TextField()
    filename = models.CharField(max_length=255, blank=False)
    mime_type = models.CharField(max_length=100, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)


class Tramite(models.Model):
    STATUS = [('Creado', 'Creado'), ('En tramite', 'En tramite'),
              ('Completado', 'Completado')]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, null=True, on_delete=models.SET_NULL)
    service = models.ForeignKey(Service, on_delete=models.PROTECT)
    folio = models.PositiveBigIntegerField(unique=True, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=50, choices=STATUS, default='Creado')
    notes = models.TextField(blank=True)

    def save(self, *args, **kwargs):
        last = Tramite.objects.order_by('-folio').first()
        self.folio = (last.folio + 1) if last else 1
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Tramite:{self.id} by {self.user}"


class Document(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, null=False, on_delete=models.CASCADE)
    tramite = models.ForeignKey(
        Tramite, null=False, blank=False, on_delete=models.CASCADE)
    document_type = models.ForeignKey(DocumentType, on_delete=models.PROTECT)
    storage_key = models.TextField()
    filename = models.CharField(max_length=255, blank=False)
    mime_type = models.CharField(max_length=100, blank=True)
    size = models.BigIntegerField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)


class AuditLog(models.Model):
    """Simple audit log for tracking important actions."""
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        User, null=True, blank=True, on_delete=models.SET_NULL)
    action = models.CharField(max_length=100)
    target_type = models.CharField(max_length=100, blank=True)
    target_id = models.CharField(max_length=100, blank=True)
    metadata = models.JSONField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [models.Index(fields=['action', 'created_at'])]

    def __str__(self):
        return f"{self.action} by {self.user} @ {self.created_at}"
