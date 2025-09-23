import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import '../repository/lesson_repo.dart';
import '../dto/lesson.dart';

abstract class LessonEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLessonsByCourseId extends LessonEvent {
  final int courseId;
  LoadLessonsByCourseId(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadLessonById extends LessonEvent {
  final int id;
  LoadLessonById(this.id);

  @override
  List<Object?> get props => [id];
}

abstract class LessonState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonsLoaded extends LessonState {
  final List<Lesson> lessons;
  LessonsLoaded(this.lessons);

  @override
  List<Object?> get props => [lessons];
}

class LessonDetailLoaded extends LessonState {
  final Lesson lesson;
  LessonDetailLoaded(this.lesson);

  @override
  List<Object?> get props => [lesson];
}

class LessonError extends LessonState {
  final String message;
  final String? errorCode;

  LessonError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final LessonRepository _lessonRepository;

  LessonBloc(this._lessonRepository) : super(LessonInitial()) {
    on<LoadLessonsByCourseId>(_onLoadLessonsByCourseId);
    on<LoadLessonById>(_onLoadLessonById);
  }

  Future<void> _onLoadLessonsByCourseId(LoadLessonsByCourseId event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final lessons = await _lessonRepository.getLessonsByCourseId(event.courseId);

      emit(LessonsLoaded(lessons));
    } on NotFoundException catch (e) {
      emit(LessonError('Không tìm thấy bài học cho khóa học này', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(LessonError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(LessonError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(LessonError(errorMessage, errorCode: e.errorCode));
    } catch (e) {
      emit(LessonError('Có lỗi không xác định xảy ra khi tải danh sách bài học'));
    }
  }

  Future<void> _onLoadLessonById(LoadLessonById event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final lesson = await _lessonRepository.getLessonById(event.id);
      emit(LessonDetailLoaded(lesson));
    } on NotFoundException catch (e) {
      emit(LessonError('Không tìm thấy bài học này', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(LessonError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(LessonError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(LessonError(errorMessage, errorCode: e.errorCode));
    } catch (e) {
      emit(LessonError('Có lỗi không xác định xảy ra khi tải thông tin bài học'));
    }
  }
}