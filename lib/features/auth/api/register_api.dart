// lib/data/providers/auth_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logi_neko/features/auth/dto/signup_request.dart';

import '../../../core/config/logger.dart';
class AuthApiService {
  final String _baseUrl = "http://10.0.2.2:8081/api";
  Future<Map<String, dynamic>> register({
    required SignUpRequest request,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    logger.i("🌍 POST $url");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    logger.i('Status: ${response.statusCode}');
    logger.i('Response: ${response.body}');


    if (response.statusCode == 200 || response.statusCode == 201) {

      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      logger.i('Status: ${response.statusCode}');
      final error = jsonDecode(response.body);
      throw Exception('Đăng ký thất bại: ${error['message'] ?? response.body}');
    }
  }
}