import '../models/tramite_model.dart';
import 'api_service.dart';

class TramiteService {
  final ApiService _apiService;

  TramiteService(this._apiService);

  Future<List<TramiteModel>> getTramites() async {
    try {
      final response = await _apiService.get('/tramites/');
      // Manejar respuesta paginada { "count": X, "results": [...] }
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
}
