import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response.data['user'] ?? response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String curp,
    required String name,
    required String phone,
    required String postalCode,
    required String colonia,
    required String street,
    String? block,
    String? exteriorNumber,
  }) async {
    try {
      final response = await _apiService.post('/auth/register/', data: {
        'email': email,
        'password': password,
        'curp': curp,
        'name': name,
        'phone': phone,
        'postal_code': postalCode,
        'colonia': colonia,
        'street': street,
        'block': block,
        'exterior_number': exteriorNumber,
      });
      print(response.data);
      return UserModel.fromJson(response.data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout/');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/user/');
      return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
