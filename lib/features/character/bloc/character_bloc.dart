import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import '../repository/character_repository.dart';
import '../api/character_dto.dart';

// Events
abstract class CharacterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllCharacters extends CharacterEvent {}

class LoadCharacterById extends CharacterEvent {
  final int id;
  
  LoadCharacterById(this.id);
  
  @override
  List<Object?> get props => [id];
}

class RefreshCharacters extends CharacterEvent {}

// States
abstract class CharacterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharactersLoaded extends CharacterState {
  final List<CharacterDto> characters;
  
  CharactersLoaded(this.characters);
  
  @override
  List<Object?> get props => [characters];
}

class CharacterDetailLoaded extends CharacterState {
  final CharacterDto character;
  
  CharacterDetailLoaded(this.character);
  
  @override
  List<Object?> get props => [character];
}

class CharacterError extends CharacterState {
  final String message;
  final String? errorCode;
  
  CharacterError(this.message, {this.errorCode});
  
  @override
  List<Object?> get props => [message, errorCode];
}

// BLoC
class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository _characterRepository;
  
  CharacterBloc(this._characterRepository) : super(CharacterInitial()) {
    on<LoadAllCharacters>(_onLoadAllCharacters);
    on<LoadCharacterById>(_onLoadCharacterById);
    on<RefreshCharacters>(_onRefreshCharacters);
  }
  
  Future<void> _onLoadAllCharacters(LoadAllCharacters event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      final characters = await _characterRepository.getAllCharacters();
      emit(CharactersLoaded(characters));
    } on NotFoundException catch (e) {
      emit(CharacterError('Không tìm thấy nhân vật nào', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterError('Có lỗi không xác định xảy ra khi tải danh sách nhân vật'));
    }
  }
  
  Future<void> _onLoadCharacterById(LoadCharacterById event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      final character = await _characterRepository.getCharacterById(event.id);
      emit(CharacterDetailLoaded(character));
    } on NotFoundException catch (e) {
      emit(CharacterError('Không tìm thấy nhân vật', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterError('Có lỗi không xác định xảy ra khi tải thông tin nhân vật'));
    }
  }
  
  Future<void> _onRefreshCharacters(RefreshCharacters event, Emitter<CharacterState> emit) async {
    // Không emit loading state để tránh làm gián đoạn UI
    try {
      final characters = await _characterRepository.getAllCharacters();
      emit(CharactersLoaded(characters));
    } on NotFoundException catch (e) {
      emit(CharacterError('Không tìm thấy nhân vật nào', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterError('Có lỗi không xác định xảy ra khi làm mới danh sách nhân vật'));
    }
  }
}