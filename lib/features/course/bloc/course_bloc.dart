import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/course_repository.dart';
import '../dto/course.dart';

abstract class CourseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {
  final bool forceRefresh;
  LoadCourses({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshCourses extends CourseEvent {}

class ClearCourseCache extends CourseEvent {}

abstract class CourseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Course> courses;
  final bool isFromCache;  // Để biết data từ cache hay mới

  CourseLoaded(this.courses, {this.isFromCache = false});

  @override
  List<Object?> get props => [courses, isFromCache];
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
    on<RefreshCourses>(_onRefreshCourses);
    on<ClearCourseCache>(_onClearCache);
  }

  // Load courses (dùng cache nếu có)
  Future<void> _onLoadCourses(
      LoadCourses event, Emitter<CourseState> emit) async {
    try {
      final courses = await _courseRepository.getCourses(
        forceRefresh: event.forceRefresh,
      );

      emit(CourseLoaded(courses, isFromCache: !event.forceRefresh));
    } catch (e) {
      emit(CourseError(
        'Có lỗi không xác định xảy ra khi tải danh sách khóa học',
        errorCode: _getErrorCode(e),
      ));
    }
  }

  // Refresh courses (luôn gọi API)
  Future<void> _onRefreshCourses(
      RefreshCourses event, Emitter<CourseState> emit) async {
    try {
      final courses = await _courseRepository.getCourses(forceRefresh: true);
      emit(CourseLoaded(courses, isFromCache: false));
    } catch (e) {
      emit(CourseError(
        'Không thể làm mới danh sách khóa học',
        errorCode: _getErrorCode(e),
      ));
    }
  }

  // Clear cache
  Future<void> _onClearCache(
      ClearCourseCache event, Emitter<CourseState> emit) async {
    try {
      if (_courseRepository is CourseRepositoryImpl) {
        await (_courseRepository as CourseRepositoryImpl).clearCache();
      }
      emit(CourseInitial());
    } catch (e) {
      emit(CourseError('Không thể xóa cache'));
    }
  }

  String _getErrorCode(dynamic error) {
    if (error.toString().contains('Network')) return 'NETWORK_ERROR';
    if (error.toString().contains('401')) return 'UNAUTHORIZED';
    if (error.toString().contains('timeout')) return 'TIMEOUT_ERROR';
    return 'UNKNOWN_ERROR';
  }
}