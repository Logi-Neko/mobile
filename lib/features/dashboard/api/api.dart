
import 'package:intl/intl.dart';
import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/dashboard/dto/report.dart';

class ReportApi {
  static const String _statisticsEndpoint = '/statistics';

  static Future<ApiResponse<ReportData>> getStatistics({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromString = DateFormat('yyyy-MM-dd').format(from);
    final toString = DateFormat('yyyy-MM-dd').format(to);

    return await ApiService.getObject<ReportData>(
      '$_statisticsEndpoint/$accountId',
      queryParameters: {
        'from': fromString,
        'to': toString,
      },
      fromJson: (json) => ReportData.fromJson(json),
    );
  }

  static Future<ApiResponse<ReportData>> getTodayStatistics({
    required int accountId,
  }) async {
    final today = DateTime.now();
    return getStatistics(
      accountId: accountId,
      from: today,
      to: today,
    );
  }

  static Future<ApiResponse<ReportData>> getDateRangeStatistics({
    required int accountId,
    required DateTime from,
    required DateTime to,
  }) async {
    return getStatistics(
      accountId: accountId,
      from: from,
      to: to,
    );
  }

  static Future<ApiResponse<ReportData>> getWeeklyStatistics({
    required int accountId,
    DateTime? targetDate,
  }) async {
    final date = targetDate ?? DateTime.now();
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return getStatistics(
      accountId: accountId,
      from: startOfWeek,
      to: endOfWeek,
    );
  }

  static Future<ApiResponse<ReportData>> getMonthlyStatistics({
    required int accountId,
    DateTime? targetDate,
  }) async {
    final date = targetDate ?? DateTime.now();
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    return getStatistics(
      accountId: accountId,
      from: startOfMonth,
      to: endOfMonth,
    );
  }
}