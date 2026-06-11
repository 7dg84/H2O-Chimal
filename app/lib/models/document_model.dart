class TramiteDocumentModel {
  final String id;
  final String filename;

  TramiteDocumentModel({
    required this.id,
    required this.filename,
});

  factory TramiteDocumentModel.fromJson(Map<String, dynamic> json) {
    return TramiteDocumentModel(
      id: json['id'],
      filename: json['filename'],
    );
  }

}

class DocumentModel {
  final String id;
  final String? presignedUrl;
  final String storageKey;
  final String filename;
  final String mimeType;
  final int size;
  final DateTime uploadedAt;
  final String tramiteId;
  final String documentTypeId;

  DocumentModel({
    required this.id,
    required this.presignedUrl,
    required this.storageKey,
    required this.filename,
    required this.mimeType,
    required this.size,
    required this.uploadedAt,
    required this.tramiteId,
    required this.documentTypeId,
  });


  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      presignedUrl: json['presigned_url'],
      storageKey: json['storage_key'] ?? '',
      filename: json['filename'] ?? '',
      mimeType: json['mime_type'] ?? '',
      size: json['size'] ?? 0,
      uploadedAt: DateTime.parse(json['uploaded_at']),
      tramiteId: json['tramite'] ?? '',
      documentTypeId: json['document_type'] ?? '',
    );
  }
}
