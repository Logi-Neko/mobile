import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import '../repository/character_account_repository.dart';
import '../api/account_character_dto.dart';

// Events
abstract class CharacterAccountEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllAccountCharacters extends CharacterAccountEvent {}

class LoadAllAccountFavoriteCharacters extends CharacterAccountEvent {}

class LoadAccountCharacterById extends CharacterAccountEvent {
  final int id;
  
  LoadAccountCharacterById(this.id);
  
  @override
  List<Object?> get props => [id];
}

class CreateAccountCharacter extends CharacterAccountEvent {
  final AccountCharacterCreateDto createDto;
  
  CreateAccountCharacter(this.createDto);
  
  @override
  List<Object?> get props => [createDto];
}

class SetFavoriteCharacter extends CharacterAccountEvent {
  final int characterId;
  final bool isFavorite;
  
  SetFavoriteCharacter(this.characterId, this.isFavorite);
  
  @override
  List<Object?> get props => [characterId, isFavorite];
}

class ChooseCharacter extends CharacterAccountEvent {
  final int accountCharacterId;
  
  ChooseCharacter(this.accountCharacterId);
  
  @override
  List<Object?> get props => [accountCharacterId];
}

// States
abstract class CharacterAccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CharacterAccountInitial extends CharacterAccountState {}

class CharacterAccountLoading extends CharacterAccountState {}

class CharacterAccountOperationLoading extends CharacterAccountState {
  final String operation;
  
  CharacterAccountOperationLoading(this.operation);
  
  @override
  List<Object?> get props => [operation];
}

class AccountCharactersLoaded extends CharacterAccountState {
  final List<AccountCharacterDto> characters;
  
  AccountCharactersLoaded(this.characters);
  
  @override
  List<Object?> get props => [characters];
}

class AccountFavoriteCharactersLoaded extends CharacterAccountState {
  final List<AccountCharacterDto> characters;
  
  AccountFavoriteCharactersLoaded(this.characters);
  
  @override
  List<Object?> get props => [characters];
}

class AccountCharacterDetailLoaded extends CharacterAccountState {
  final AccountCharacterDto character;
  
  AccountCharacterDetailLoaded(this.character);
  
  @override
  List<Object?> get props => [character];
}

class AccountCharacterCreated extends CharacterAccountState {
  final AccountCharacterDto character;
  
  AccountCharacterCreated(this.character);
  
  @override
  List<Object?> get props => [character];
}

class FavoriteCharacterUpdated extends CharacterAccountState {
  final AccountCharacterDto character;
  
  FavoriteCharacterUpdated(this.character);
  
  @override
  List<Object?> get props => [character];
}

class CharacterChosen extends CharacterAccountState {
  final int accountCharacterId;
  
  CharacterChosen(this.accountCharacterId);
  
  @override
  List<Object?> get props => [accountCharacterId];
}

class CharacterAccountError extends CharacterAccountState {
  final String message;
  final String? errorCode;
  
  CharacterAccountError(this.message, {this.errorCode});
  
  @override
  List<Object?> get props => [message, errorCode];
}

// BLoC
class CharacterAccountBloc extends Bloc<CharacterAccountEvent, CharacterAccountState> {
  final CharacterAccountRepository _characterAccountRepository;
  
  CharacterAccountBloc(this._characterAccountRepository) : super(CharacterAccountInitial()) {
    on<LoadAllAccountCharacters>(_onLoadAllAccountCharacters);
    on<LoadAllAccountFavoriteCharacters>(_onLoadAllAccountFavoriteCharacters);
    on<LoadAccountCharacterById>(_onLoadAccountCharacterById);
    on<CreateAccountCharacter>(_onCreateAccountCharacter);
    on<SetFavoriteCharacter>(_onSetFavoriteCharacter);
    on<ChooseCharacter>(_onChooseCharacter);
  }

  Future<void> _onLoadAllAccountCharacters(LoadAllAccountCharacters event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountLoading());
    try {
      final characters = await _characterAccountRepository.getAllAccountCharacters();
      emit(AccountCharactersLoaded(characters));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy nhân vật nào', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi tải danh sách nhân vật'));
    }
  }

  Future<void> _onLoadAllAccountFavoriteCharacters(LoadAllAccountFavoriteCharacters event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountLoading());
    try {
      final characters = await _characterAccountRepository.getAllAccountFavoriteCharacters();
      emit(AccountFavoriteCharactersLoaded(characters));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy nhân vật yêu thích nào', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi tải danh sách nhân vật yêu thích'));
    }
  }

  Future<void> _onLoadAccountCharacterById(LoadAccountCharacterById event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountLoading());
    try {
      final character = await _characterAccountRepository.getAccountCharacterById(event.id);
      emit(AccountCharacterDetailLoaded(character));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy nhân vật', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi tải thông tin nhân vật'));
    }
  }

  Future<void> _onCreateAccountCharacter(CreateAccountCharacter event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountOperationLoading('Đang tạo nhân vật...'));
    try {
      final character = await _characterAccountRepository.createAccountCharacter(event.createDto);
      emit(AccountCharacterCreated(character));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy thông tin cần thiết để tạo nhân vật', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi tạo nhân vật'));
    }
  }

  Future<void> _onSetFavoriteCharacter(SetFavoriteCharacter event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountOperationLoading('Đang cập nhật trạng thái yêu thích...'));
    try {
      final character = await _characterAccountRepository.setFavoriteCharacter(event.characterId, event.isFavorite);
      emit(FavoriteCharacterUpdated(character));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy nhân vật', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi cập nhật trạng thái yêu thích'));
    }
  }

  Future<void> _onChooseCharacter(ChooseCharacter event, Emitter<CharacterAccountState> emit) async {
    emit(CharacterAccountOperationLoading('Đang chọn nhân vật chính...'));
    try {
      await _characterAccountRepository.chooseCharacter(event.accountCharacterId);
      emit(CharacterChosen(event.accountCharacterId));
    } on NotFoundException catch (e) {
      emit(CharacterAccountError('Không tìm thấy nhân vật', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterAccountError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterAccountError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterAccountError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterAccountError('Có lỗi không xác định xảy ra khi chọn nhân vật chính'));
    }
  }
}