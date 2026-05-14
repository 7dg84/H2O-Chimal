from django.db.models.signals import post_migrate
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from django.dispatch import receiver


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
