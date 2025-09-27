import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'account_character_dto.dart';

class CharacterAccountApi {
  static const String _baseEndpoint = '/api/account-characters';

  /// Tạo nhân vật cho tài khoản
  /// POST /api/account-characters/unlocked
  static Future<ApiResponse<AccountCharacterDto>> createAccountCharacter(
      AccountCharacterCreateDto createDto) async {
    try {
      return await ApiService.postObject<AccountCharacterDto>(
        '$_baseEndpoint/unlocked',
        data: createDto.toJson(),
        fromJson: AccountCharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy thông tin nhân vật của tài khoản theo ID
  /// GET /api/account-characters/{id}
  static Future<ApiResponse<AccountCharacterDto>> getAccountCharacterById(int id) async {
    try {
      return await ApiService.getObject<AccountCharacterDto>(
        '$_baseEndpoint/$id',
        fromJson: AccountCharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy tất cả nhân vật của tài khoản
  /// GET /api/account-characters
  static Future<ApiResponse<List<AccountCharacterDto>>> getAllAccountCharacters() async {
    try {
      return await ApiService.getList<AccountCharacterDto>(
        '$_baseEndpoint/unlocked/all',
        fromJson: AccountCharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<ApiResponse<List<AccountCharacterDto>>> getAllAccountFavoriteCharacters() async {
    try {
      return await ApiService.getList<AccountCharacterDto>(
        '$_baseEndpoint/favorites',
        fromJson: AccountCharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Chọn nhân vật làm nhân vật chính
  /// POST /api/account-characters/{accountCharacterId}/choose
  static Future<ApiResponse<void>> chooseCharacter(int accountCharacterId) async {
    try {
      return await ApiService.postObject<void>(
        '$_baseEndpoint/$accountCharacterId/choose',
        fromJson: (json) => null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Đặt trạng thái yêu thích cho nhân vật
  /// PATCH /api/account-characters/character/{id}/favorite
  static Future<ApiResponse<AccountCharacterDto>> setFavoriteCharacter(int characterId, bool isFavorite) async {
    try {
      return await ApiService.putObject<AccountCharacterDto>(
        '$_baseEndpoint/character/$characterId/favorite?isFavorite=$isFavorite',
        fromJson: AccountCharacterDto.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }
}