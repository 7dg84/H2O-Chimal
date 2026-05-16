import '../core/config.dart';
import 'package:flutter/material.dart';

enum ReportStatus { recibido, enRevision, enAtencion, resuelto, cerrado }

class ReportModel {
  final String id;
  final String folio;
  final DateTime reportedAt;
  final double latitude;
  final double longitude;
  final String locationText;
  final String reportType;
  final String description;
  final ReportStatus status;
  final String? assignedOperatorId;

  ReportModel({
    required this.id,
    required this.folio,
    required this.reportedAt,
    required this.latitude,
    required this.longitude,
    required this.locationText,
    required this.reportType,
    required this.description,
    required this.status,
    this.assignedOperatorId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      folio: json['folio'],
      reportedAt: DateTime.parse(json['reported_at'] ?? json['created_at']),
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      locationText: json['location_text'] ?? '',
      reportType: json['report_type'] ?? '',
      description: json['description'] ?? '',
      status: _parseStatus(json['status']),
      assignedOperatorId: json['assigned_operator_id'],
    );
  }

  static ReportStatus _parseStatus(String? status) {
    switch (status) {
      case 'En revisión':
        return ReportStatus.enRevision;
      case 'En atención':
        return ReportStatus.enAtencion;
      case 'Resuelto':
        return ReportStatus.resuelto;
      case 'Cerrado':
        return ReportStatus.cerrado;
      default:
        return ReportStatus.recibido;
    }
  }

  String get statusText {
    switch (status) {
      case ReportStatus.enRevision: return 'En revisión';
      case ReportStatus.enAtencion: return 'En atención';
      case ReportStatus.resuelto: return 'Resuelto';
      case ReportStatus.cerrado: return 'Cerrado';
      default: return 'Recibido';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReportStatus.enRevision: return AppConfig.statusInReview;
      case ReportStatus.enAtencion: return AppConfig.statusInAttention;
      case ReportStatus.resuelto: return AppConfig.statusResolved;
      case ReportStatus.cerrado: return AppConfig.statusClosed;
      default: return AppConfig.statusPending;
    }
  }
}
