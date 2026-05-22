from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReportViewSet, DocumentViewSet, ServiceViewSet, TramiteViewSet, RegisterView, MediaViewSet, login, logout, user_info
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

router = DefaultRouter()
router.register(r'reports', ReportViewSet, basename='report')
router.register(r'media', MediaViewSet, basename='media')
router.register(r'documents', DocumentViewSet, basename='document')
router.register(r'services', ServiceViewSet, basename='service')
router.register(r'tramites', TramiteViewSet, basename='tramite')
router.register(r'auth', RegisterView, basename='auth')

urlpatterns = [
    path('', include(router.urls)),
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/login/', login, name='login'),
    path('auth/logout/', logout, name='logout'),
    path('auth/user/', user_info, name='user_info'),
]
