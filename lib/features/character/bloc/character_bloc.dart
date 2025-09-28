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

class LoadAllCharactersLocked extends CharacterEvent {}

class LoadCharacterById extends CharacterEvent {
  final int id;
  
  LoadCharacterById(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadCharactersByRarity extends CharacterEvent {
  final CharacterRarity rarity;
  
  LoadCharactersByRarity(this.rarity);
  
  @override
  List<Object?> get props => [rarity];
}

// States
abstract class CharacterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharactersLockedLoaded extends CharacterState {
  final List<CharacterDto> characters;
  
  CharactersLockedLoaded(this.characters);
  
  @override
  List<Object?> get props => [characters];
}

class CharactersByRarityLoaded extends CharacterState {
  final List<CharacterDto> characters;
  final CharacterRarity rarity;
  
  CharactersByRarityLoaded(this.characters, this.rarity);
  
  @override
  List<Object?> get props => [characters, rarity];
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
    on<LoadAllCharactersLocked>(_onLoadAllCharactersLocked);
    on<LoadCharacterById>(_onLoadCharacterById);
    on<LoadCharactersByRarity>(_onLoadCharactersByRarity);
  }
  
  Future<void> _onLoadAllCharactersLocked(LoadAllCharactersLocked event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      final characters = await _characterRepository.getAllCharactersLocked();
      emit(CharactersLockedLoaded(characters));
    } on NotFoundException catch (e) {
      emit(CharacterError('Không tìm thấy nhân vật bị khóa nào', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterError('Có lỗi không xác định xảy ra khi tải danh sách nhân vật bị khóa'));
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
  
  Future<void> _onLoadCharactersByRarity(LoadCharactersByRarity event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      final characters = await _characterRepository.getCharactersByRarity(event.rarity);
      emit(CharactersByRarityLoaded(characters, event.rarity));
    } on NotFoundException catch (e) {
      emit(CharacterError('Không tìm thấy nhân vật nào với độ hiếm ${event.rarity.name}', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CharacterError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CharacterError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      emit(CharacterError(e.message, errorCode: e.errorCode));
    } catch (e) {
      emit(CharacterError('Có lỗi không xác định xảy ra khi tải danh sách nhân vật theo độ hiếm'));
    }
  }
}