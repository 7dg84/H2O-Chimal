from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action, api_view, permission_classes, authentication_classes
from rest_framework.response import Response
from .models import Report, Document, Service, Tramite, AuditLog, Media
from .serializers import ReportSerializer, DocumentSerializer, ServiceSerializer, TramiteSerializer, RegisterSerializer, UserSerializer, MediaSerializer
from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token
from django.shortcuts import get_object_or_404
from django.core.files.storage import default_storage
from django.conf import settings
from .auth import CookieTokenAuthentication
from .permissions import IsOperator, IsAdmin, IsOperatorOrAdmin
from h2o.storage_backends import MediaStorage, DocumentStorage


class RegisterView(viewsets.GenericViewSet):
    serializer_class = RegisterSerializer

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        # create token
        token, _ = Token.objects.get_or_create(user=user)
        response = Response(
            {'id': user.id, 'email': user.email}, status=status.HTTP_201_CREATED)
        response.set_cookie(key='auth_token', value=token.key,
                            httponly=True, samesite='Lax', max_age=86400*30)
        return response


@api_view(['POST'])
@permission_classes([permissions.AllowAny])
def login(request):
    if 'email' not in request.data or 'password' not in request.data:
        return Response({'error': 'Email and password are required'}, status=status.HTTP_400_BAD_REQUEST)

    user = get_object_or_404(get_user_model(), email=request.data['email'])
    if not user.check_password(request.data['password']):
        return Response({'error': 'Invalid password'}, status=status.HTTP_401_UNAUTHORIZED)

    token, _ = Token.objects.get_or_create(user=user)
    response = Response({'succes': 'ok'}, status=status.HTTP_200_OK)
    response.set_cookie(key='auth_token', value=token.key,
                        httponly=True, samesite='Lax', max_age=86400*30)
    return response


@api_view(['POST'])
@authentication_classes([CookieTokenAuthentication])
@permission_classes([permissions.IsAuthenticated])
def logout(request):
    try:
        request.auth.delete()
    except Exception:
        pass
    response = Response({'message': 'Logout successful'},
                        status=status.HTTP_200_OK)
    response.delete_cookie(key='auth_token', samesite='Lax')
    return response


@api_view(['GET'])
@authentication_classes([CookieTokenAuthentication])
@permission_classes([permissions.IsAuthenticated])
def user_info(request):
    ser = UserSerializer(request.user)
    return Response(ser.data, status=status.HTTP_200_OK)


class ReportViewSet(viewsets.ModelViewSet):
    queryset = Report.objects.all().order_by('-reported_at')
    serializer_class = ReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        user = getattr(self.request, 'user', None)
        # citizens see only their own reports,
        if user and getattr(user, 'role', '') == 'citizen':
            qs = qs.filter(user=user)
        # operators see assigned to them by default
        if user and getattr(user, 'role', '') == 'operator':
            qs = qs.filter(assigned_operator_id=str(user.id))
        # filter param to show assigned_to_me explicitly
        if self.request.query_params.get('assigned_to_me') == 'true' and user:
            qs = qs.filter(assigned_operator_id=str(user.id))
        return qs

    @action(detail=True, methods=['post'], permission_classes=[IsOperatorOrAdmin])
    def assign(self, request, pk=None):
        report = self.get_object()
        operator_id = request.data.get('operator_id')
        if not operator_id:
            return Response({'error': 'operator_id required'}, status=status.HTTP_400_BAD_REQUEST)
        report.assigned_operator_id = operator_id
        report.status = 'En atención'
        report.save()
        AuditLog.objects.create(user=request.user, action='assign_report', target_type='report', target_id=str(
            report.id), metadata={'operator_id': operator_id})
        return Response({'status': 'assigned', 'report': ReportSerializer(report).data})

    @action(detail=True, methods=['post'], permission_classes=[IsOperatorOrAdmin])
    def change_status(self, request, pk=None):
        report = self.get_object()
        new_status = request.data.get('status')
        note = request.data.get('note')
        if not new_status:
            return Response({'error': 'status required'}, status=status.HTTP_400_BAD_REQUEST)
        report.status = new_status
        report.save()
        AuditLog.objects.create(user=request.user, action='change_status', target_type='report', target_id=str(
            report.id), metadata={'status': new_status, 'note': note})
        return Response({'status': 'ok', 'report': ReportSerializer(report).data})

    def destroy(self, request, *args, **kwargs):
        user = getattr(request, 'user', None)
        if user and getattr(user, 'role', '') != 'admin':
            if self.get_object().status != 'Recibido':
                return Response({'error': 'Only reports in "Recibido" status can be deleted'}, status=status.HTTP_400_BAD_REQUEST)
            else:
                # Delete also media
                media_qs = Media.objects.filter(report=self.get_object())
                for media in media_qs:
                    try:
                        MediaStorage().delete(media.storage_key)
                    except Exception:
                        return Response({'error': 'Failed to delete media from storage'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                    media.delete()
        return super().destroy(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        if self.get_object().status != 'Recibido':
            return Response({'error': 'Only reports in "Recibido" status can be updated'}, status=status.HTTP_400_BAD_REQUEST)
        return super().update(request, *args, **kwargs)


class MediaViewSet(viewsets.ModelViewSet):
    queryset = Media.objects.all().order_by('-uploaded_at')
    serializer_class = MediaSerializer
    permission_classes = [permissions.IsAuthenticated]
    storage = MediaStorage()

    def create(self, request, *args, **kwargs):
        # Accept file upload or storage_key
        file = request.FILES.get('file')
        data = request.data.copy()
        if file:
            # save using default storage (S3/Ceph)
            key = self.storage.save(file.name, file)
            data['storage_key'] = key
            data['filename'] = file.name
            data['mime_type'] = file.content_type
            data['size'] = file.size
        else:
            return Response({'error': 'File upload required'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        return Response({'error': 'Media updates are not allowed'}, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        # delete from storage
        try:
            if instance.storage_key:
                self.storage.delete(instance.storage_key)
        except Exception:
            return Response({'error': 'Failed to delete media from storage'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        instance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    def get_queryset(self):
        qs = super().get_queryset()
        user = getattr(self.request, 'user', None)
        if user and getattr(user, 'role', '') == 'citizen':
            qs = qs.filter(report__user=user)
            return qs
        elif user and getattr(user, 'role', '') in ['operator', 'admin']:
            return qs
        else:
            return None

    def list(self, request, *args, **kwargs):
        if getattr(request.user, 'role', '') == 'citizen':
            return Response({'error': 'Citizens cannot list media directly'}, status=status.HTTP_403_FORBIDDEN)
        elif getattr(request.user, 'role', '') in ['operator', 'admin']:
            return super().list(request, *args, **kwargs)
        else:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)


class DocumentViewSet(viewsets.ModelViewSet):
    queryset = Document.objects.all().order_by('-uploaded_at')
    serializer_class = DocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    storage = DocumentStorage()

    def create(self, request, *args, **kwargs):
        # Accept file upload or storage_key
        file = request.FILES.get('file')
        data = request.data.copy()
        if file:
            # save using default storage (S3/Ceph)
            key = self.storage.save(file.name, file)
            data['storage_key'] = key
            data['filename'] = file.name
            data['mime_type'] = file.content_type
            data['size'] = file.size
        else:
            return Response({'error': 'File upload required'}, status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def update(self, request, *args, **kwargs):
        return Response({"error": "Document updates are not allowed"}, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        # delete from storage
        try:
            if instance.storage_key:
                self.storage.delete(instance.storage_key)
        except Exception:
            return Response({'error': 'Failed to delete document from storage'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        instance.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

    def get_queryset(self):
        qs = super().get_queryset()
        user = getattr(self.request, 'user', None)
        if user and getattr(user, 'role', '') == 'citizen':
            qs = qs.filter(user=user)
            return qs
        elif user and (getattr(user, 'role', '') in ['operator', 'admin']):
            return qs
        else:
            return None

    def list(self, request, *args, **kwargs):
        if getattr(request.user, 'role', '') == 'citizen':
            return Response({'error': 'Citizens cannot list documents directly'}, status=status.HTTP_403_FORBIDDEN)
        elif getattr(request.user, 'role', '') in ['operator', 'admin']:
            return super().list(request, *args, **kwargs)
        else:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)


class ServiceViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Service.objects.all()
    serializer_class = ServiceSerializer
    permission_classes = [permissions.AllowAny]


class TramiteViewSet(viewsets.ModelViewSet):
    queryset = Tramite.objects.all().order_by('-created_at')
    serializer_class = TramiteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = super().get_queryset()
        user = getattr(self.request, 'user', None)
        # citizens see only their own reports,
        if user and getattr(user, 'role', '') == 'citizen':
            qs = qs.filter(user=user)
        # operators see assigned to them by default
        if user and getattr(user, 'role', '') == 'operator':
            qs = qs.all()
        return qs

    def get_permissions(self):
        """
        Instantiates and returns the list of permissions that this view requires.
        """
        if self.action in ['list', 'create', 'retrieve', 'destroy']:
            permission_classes = [permissions.IsAuthenticated]
        elif self.action in ['update', 'partial_update']:
            permission_classes = [IsOperatorOrAdmin]
        else:
            permission_classes = [IsOperatorOrAdmin]
        return [permission() for permission in permission_classes]

    def destroy(self, request, *args, **kwargs):
        user = getattr(request, 'user', None)
        if user and getattr(user, 'role', '') != 'admin':
            if self.get_object().status != 'Creado':
                return Response({'error': 'Only tramites in "Creado" status can be deleted'}, status=status.HTTP_400_BAD_REQUEST)
            elif self.get_object().status == 'Creado':
                # Delete also documents
                doc_qs = Document.objects.filter(tramite=self.get_object())
                for doc in doc_qs:
                    try:
                        DocumentStorage().delete(doc.storage_key)
                    except Exception:
                        return Response({'error': 'Failed to delete document from storage'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                    doc.delete()
        return super().destroy(request, *args, **kwargs)
