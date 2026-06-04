import 'dart:io';
import 'package:dio/dio.dart';
import '../models/report_model.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<ReportModel> createReport({
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
    File? imageFile, // Aceptamos el archivo de imagen
  }) async {
    try {
      // 1. Crear el reporte (datos de texto)
      final response = await _apiService.post('/reports/', data: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_text': locationText,
        'report_type': reportType,
        'description': description,
      });

      final report = ReportModel.fromJson(response.data);

      // 2. Si el usuario seleccionó una imagen, la subimos vinculada al reporte
      if (imageFile != null) {
        await _uploadMedia(report.id, imageFile);
      }

      return report;
    } catch (e) {
      rethrow;
    }
  }

  // Método privado para subir la multimedia al endpoint /api/media/
  Future<void> _uploadMedia(String reportId, File file) async {
    try {
      String fileName = file.path.split('/').last;

      // Creamos el FormData según lo que pide el curl de tu ejemplo
      FormData formData = FormData.fromMap({
        'report': reportId,
        'file': await MultipartFile.fromFile(
            file.path,
            filename: fileName
        ),
      });

      await _apiService.post('/media/', data: formData);
    } catch (e) {
      // Loggear el error de subida de imagen pero el reporte ya fue creado
      print("Error subiendo imagen: $e");
    }
  }
}