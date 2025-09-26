import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'character_dto.dart';

class CharacterApi {
  static const String _getAllCharactersEndpoint = '/api/account-characters';
  static const String _unlockCharacterEndpoint = '/api/account-characters/unlock';

  /// Lấy tất cả nhân vật từ API
  static Future<ApiResponse<List<CharacterDto>>> getAllCharacters() async {
    try {
      final response = await ApiService.get(_getAllCharactersEndpoint);
      
      if (response.isSuccess && response.data != null) {
        final List<dynamic> charactersJson = response.data as List<dynamic>;
        final List<CharacterDto> characters = charactersJson
            .map((json) => CharacterDto.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message,
          data: characters,
        );
      } else {
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message ?? 'Không thể tải danh sách nhân vật',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 500,
        code: 'CONNECTION_ERROR',
        message: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }

  /// Mở khóa nhân vật
  static Future<ApiResponse<Map<String, dynamic>>> unlockCharacter(int characterId) async {
    try {
      final response = await ApiService.post(
        _unlockCharacterEndpoint,
        data: {'characterId': characterId},
      );
      
      if (response.isSuccess) {
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message,
          data: response.data as Map<String, dynamic>? ?? {},
        );
      } else {
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message ?? 'Không thể mở khóa nhân vật',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 500,
        code: 'CONNECTION_ERROR',
        message: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }

  /// Kiểm tra nhân vật đã được mở khóa chưa
  static Future<ApiResponse<bool>> isCharacterUnlocked(int characterId) async {
    try {
      final response = await ApiService.get('$_getAllCharactersEndpoint/$characterId/unlock-status');
      
      if (response.isSuccess) {
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message,
          data: response.data['isUnlocked'] as bool? ?? false,
        );
      } else {
        return ApiResponse(
          status: response.status,
          code: response.code,
          message: response.message ?? 'Không thể kiểm tra trạng thái mở khóa',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: 500,
        code: 'CONNECTION_ERROR',
        message: 'Lỗi kết nối: ${e.toString()}',
      );
    }
  }
}