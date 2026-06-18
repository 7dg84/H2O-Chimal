import django_filters
from .models import Report, Service, Media, Tramite, Document, ServiceRequirement, AuditLog, Review
from django.contrib.auth import get_user_model

class ServiceFilter(django_filters.FilterSet):
    class Meta:
        model = Service
        fields = {
            'name': ['icontains'],
            'description': ['icontains'],
        }


class ReportFilter(django_filters.FilterSet):
    class Meta:
        model = Report
        fields = {
            'status': ['exact'],
            'report_type': ['exact'],
            'reported_at': ['exact', 'gte', 'lte', 'range', 'month__gte'],
            'id': ['icontains'],
            'folio': ['exact', 'gte', 'lte', 'range'],
            'latitude': ['exact', 'gte', 'lte', 'range'],
            'longitude': ['exact', 'gte', 'lte', 'range'],
            'assigned_operator_id': ['exact'],
        }


class MediaFilter(django_filters.FilterSet):
    class Meta:
        model = Media
        fields = {
            'report__id': ['exact'],
            'storage_key': ['icontains'],
            'filename': ['icontains'],
            'mime_type': ['icontains'],
        }


class TramiteFilter(django_filters.FilterSet):
    class Meta:
        model = Tramite
        fields = {
            'user__curp': ['icontains'],
            'service': ['exact'],
            'folio': ['exact', 'gte', 'lte', 'range'],
            'created_at': ['exact', 'gte', 'lte', 'range'],
            'status': ['exact'],
        }


class DocumentFilter(django_filters.FilterSet):
    class Meta:
        model = Document
        fields = {
            'user__curp': ['icontains'],
            'tramite__folio': ['exact', 'gte', 'lte', 'range'],
            'document_type': ['exact'],
            'document_type__name': ['icontains'],
            'filename': ['icontains'],
            'mime_type': ['icontains'],
        }


class ServiceRequirementFilter(django_filters.FilterSet):
    class Meta:
        model = ServiceRequirement
        fields = {'required': ['exact'],
                  'service': ['exact'],
                  'document_type': ['exact']}


class ReportCoordinateFilter(django_filters.FilterSet):
    class Meta:
        model = Report
        fields = {
            'status': ['exact'],
            'latitude': ['exact', 'gte', 'lte', 'range'],
            'longitude': ['exact', 'gte', 'lte', 'range'],
        }


class AuditLogFilter(django_filters.FilterSet):
    class Meta:
        model = AuditLog
        fields = {
            'user__email': ['icontains'],
            'action': ['icontains'],
        }


class ReviewFilter(django_filters.FilterSet):
    class Meta:
        model = Review
        fields = {
            'id': ['exact'],
            'user': ['exact'],
            'user__curp': ['icontains'],
            'user__email': ['icontains'],
            'report': ['exact'],
            'tramite': ['exact'],
            'value': ['exact', 'gte', 'lte', 'range'],
            'created_at': ['exact', 'gte', 'lte', 'range'],
        }


class UserFilter(django_filters.FilterSet):
    class Meta:
        model = get_user_model()
        fields = {
            'id': ['exact'],
            'email': ['icontains'],
            'curp': ['icontains'],
            'name': ['icontains'],
            'phone': ['icontains'],
            'postal_code': ['icontains'],
            'colonia': ['icontains'],
            'street': ['icontains'],
            'block': ['icontains'],
            'exterior_number': ['icontains'],
            'role': ['icontains'],
        }
