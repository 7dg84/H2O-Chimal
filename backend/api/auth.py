from rest_framework.authentication import TokenAuthentication
from rest_framework import exceptions
from rest_framework.authtoken.models import Token


class CookieTokenAuthentication(TokenAuthentication):
    """
    Custom authentication that reads token from HTTPOnly cookie 'auth_token'.
    Falls back to Authorization header if cookie not found.
    """
    def authenticate(self, request):
        token = request.COOKIES.get('auth_token')

        if not token:
            return super().authenticate(request)

        return self.authenticate_credentials(token)

    def authenticate_credentials(self, key):
        try:
            token = Token.objects.select_related('user').get(key=key)
        except Token.DoesNotExist:
            raise exceptions.AuthenticationFailed('Invalid token.')

        if not token.user.is_active:
            raise exceptions.AuthenticationFailed('User inactive or deleted.')

        return (token.user, token)
