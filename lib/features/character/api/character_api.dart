import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'character_dto.dart';

class CharacterApi {
  static const String _getAllCharactersEndpoint = '/api/characters';

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

  /// Lấy nhân vật theo độ hiếm
  static Future<ApiResponse<List<CharacterDto>>> getCharactersByRarity(CharacterRarity rarity) async {
    try {
      return await ApiService.getList<CharacterDto>(
        '$_getAllCharactersEndpoint/rarity/${rarity.name.toUpperCase()}',
        fromJson: CharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy tất cả nhân vật bị khóa từ API
  static Future<ApiResponse<List<CharacterDto>>> getAllCharactersLocked() async {
    try {
      return await ApiService.getList<CharacterDto>(
        '$_getAllCharactersEndpoint/locked',
        fromJson: CharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }
}