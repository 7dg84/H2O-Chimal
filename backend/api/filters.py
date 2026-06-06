import django_filters
from .models import Report, Service

class ReportFilter(django_filters.FilterSet):
    class Meta:
        model = Report
        fields = {
            'status': ['exact'],
            'report_type': ['exact'],
            'reported_at': ['exact', 'gte', 'lte', 'range'],
            'id': ['exact'],
        }
        
class ServiceFilter(django_filters.FilterSet):
    class Meta:
        model = Service
        fields = {
            'name': ['icontains'],
            'description': ['icontains'],
        }
        search_fields = ['name', 'description']