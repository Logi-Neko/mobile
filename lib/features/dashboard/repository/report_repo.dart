import 'package:logi_neko/features/course/dto/course.dart';
import 'package:logi_neko/features/dashboard/api/api.dart';
import 'package:logi_neko/features/dashboard/dto/report.dart';
import 'package:logi_neko/features/lesson/dto/lesson.dart';

import '../../../core/config/logger.dart';
import '../../../core/exception/exceptions.dart';

class ReportRepository {
  static final ReportRepository _instance = ReportRepository._internal();
  factory ReportRepository() => _instance;
  ReportRepository._internal();

  Future<ReportData> getTodayReport({required int accountId}) async {
    try {
      logger.i('Fetching today report for account: $accountId');
      final response = await ReportApi.getTodayStatistics(accountId: accountId);

      if (response.isSuccess && response.data != null) {
        logger.i('Successfully fetched today report');
        return response.data!;
      } else {
        logger.w('Report API returned unsuccessful response: ${response.message}');
        throw ServerException(
          message: response.message ?? 'Failed to fetch report data',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching today report: $e');
      throw ServerException(
        message: 'Unable to fetch report data',
        details: e.toString(),
      );
    }
  }

  Future<ReportData> getDateReport({
    required int accountId,
    required DateTime date,
  }) async {
    try {
      logger.i('Fetching report for date: ${date.toIso8601String().split('T')[0]} for account: $accountId');
      final response = await ReportApi.getStatistics(
        accountId: accountId,
        from: date,
        to: date,
      );

      if (response.isSuccess && response.data != null) {
        logger.i('Successfully fetched date report');
        return response.data!;
      } else {
        logger.w('Report API returned unsuccessful response: ${response.message}');
        throw ServerException(
          message: response.message ?? 'Failed to fetch report data',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching date report: $e');
      throw ServerException(
        message: 'Unable to fetch report data',
        details: e.toString(),
      );
    }
  }

  Future<ReportData> getDateRangeReport({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      logger.i('Fetching report for date range: ${from.toIso8601String().split('T')[0]} to ${to.toIso8601String().split('T')[0]} for account: $accountId');

      if (from.isAfter(to)) {
        throw ValidationException(message: 'Start date cannot be after end date');
      }

      final response = await ReportApi.getDateRangeStatistics(
        accountId: accountId,
        from: from,
        to: to,
      );

      if (response.isSuccess && response.data != null) {
        logger.i('Successfully fetched date range report');
        return response.data!;
      } else {
        logger.w('Report API returned unsuccessful response: ${response.message}');
        throw ServerException(
          message: response.message ?? 'Failed to fetch report data',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching date range report: $e');
      throw ServerException(
        message: 'Unable to fetch report data',
        details: e.toString(),
      );
    }
  }

  Future<ReportData> getWeeklyReport({
    required int accountId,
    DateTime? targetDate,
  }) async {
    try {
      final date = targetDate ?? DateTime.now();
      logger.i('Fetching weekly report for week containing: ${date.toIso8601String().split('T')[0]} for account: $accountId');

      final response = await ReportApi.getWeeklyStatistics(
        accountId: accountId,
        targetDate: date,
      );

      if (response.isSuccess && response.data != null) {
        logger.i('Successfully fetched weekly report');
        return response.data!;
      } else {
        logger.w('Report API returned unsuccessful response: ${response.message}');
        throw ServerException(
          message: response.message ?? 'Failed to fetch weekly report',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching weekly report: $e');
      throw ServerException(
        message: 'Unable to fetch weekly report',
        details: e.toString(),
      );
    }
  }

  Future<ReportData> getMonthlyReport({
    required int accountId,
    DateTime? targetDate,
  }) async {
    try {
      final date = targetDate ?? DateTime.now();
      logger.i('Fetching monthly report for month: ${date.year}-${date.month} for account: $accountId');

      final response = await ReportApi.getMonthlyStatistics(
        accountId: accountId,
        targetDate: date,
      );

      if (response.isSuccess && response.data != null) {
        logger.i('Successfully fetched monthly report');
        return response.data!;
      } else {
        logger.w('Report API returned unsuccessful response: ${response.message}');
        throw ServerException(
          message: response.message ?? 'Failed to fetch monthly report',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      logger.e('Unexpected error fetching monthly report: $e');
      throw ServerException(
        message: 'Unable to fetch monthly report',
        details: e.toString(),
      );
    }
  }

  int calculateTotalStudyTime(ReportData reportData) {
    return reportData.lessons.fold(0, (total, lesson) => total + lesson.duration);
  }

  double calculateCompletionRate(ReportData reportData) {
    if (reportData.lessons.isEmpty) return 0.0;

    final completedCount = reportData.lessons.where((lesson) => lesson.isCompleted).length;
    return (completedCount / reportData.lessons.length) * 100.0;
  }

  Map<Course, List<Lesson>> groupLessonsByCourse(ReportData reportData) {
    final Map<Course, List<Lesson>> groupedLessons = {};

    for (final course in reportData.courses) {
      groupedLessons[course] = [];
    }

    if (reportData.courses.isNotEmpty) {
      for (int i = 0; i < reportData.lessons.length; i++) {
        final courseIndex = i % reportData.courses.length;
        final course = reportData.courses[courseIndex];
        groupedLessons[course]?.add(reportData.lessons[i]);
      }
    }

    return groupedLessons;
  }
}