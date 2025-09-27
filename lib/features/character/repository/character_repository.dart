import 'package:logi_neko/core/exception/exceptions.dart';
import '../api/character_api.dart';
import '../api/character_dto.dart';

abstract class CharacterRepository {
  Future<List<CharacterDto>> getAllCharactersLocked();
  Future<CharacterDto> getCharacterById(int id);
  Future<List<CharacterDto>> getCharactersByRarity(CharacterRarity rarity);
}

class CharacterRepositoryImpl implements CharacterRepository {
  @override
  Future<List<CharacterDto>> getAllCharactersLocked() async {
    final response = await CharacterApi.getAllCharactersLocked();

    if (response.isSuccess && response.hasData) {
      // Trả về tất cả nhân vật bị khóa
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải danh sách nhân vật bị khóa',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_LOCKED_CHARACTERS_ERROR',
    );
  }

  @override
  Future<CharacterDto> getCharacterById(int id) async {
    final response = await CharacterApi.getCharacterById(id);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải thông tin nhân vật',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_CHARACTER_ERROR',
      details: 'Character ID: $id',
    );
  }

  @override
  Future<List<CharacterDto>> getCharactersByRarity(CharacterRarity rarity) async {
    final response = await CharacterApi.getCharactersByRarity(rarity);

    if (response.isSuccess && response.hasData) {
      // Lọc chỉ lấy những nhân vật đang hoạt động
      return response.data!.where((character) => character.isActive).toList();
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải danh sách nhân vật theo độ hiếm',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_CHARACTERS_BY_RARITY_ERROR',
      details: 'Rarity: ${rarity.name}',
    );
  }
}