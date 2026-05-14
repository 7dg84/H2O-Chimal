from django.apps import AppConfig

class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'api'
    def ready(self):
        # import signals to create groups and permissions on migrate
        try:
            import api.signals
        except Exception:
            pass
