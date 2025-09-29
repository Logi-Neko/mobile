import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/features/course/dto/course.dart';
import 'package:logi_neko/features/dashboard/dto/report.dart';
import 'package:logi_neko/features/dashboard/repository/report_repo.dart';
import 'package:logi_neko/features/lesson/dto/lesson.dart';
import '../../../core/config/logger.dart';
import '../../../core/exception/exceptions.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayReport extends ReportEvent {
  final int accountId;

  const LoadTodayReport({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class LoadDateReport extends ReportEvent {
  final int accountId;
  final DateTime date;

  const LoadDateReport({
    required this.accountId,
    required this.date,
  });

  @override
  List<Object?> get props => [accountId, date];
}

class LoadDateRangeReport extends ReportEvent {
  final int accountId;
  final DateTime from;
  final DateTime to;

  const LoadDateRangeReport({
    required this.accountId,
    required this.from,
    required this.to,
  });

  @override
  List<Object?> get props => [accountId, from, to];
}

class LoadWeeklyReport extends ReportEvent {
  final int accountId;
  final DateTime? targetDate;

  const LoadWeeklyReport({
    required this.accountId,
    this.targetDate,
  });

  @override
  List<Object?> get props => [accountId, targetDate];
}

class LoadMonthlyReport extends ReportEvent {
  final int accountId;
  final DateTime? targetDate;

  const LoadMonthlyReport({
    required this.accountId,
    this.targetDate,
  });

  @override
  List<Object?> get props => [accountId, targetDate];
}

class RefreshReport extends ReportEvent {
  const RefreshReport();
}

// States
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final ReportData reportData;
  final int totalStudyTime;
  final double completionRate;
  final Map<Course, List<Lesson>> groupedLessons;

  const ReportLoaded({
    required this.reportData,
    required this.totalStudyTime,
    required this.completionRate,
    required this.groupedLessons,
  });

  @override
  List<Object?> get props => [
    reportData,
    totalStudyTime,
    completionRate,
    groupedLessons,
  ];
}

class ReportError extends ReportState {
  final String message;
  final String? details;
  final AppException? exception;

  const ReportError({
    required this.message,
    this.details,
    this.exception,
  });

  @override
  List<Object?> get props => [message, details, exception];

  bool get isNetworkError => exception is NetworkException;
  bool get isServerError => exception is ServerException;
  bool get isValidationError => exception is ValidationException;
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc({ReportRepository? repository})
      : _repository = repository ?? ReportRepository(),
        super(const ReportInitial()) {

    on<LoadTodayReport>(_onLoadTodayReport);
    on<LoadDateReport>(_onLoadDateReport);
    on<LoadDateRangeReport>(_onLoadDateRangeReport);
    on<LoadWeeklyReport>(_onLoadWeeklyReport);
    on<LoadMonthlyReport>(_onLoadMonthlyReport);
    on<RefreshReport>(_onRefreshReport);
  }

  Future<void> _onLoadTodayReport(
      LoadTodayReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(const ReportLoading());

    try {
      logger.i('Loading today report for account: ${event.accountId}');
      final reportData = await _repository.getTodayReport(
        accountId: event.accountId,
      );

      final totalStudyTime = _repository.calculateTotalStudyTime(reportData);
      final completionRate = _repository.calculateCompletionRate(reportData);
      final groupedLessons = _repository.groupLessonsByCourse(reportData);

      logger.i('Successfully loaded today report');
      emit(ReportLoaded(
        reportData: reportData,
        totalStudyTime: totalStudyTime,
        completionRate: completionRate,
        groupedLessons: groupedLessons,
      ));
    } on AppException catch (e) {
      logger.e('AppException while loading today report: ${e.message}');
      emit(ReportError(
        message: e.message,
        details: e.details,
        exception: e,
      ));
    } catch (e) {
      logger.e('Unexpected error while loading today report: $e');
      emit(const ReportError(
        message: 'Đã xảy ra lỗi không mong muốn',
        details: 'Vui lòng thử lại sau',
      ));
    }
  }

  Future<void> _onLoadDateReport(
      LoadDateReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(const ReportLoading());

    try {
      logger.i('Loading date report for ${event.date} and account: ${event.accountId}');
      final reportData = await _repository.getDateReport(
        accountId: event.accountId,
        date: event.date,
      );

      final totalStudyTime = _repository.calculateTotalStudyTime(reportData);
      final completionRate = _repository.calculateCompletionRate(reportData);
      final groupedLessons = _repository.groupLessonsByCourse(reportData);

      logger.i('Successfully loaded date report');
      emit(ReportLoaded(
        reportData: reportData,
        totalStudyTime: totalStudyTime,
        completionRate: completionRate,
        groupedLessons: groupedLessons,
      ));
    } on AppException catch (e) {
      logger.e('AppException while loading date report: ${e.message}');
      emit(ReportError(
        message: e.message,
        details: e.details,
        exception: e,
      ));
    } catch (e) {
      logger.e('Unexpected error while loading date report: $e');
      emit(const ReportError(
        message: 'Đã xảy ra lỗi không mong muốn',
        details: 'Vui lòng thử lại sau',
      ));
    }
  }

  Future<void> _onLoadDateRangeReport(
      LoadDateRangeReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(const ReportLoading());

    try {
      logger.i('Loading date range report from ${event.from} to ${event.to} for account: ${event.accountId}');
      final reportData = await _repository.getDateRangeReport(
        accountId: event.accountId,
        from: event.from,
        to: event.to,
      );

      final totalStudyTime = _repository.calculateTotalStudyTime(reportData);
      final completionRate = _repository.calculateCompletionRate(reportData);
      final groupedLessons = _repository.groupLessonsByCourse(reportData);

      logger.i('Successfully loaded date range report');
      emit(ReportLoaded(
        reportData: reportData,
        totalStudyTime: totalStudyTime,
        completionRate: completionRate,
        groupedLessons: groupedLessons,
      ));
    } on AppException catch (e) {
      logger.e('AppException while loading date range report: ${e.message}');
      emit(ReportError(
        message: e.message,
        details: e.details,
        exception: e,
      ));
    } catch (e) {
      logger.e('Unexpected error while loading date range report: $e');
      emit(const ReportError(
        message: 'Đã xảy ra lỗi không mong muốn',
        details: 'Vui lòng thử lại sau',
      ));
    }
  }

  Future<void> _onLoadWeeklyReport(
      LoadWeeklyReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(const ReportLoading());

    try {
      logger.i('Loading weekly report for account: ${event.accountId}');
      final reportData = await _repository.getWeeklyReport(
        accountId: event.accountId,
        targetDate: event.targetDate,
      );

      final totalStudyTime = _repository.calculateTotalStudyTime(reportData);
      final completionRate = _repository.calculateCompletionRate(reportData);
      final groupedLessons = _repository.groupLessonsByCourse(reportData);

      logger.i('Successfully loaded weekly report');
      emit(ReportLoaded(
        reportData: reportData,
        totalStudyTime: totalStudyTime,
        completionRate: completionRate,
        groupedLessons: groupedLessons,
      ));
    } on AppException catch (e) {
      logger.e('AppException while loading weekly report: ${e.message}');
      emit(ReportError(
        message: e.message,
        details: e.details,
        exception: e,
      ));
    } catch (e) {
      logger.e('Unexpected error while loading weekly report: $e');
      emit(const ReportError(
        message: 'Đã xảy ra lỗi không mong muốn',
        details: 'Vui lòng thử lại sau',
      ));
    }
  }

  Future<void> _onLoadMonthlyReport(
      LoadMonthlyReport event,
      Emitter<ReportState> emit,
      ) async {
    emit(const ReportLoading());

    try {
      logger.i('Loading monthly report for account: ${event.accountId}');
      final reportData = await _repository.getMonthlyReport(
        accountId: event.accountId,
        targetDate: event.targetDate,
      );

      final totalStudyTime = _repository.calculateTotalStudyTime(reportData);
      final completionRate = _repository.calculateCompletionRate(reportData);
      final groupedLessons = _repository.groupLessonsByCourse(reportData);

      logger.i('Successfully loaded monthly report');
      emit(ReportLoaded(
        reportData: reportData,
        totalStudyTime: totalStudyTime,
        completionRate: completionRate,
        groupedLessons: groupedLessons,
      ));
    } on AppException catch (e) {
      logger.e('AppException while loading monthly report: ${e.message}');
      emit(ReportError(
        message: e.message,
        details: e.details,
        exception: e,
      ));
    } catch (e) {
      logger.e('Unexpected error while loading monthly report: $e');
      emit(const ReportError(
        message: 'Đã xảy ra lỗi không mong muốn',
        details: 'Vui lòng thử lại sau',
      ));
    }
  }

  Future<void> _onRefreshReport(
      RefreshReport event,
      Emitter<ReportState> emit,
      ) async {
    final currentState = state;
    if (currentState is ReportLoaded) {
      logger.i('Refreshing report data');
    }
  }
}