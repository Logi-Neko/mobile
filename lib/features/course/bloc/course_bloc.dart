import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/course_repository.dart';
import '../dto/course.dart';

abstract class CourseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {}

class LoadCourseById extends CourseEvent {
  final int id;
  LoadCourseById(this.id);

  @override
  List<Object?> get props => [id];
}

abstract class CourseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;
  CourseLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseDetailLoaded extends CourseState {
  final Course course;
  CourseDetailLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseOperationSuccess extends CourseState {
  final String message;
  CourseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CourseError extends CourseState {
  final String message;
  CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCourseById>(_onLoadCourseById);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final courses = await _courseRepository.getCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError('Failed to load courses: $e'));
    }
  }

  Future<void> _onLoadCourseById(LoadCourseById event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final course = await _courseRepository.getCourseById(event.id);
      emit(CourseDetailLoaded(course));
    } catch (e) {
      emit(CourseError('Failed to load course: $e'));
    }
  }

}