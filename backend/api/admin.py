from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin
from .models import User, Service, DocumentType, ServiceRequirement, Report, Document, Media, Tramite, AuditLog


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    model = User
    list_display = ('email','name','curp','role','is_staff','is_superuser')
    search_fields = ('email','name','curp')
    ordering = ('email',)
    fieldsets = (
        (None, {'fields': ('email','password')}),
        ('Personal', {'fields': ('name','curp','phone')}),
        ('Address', {'fields': ('postal_code','colonia','street','block','exterior_number')}),
        ('Permissions', {'fields': ('role','is_staff','is_superuser')}),
    )


admin.site.register(Service)
admin.site.register(DocumentType)
admin.site.register(ServiceRequirement)
admin.site.register(Report)
admin.site.register(Document)
admin.site.register(Media)
admin.site.register(Tramite)
admin.site.register(AuditLog)