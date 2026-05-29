from storages.backends.s3boto3 import S3Boto3Storage
import os

class MediaStorage(S3Boto3Storage):
    bucket_name = os.environ.get('CEPH_BUCKET_MEDIA')  # o AWS_MEDIA_BUCKET_NAME
    default_acl = 'private'
    file_overwrite = False
    
    
class DocumentStorage(S3Boto3Storage):
    bucket_name = os.environ.get('CEPH_BUCKET_DOCUMENTS')  # o AWS_REPORT_BUCKET_NAME
    default_acl = 'private'
    file_overwrite = False