import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'character_dto.dart';

class CharacterApi {
  static const String _getAllCharactersEndpoint = '/api/characters';

  /// Lấy tất cả nhân vật từ API
  static Future<ApiResponse<List<CharacterDto>>> getAllCharacters() async {
    try {
      return await ApiService.getList<CharacterDto>(
        _getAllCharactersEndpoint,
        fromJson: CharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy nhân vật theo ID
  static Future<ApiResponse<CharacterDto>> getCharacterById(int id) async {
    try {
      return await ApiService.getObject<CharacterDto>(
        '$_getAllCharactersEndpoint/$id',
        fromJson: CharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }
}