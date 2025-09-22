import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
  LessonError(this.message);

  @override
  List<Object?> get props => [message];
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
    } catch (e) {
      emit(LessonError('Failed to load lessons: $e'));
    }
  }

  Future<void> _onLoadLessonById(LoadLessonById event, Emitter<LessonState> emit) async {
    emit(LessonLoading());
    try {
      final lesson = await _lessonRepository.getLessonById(event.id);
      emit(LessonDetailLoaded(lesson));
    } catch (e) {
      emit(LessonError('Failed to load lesson: $e'));
    }
  }
}