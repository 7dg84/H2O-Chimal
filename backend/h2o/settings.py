import os
from pathlib import Path
from datetime import timedelta

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.environ.get('SECRET_KEY', 'replace-me')
DEBUG = os.environ.get(
    'DEBUG', '0') == '1' or os.environ.get('DEBUG') == 'True'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'localhost').split(',')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'rest_framework.authtoken',
    'storages',
    'api',
    'django_filters',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'h2o.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {'context_processors': ['django.template.context_processors.debug', 'django.template.context_processors.request', 'django.contrib.auth.context_processors.auth', 'django.contrib.messages.context_processors.messages']},
    },
]

WSGI_APPLICATION = 'h2o.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'h2o_db'),
        'USER': os.environ.get('DB_USER', 'h2o_user'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'h2o_pass'),
        'HOST': os.environ.get('DB_HOST', 'localhost'),
        'PORT': os.environ.get('DB_PORT', '5432'),
    }
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = 'es-mx'
TIME_ZONE = 'America/Mexico_City'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

AUTH_USER_MODEL = 'api.User'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'api.auth.CookieTokenAuthentication',
    ),
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 100,
    'MAX_PAGE_SIZE': 1000,
}

# SIMPLE_JWT left in settings if needed elsewhere, but primary auth uses token cookies
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=30),
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# Storage (S3-compatible Ceph)
DEFAULT_FILE_STORAGE = os.environ.get(
    'DEFAULT_FILE_STORAGE', 'storages.backends.s3boto3.S3Boto3Storage')
AWS_ACCESS_KEY_ID = os.environ.get('CEPH_ACCESS_KEY')
AWS_SECRET_ACCESS_KEY = os.environ.get('CEPH_SECRET_KEY')
AWS_STORAGE_BUCKET_NAME = os.environ.get('CEPH_BUCKET')
AWS_S3_ENDPOINT_URL = os.environ.get('CEPH_ENDPOINT')
AWS_S3_REGION_NAME = os.environ.get('CEPH_REGION', '')
AWS_S3_SIGNATURE_VERSION = 's3v4'
AWS_S3_ADDRESSING_STYLE = 'path'
# Public endpoint used to sign presigned URLs (can differ from internal endpoint)
CEPH_PUBLIC_ENDPOINT = os.environ.get(
    'CEPH_PUBLIC_ENDPOINT', AWS_S3_ENDPOINT_URL)
