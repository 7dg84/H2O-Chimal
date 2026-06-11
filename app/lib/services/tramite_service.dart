import 'dart:io';
import 'package:dio/dio.dart';
import '../models/tramite_model.dart';
import 'api_service.dart';

class TramiteService {
  final ApiService _apiService;

  TramiteService(this._apiService);

  Future<List<TramiteModel>> getTramites() async {
    try {
      final response = await _apiService.get('/tramites/');
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => TramiteModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TramiteModel> createTramite(String serviceId) async {
    try {
      final response = await _apiService.post('/tramites/', data: {
        'service': serviceId,
      });
      return TramiteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadDocument(String tramiteId, String documentTypeId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'tramite': tramiteId,
        'document_type': documentTypeId,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      await _apiService.post('/documents/', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
