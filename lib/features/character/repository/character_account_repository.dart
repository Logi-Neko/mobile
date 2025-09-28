import 'package:logi_neko/core/exception/exceptions.dart';
import '../api/character_account_api.dart';
import '../api/account_character_dto.dart';

abstract class CharacterAccountRepository {
  Future<List<AccountCharacterDto>> getAllAccountCharacters();
  Future<List<AccountCharacterDto>> getAllAccountFavoriteCharacters();
  Future<AccountCharacterDto> getAccountCharacterById(int id);
  Future<AccountCharacterDto> createAccountCharacter(AccountCharacterCreateDto createDto);
  Future<AccountCharacterDto> setFavoriteCharacter(int characterId, bool isFavorite);
  Future<void> chooseCharacter(int accountCharacterId);
}

class CharacterAccountRepositoryImpl implements CharacterAccountRepository {
  @override
  Future<List<AccountCharacterDto>> getAllAccountCharacters() async {
    final response = await CharacterAccountApi.getAllAccountCharacters();

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải danh sách nhân vật',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_ACCOUNT_CHARACTERS_ERROR',
    );
  }

  @override
  Future<List<AccountCharacterDto>> getAllAccountFavoriteCharacters() async {
    final response = await CharacterAccountApi.getAllAccountFavoriteCharacters();

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải danh sách nhân vật yêu thích',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_FAVORITE_CHARACTERS_ERROR',
    );
  }

  @override
  Future<AccountCharacterDto> getAccountCharacterById(int id) async {
    final response = await CharacterAccountApi.getAccountCharacterById(id);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tải thông tin nhân vật',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_ACCOUNT_CHARACTER_ERROR',
      details: 'Account Character ID: $id',
    );
  }

  @override
  Future<AccountCharacterDto> createAccountCharacter(AccountCharacterCreateDto createDto) async {
    final response = await CharacterAccountApi.createAccountCharacter(createDto);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể tạo nhân vật',
      statusCode: response.status,
      errorCode: response.code ?? 'CREATE_ACCOUNT_CHARACTER_ERROR',
    );
  }

  @override
  Future<AccountCharacterDto> setFavoriteCharacter(int characterId, bool isFavorite) async {
    final response = await CharacterAccountApi.setFavoriteCharacter(characterId, isFavorite);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Không thể cập nhật trạng thái yêu thích',
      statusCode: response.status,
      errorCode: response.code ?? 'SET_FAVORITE_CHARACTER_ERROR',
    );
  }

  @override
  Future<void> chooseCharacter(int accountCharacterId) async {
    final response = await CharacterAccountApi.chooseCharacter(accountCharacterId);

    if (!response.isSuccess) {
      throw BackendException(
        message: response.message ?? 'Không thể chọn nhân vật làm nhân vật chính',
        statusCode: response.status,
        errorCode: response.code ?? 'CHOOSE_CHARACTER_ERROR',
        details: 'Account Character ID: $accountCharacterId',
      );
    }
  }
}