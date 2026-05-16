import '../models/tramite_model.dart';
import 'api_service.dart';

class TramiteService {
  final ApiService _apiService;

  TramiteService(this._apiService);

  Future<List<TramiteModel>> getTramites() async {
    try {
      final response = await _apiService.get('/tramites/');
      final List<dynamic> data = response.data;
      return data.map((json) => TramiteModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<TramiteModel> createTramite(String serviceId, Map<String, dynamic> documents) async {
    try {
      final response = await _apiService.post('/tramites/', data: {
        'service': serviceId,
        'documents': documents,
      });
      return TramiteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
