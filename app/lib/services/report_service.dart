import 'package:dio/dio.dart';
import '../models/report_model.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _apiService;

  ReportService(this._apiService);

  Future<List<ReportModel>> getReports() async {
    try {
      final response = await _apiService.get('/reports/');
      final List<dynamic> data = response.data;
      return data.map((json) => ReportModel.fromJson(json)).toList();
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
    MultipartFile? image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'location_text': locationText,
        'report_type': reportType,
        'description': description,
        if (image != null) 'image': image,
      });

      final response = await _apiService.post('/reports/', data: formData);
      return ReportModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelReport(String id) async {
    try {
      await _apiService.delete('/reports/$id/');
    } catch (e) {
      rethrow;
    }
  }
}
