import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/course/dto/course.dart';
import 'package:logi_neko/features/lesson/dto/lesson.dart';
import '../../dto/report.dart';

class ReportHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final int totalStudyTimeMinutes;

  const ReportHeader({
    Key? key,
    this.onBackPressed,
    this.totalStudyTimeMinutes = 0,
  }) : super(key: key);

  String _formatTime(int seconds) {
    final totalMinutes = (seconds / 60).ceil(); // Làm tròn lên

    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    } else {
      final hours = totalMinutes ~/ 60;
      final remainingMinutes = totalMinutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTime(totalStudyTimeMinutes);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.router.push(const HomeRoute()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Báo cáo học tập',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Hãy xem con đã học được gì hôm nay',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.black38,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Colors.black87,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseReportCard extends StatelessWidget {
  final Course course;
  final List<Lesson> lessons;
  final int studyTimeMinutes;

  const CourseReportCard({
    Key? key,
    required this.course,
    required this.lessons,
    required this.studyTimeMinutes,
  }) : super(key: key);

  String _formatStudyTime(int seconds) {
    final totalMinutes = (seconds / 60).ceil(); // Làm tròn lên
    return '${totalMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: course.courseColor.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      course.courseColor,
                      course.courseColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Icon(course.courseIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InfoChip(
                          icon: Icons.access_time,
                          text: _formatStudyTime(studyTimeMinutes),
                          color: course.courseColor,
                        ),
                        const SizedBox(width: 8),
                        InfoChip(
                          icon: Icons.book_outlined,
                          text: '${lessons.length} bài',
                          color: course.courseColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (lessons.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...lessons.map(
                  (lesson) =>
                  LessonItem(lesson: lesson, courseColor: course.courseColor),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const InfoChip({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonItem extends StatelessWidget {
  final Lesson lesson;
  final Color courseColor;

  const LessonItem({Key? key, required this.lesson, required this.courseColor})
      : super(key: key);

  String _formatLessonDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes == 0) {
      return '${remainingSeconds}s';
    } else if (remainingSeconds == 0) {
      return '${minutes}m';
    } else {
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: courseColor.withOpacity(0.05),
        border: Border.all(color: courseColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Progress Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: courseColor.withOpacity(0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: lesson.progressPercentage / 100,
                    strokeWidth: 2.5,
                    backgroundColor: courseColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(courseColor),
                  ),
                ),
                Text(
                  '${lesson.progressPercentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: courseColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(lesson.updatedAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatLessonDuration(lesson.duration),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (lesson.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF10B981).withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Hoàn thành',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorState({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
            SizedBox(height: 24),
            Text(
              'Đang tải báo cáo...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateRangeSelector extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final VoidCallback onTap;

  const DateRangeSelector({
    Key? key,
    required this.fromDate,
    required this.toDate,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSameDay = DateUtils.isSameDay(fromDate, toDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: const Icon(
              Icons.date_range_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khoảng thời gian',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSameDay)
                  Text(
                    DateFormat('dd/MM/yyyy').format(fromDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_calculateDaysDifference(fromDate, toDate)} ngày',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFF3F4F6),
              ),
              child: const Icon(
                Icons.keyboard_arrow_right,
                color: Color(0xFF667EEA),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDaysDifference(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}

class QuickDateButtons extends StatelessWidget {
  final Function(DateTime from, DateTime to) onDateRangeSelected;
  final DateTime currentFromDate;
  final DateTime currentToDate;

  const QuickDateButtons({
    Key? key,
    required this.onDateRangeSelected,
    required this.currentFromDate,
    required this.currentToDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn nhanh',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 8,
            children: [
              _QuickDateButton(
                label: 'Hôm nay',
                isSelected: _isToday(currentFromDate, currentToDate),
                onTap: () {
                  final today = DateTime.now();
                  onDateRangeSelected(today, today);
                },
              ),
              _QuickDateButton(
                label: 'Hôm qua',
                isSelected: _isYesterday(currentFromDate, currentToDate),
                onTap: () {
                  final yesterday = DateTime.now().subtract(
                    const Duration(days: 1),
                  );
                  onDateRangeSelected(yesterday, yesterday);
                },
              ),
              _QuickDateButton(
                label: '7 ngày',
                isSelected: _isLastWeek(currentFromDate, currentToDate),
                onTap: () {
                  final today = DateTime.now();
                  final weekAgo = today.subtract(const Duration(days: 6));
                  onDateRangeSelected(weekAgo, today);
                },
              ),
              _QuickDateButton(
                label: 'Tháng này',
                isSelected: _isThisMonth(currentFromDate, currentToDate),
                onTap: () {
                  final now = DateTime.now();
                  final firstDayOfMonth = DateTime(now.year, now.month, 1);
                  final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
                  onDateRangeSelected(firstDayOfMonth, lastDayOfMonth);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime from, DateTime to) {
    final today = DateTime.now();
    return DateUtils.isSameDay(from, today) && DateUtils.isSameDay(to, today);
  }

  bool _isYesterday(DateTime from, DateTime to) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateUtils.isSameDay(from, yesterday) &&
        DateUtils.isSameDay(to, yesterday);
  }

  bool _isLastWeek(DateTime from, DateTime to) {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 6));
    return DateUtils.isSameDay(from, weekAgo) && DateUtils.isSameDay(to, today);
  }

  bool _isThisMonth(DateTime from, DateTime to) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateUtils.isSameDay(from, firstDayOfMonth) &&
        DateUtils.isSameDay(to, lastDayOfMonth);
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? const Color(0xFF667EEA) : const Color(0xFFF3F4F6),
          border:
          isSelected
              ? null
              : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}