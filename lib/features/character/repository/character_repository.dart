import 'package:logi_neko/core/exception/exceptions.dart';
import '../api/character_api.dart';
import '../api/character_dto.dart';

abstract class CharacterRepository {
  Future<List<CharacterDto>> getAllCharacters();
  Future<CharacterDto> getCharacterById(int id);
}

class CharacterRepositoryImpl implements CharacterRepository {
  @override
  Future<List<CharacterDto>> getAllCharacters() async {
    final response = await CharacterApi.getAllCharacters();

    if (response.isSuccess && response.hasData) {
      // Lọc chỉ lấy những nhân vật đang hoạt động
      return response.data!.where((character) => character.isActive).toList();
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải danh sách nhân vật',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_CHARACTERS_ERROR',
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
}