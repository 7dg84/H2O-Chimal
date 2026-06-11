import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<UserModel> login(String email, String password) async {
    // 1. Intentar login
    final response = await _apiService.post('/auth/login/', data: {
      'email': email,
      'password': password,
    });

    if (response.data['succes'] == 'ok' || response.statusCode == 200) {
      // 2. Si el login es exitoso, obtenemos los datos del usuario (la cookie ya está guardada)
      return await getCurrentUser() ?? (throw Exception("No se pudo obtener el perfil"));
    } else {
      throw Exception("Credenciales inválidas");
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

  // El registro devuelve id y email, podemos usar eso para crear un UserModel parcial o llamar a user/
  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await _apiService.post('/auth/register/', data: data);
    if (response.statusCode == 201) {
      return await getCurrentUser() ?? UserModel.fromJson(response.data);
    }
    throw Exception("Error en el registro");
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout/');
  }

  Future<void> updateInfo(Map<String, dynamic> data) async {
    try {
      await _apiService.put('/auth/update_info/', data: data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw e.response!.data; // Devolvemos el mapa de errores
      }
      rethrow;
    }
  }
}