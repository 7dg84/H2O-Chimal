import 'dart:io';
import 'package:dio/dio.dart';
import '../models/report_model.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<List<ReportModel>> getRecentReports({int limit = 2}) async {
    try {
      final response = await _apiService.get('/reports/', queryParameters: {
        'limit': limit,
        'ordering': '-reported_at',
      });
      
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => ReportModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ReportModel> createReport({
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
  }) async {
    try {
      final response = await _apiService.post('/reports/', data: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_text': locationText,
        'report_type': reportType,
        'description': description,
      });

      return ReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadMedia(String reportId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'report': reportId,
        'file': await MultipartFile.fromFile(
            file.path,
            filename: fileName
        ),
      });

      await _apiService.post('/media/', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
