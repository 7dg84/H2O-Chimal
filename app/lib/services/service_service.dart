import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService _apiService;

  ServiceService(this._apiService);

  Future<List<ServiceModel>> getServices({String? search}) async {
    try {
      final response = await _apiService.get('/services/', queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      });
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> getServiceDetail(String id) async {
    try {
      final response = await _apiService.get('/services/$id/');
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
