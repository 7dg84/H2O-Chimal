import 'package:flutter/material.dart';
import '../core/config.dart';
import '../models/document_model.dart';

enum TramiteStatus { creado, enTramite, completado }

class TramiteModel {
  final String id;
  final String folio;
  final String serviceName;
  final DateTime createdAt;
  final TramiteStatus status;
  final String? notes;
  final List<TramiteDocumentModel>? documents;

  TramiteModel({
    required this.id,
    required this.folio,
    required this.serviceName,
    required this.createdAt,
    required this.status,
    this.notes,
    this.documents,
  });

  factory TramiteModel.fromJson(Map<String, dynamic> json) {
    return TramiteModel(
      id: json['id'],
      folio: json['folio'].toString(),
      // El service puede venir como objeto o solo el ID dependiendo del endpoint, 
      // manejamos ambos casos si es posible o usamos un valor por defecto.
      serviceName: json['service_name'] ?? (json['service'] is Map ? json['service']['name'] : 'Servicio'),
      createdAt: DateTime.parse(json['created_at']),
      status: _parseStatus(json['status']),
      notes: json['notes'],
        documents: json['documents'] != null
            ? List<TramiteDocumentModel>.from(
            json['documents'].map((doc) => TramiteDocumentModel.fromJson(doc))
        )
            : null,
    );
  }

  static TramiteStatus _parseStatus(String? status) {
    switch (status) {
      case 'En tramite':
        return TramiteStatus.enTramite;
      case 'Completado':
        return TramiteStatus.completado;
      default:
        return TramiteStatus.creado;
    }
  }

  String get statusText {
    switch (status) {
      case TramiteStatus.enTramite: return 'En trámite';
      case TramiteStatus.completado: return 'Completado';
      default: return 'Creado';
    }
  }

  Color get statusColor {
    switch (status) {
      case TramiteStatus.enTramite: return AppConfig.statusInAttention;
      case TramiteStatus.completado: return AppConfig.statusResolved;
      default: return AppConfig.statusInReview;
    }
  }
}
