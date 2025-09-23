import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
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
  final String? errorCode;
  CourseError(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
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
    } on AppException catch (e) {
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(CourseError(errorMessage, errorCode: e.errorCode));
    } catch (e) {
      emit(CourseError('Có lỗi không xác định xảy ra khi tải danh sách khóa học'));
    }
  }

  Future<void> _onLoadCourseById(LoadCourseById event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final course = await _courseRepository.getCourseById(event.id);
      emit(CourseDetailLoaded(course));
    } on NotFoundException catch (e) {
      emit(CourseError('Không tìm thấy khóa học này', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(CourseError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(CourseError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(CourseError(errorMessage, errorCode: e.errorCode));
    } catch (e) {
      emit(CourseError(
          'Có lỗi không xác định xảy ra khi tải thông tin khóa học'));
    }
  }
}