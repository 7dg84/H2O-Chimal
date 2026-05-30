from rest_framework import serializers
from .models import User, Report, Document, Service, DocumentType, Tramite, Media
from django.contrib.auth import get_user_model
from django.conf import settings
from django.core.files.storage import default_storage
import re
import os
import boto3
from .models import ServiceRequirement
from h2o.storage_backends import MediaStorage, DocumentStorage


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = get_user_model()
        fields = ['id', 'email', 'curp', 'name', 'phone', 'postal_code',
                  'colonia', 'street', 'block', 'exterior_number']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = get_user_model()
        fields = ['email', 'password', 'curp', 'name', 'phone',
                  'postal_code', 'colonia', 'street', 'block', 'exterior_number']

    def create(self, validated_data):
        # Required fields check
        phone = validated_data.get('phone')
        curp = validated_data.get('curp')
        postal_code = validated_data.get('postal_code')

        if not phone:
            raise serializers.ValidationError(
                {'phone': 'Número de teléfono requerido'})
        if not curp:
            raise serializers.ValidationError({'curp': 'CURP requerida'})
        if not postal_code:
            raise serializers.ValidationError(
                {'postal_code': 'Código postal requerido'})

        # Validate phone number
        if not phone.isdigit() or len(phone) != 10:
            raise serializers.ValidationError(
                {'phone': 'Número de teléfono inválido'})

        # Validate CURP format
        curp_pattern = r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$'
        if not re.match(curp_pattern, curp):
            raise serializers.ValidationError({'curp': 'CURP inválida'})

        # validate postal code
        if not postal_code.isdigit() or len(postal_code) != 5:
            raise serializers.ValidationError(
                {'postal_code': 'Código postal inválido'})

        password = validated_data.pop('password')
        # Use the custom manager to create the user (handles password properly)
        user = get_user_model().objects.create_user(**validated_data, password=password)
        return user


class ReportSerializer(serializers.ModelSerializer):
    media = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Report
        fields = '__all__'
        read_only_fields = ['id', 'user', 'folio', 'reported_at', 'status',
                            'assigned_operator_id', 'estimated_time_interval']

    def create(self, validated_data):
        validated_data.pop('user', None)  # Ensure user is not set by client
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)
    
    def get_media(self, obj):
        media_qs = Media.objects.filter(report=obj)
        # Return only list of media IDs to avoid generating presigned URLs for every media
        return [str(m.id) for m in media_qs]


class AssignSerializer(serializers.Serializer):
    operator_id = serializers.UUIDField()


class StatusChangeSerializer(serializers.Serializer):
    status = serializers.CharField()
    note = serializers.CharField(required=False, allow_blank=True)


class MediaSerializer(serializers.ModelSerializer):
    presigned_url = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Media
        fields = '__all__'
        # `report` must be provided when creating a Media, but must not be updatable afterwards
        read_only_fields = ['id', 'uploaded_at']

    def get_presigned_url(self, obj):
        if not obj.storage_key:
            return None
        # Try to build presigned URL using boto3 via default storage
        try:
            storage = MediaStorage()
            bucket = storage.bucket_name
            # Use public endpoint for signing if provided in settings, otherwise fall back to storage's endpoint
            endpoint = getattr(settings, 'CEPH_PUBLIC_ENDPOINT', None) or storage.connection.meta.client.meta.endpoint_url
            # If we have a public endpoint, create a boto3 client that will sign URLs for that host
            if endpoint:
                client = boto3.client('s3',
                    endpoint_url=endpoint,
                    aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', os.environ.get('CEPH_ACCESS_KEY')),
                    aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', os.environ.get('CEPH_SECRET_KEY')),
                    region_name=getattr(settings, 'AWS_S3_REGION_NAME', os.environ.get('CEPH_REGION')),
                )
            else:
                client = storage.connection.meta.client
        except Exception:
            return None
        
    def create(self, validated_data):
        # validate if the report belongs to the user (if citizen) or is assigned to the operator (if operator)
        request = self.context['request']
        user = getattr(request, 'user', None)
        report = validated_data.get('report')
        # report is required on create
        if not report:
            raise serializers.ValidationError({'report': 'Este campo es requerido.'})
        if user and getattr(user, 'role', '') == 'citizen':
            if report.user_id != user.id:
                raise serializers.ValidationError('Reporte no pertenece al usuario')
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # Prevent changing the `report` of an existing Media
        if 'report' in validated_data and validated_data['report'] != instance.report:
            raise serializers.ValidationError({'report': 'No se puede cambiar el reporte asociado a un medio.'})
        return super().update(instance, validated_data)


class DocumentSerializer(serializers.ModelSerializer):
    presigned_url = serializers.SerializerMethodField(read_only=True)
    user = serializers.HiddenField(default=serializers.CurrentUserDefault())

    class Meta:
        model = Document
        fields = '__all__'
        read_only_fields = ['id', ]

    def get_presigned_url(self, obj):
        if not obj.storage_key:
            return None
        # Try to build presigned URL using boto3 via default storage
        try:
            storage = DocumentStorage()
            bucket = storage.bucket_name
            endpoint = getattr(settings, 'CEPH_PUBLIC_ENDPOINT', None)
            # If we have a public endpoint, create a boto3 client that will sign URLs for that host
            if endpoint:
                client = boto3.client('s3',
                    endpoint_url=endpoint,
                    aws_access_key_id=getattr(settings, 'AWS_ACCESS_KEY_ID', os.environ.get('CEPH_ACCESS_KEY')),
                    aws_secret_access_key=getattr(settings, 'AWS_SECRET_ACCESS_KEY', os.environ.get('CEPH_SECRET_KEY')),
                    region_name=getattr(settings, 'AWS_S3_REGION_NAME', os.environ.get('CEPH_REGION')),
                )
            else:
                client = storage.connection.meta.client
            return client.generate_presigned_url('get_object', Params={'Bucket': bucket, 'Key': obj.storage_key}, ExpiresIn=3600)
        except Exception:
            return None

    def create(self, validated_data):
        # Automatically associate the creating user with the Document
        request = self.context.get('request')
        user = getattr(request, 'user', None)
        if not user or not user.is_authenticated:
            raise serializers.ValidationError('Authentication required to create a Document')

        # If the user is a citizen, ensure the tramite belongs to them
        tramite = validated_data.get('tramite')
        if tramite and getattr(user, 'role', '') == 'citizen' and tramite.user_id != user.id:
            raise serializers.ValidationError('El tramite no pertenece al usuario autenticado')

        return super().create(validated_data)


class ServiceSerializer(serializers.ModelSerializer):
    requirements = serializers.SerializerMethodField()

    class Meta:
        model = Service
        fields = '__all__'

    def get_requirements(self, obj):
        # return list of document types required for this service
        reqs = ServiceRequirement.objects.filter(service=obj)
        out = []
        for r in reqs.select_related('document_type'):
            dt = r.document_type
            out.append({
                'document_type_id': str(dt.id),
                'document_type_name': dt.name,
                'required': r.required,
                'notes': r.notes,
            })
        return out


class TramiteSerializer(serializers.ModelSerializer):
    documents = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Tramite
        fields = '__all__'
        read_only_fields = ['id', 'user', 'folio', 'created_at']

    def create(self, validated_data):
        validated_data.pop('user', None)  # Ensure user is not set by client
        validated_data.pop('folio', None)  # Ensure folio is not set by client
        validated_data.pop('status', None)  # Ensure status is not set by client
        validated_data.pop('notes', None)  # Ensure created_at is not set by client
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)
    
    def get_documents(self, obj):
        docs_qs = Document.objects.filter(tramite=obj)
        return [{"id":d.id,"filename": d.filename} for d in docs_qs]


class DocumentTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = DocumentType
        fields = '__all__'