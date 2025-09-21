// lib/data/repositories/auth_repository.dart

import '../api/register_api.dart';
import '../dto/signup_request.dart';

class AuthRepository {
  final AuthApiService _apiService;

  AuthRepository({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  // Chỉ nhận 1 tham số
  Future<Map<String, dynamic>> register({required SignUpRequest request}) async {
    try {
      final response = await _apiService.register(request: request);
      return response; // 👈 trả dữ liệu về
    } catch (e) {
      rethrow;
    }
  }
}