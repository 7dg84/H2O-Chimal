from rest_framework import serializers
from .models import User, Report, Document, Service, DocumentType, Tramite, Media
from django.contrib.auth import get_user_model
from django.conf import settings
from django.core.files.storage import default_storage
import re
from .models import ServiceRequirement
from h2o.storage_backends import MediaStorage


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
        return MediaSerializer(media_qs, many=True).data


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

    def get_presigned_url(self, obj):
        if not obj.storage_key:
            return None
        # Try to build presigned URL using boto3 via default storage
        try:
            storage = MediaStorage()
            # storage.bucket_name and connection.client should exist for S3Boto3Storage
            client = storage.connection.meta.client
            bucket = storage.bucket_name
            return client.generate_presigned_url('get_object', Params={'Bucket': bucket, 'Key': obj.storage_key}, ExpiresIn=3600)
        except Exception:
            return None

class DocumentSerializer(serializers.ModelSerializer):
    presigned_url = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Document
        fields = '__all__'

    def get_presigned_url(self, obj):
        if not obj.storage_key:
            return None
        # Try to build presigned URL using boto3 via default storage
        try:
            storage = default_storage
            # storage.bucket_name and connection.client should exist for S3Boto3Storage
            client = storage.connection.meta.client
            bucket = storage.bucket_name
            return client.generate_presigned_url('get_object', Params={'Bucket': bucket, 'Key': obj.storage_key}, ExpiresIn=3600)
        except Exception:
            return None


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
    class Meta:
        model = Tramite
        fields = '__all__'

    def create(self, validated_data):
        validated_data.pop('user', None)  # Ensure user is not set by client
        validated_data.pop('folio', None)  # Ensure folio is not set by client
        user = self.context['request'].user
        validated_data['user'] = user
        return super().create(validated_data)

