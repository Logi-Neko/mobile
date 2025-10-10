import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/report_bloc.dart';
import '../../dto/report.dart';
import '../widgets/report_widget.dart';
import '../../repository/report_repo.dart';
import 'package:logi_neko/shared/color/app_color.dart';

@RoutePage()
class LearningReportPage extends StatelessWidget {
  final int? accountId;

  const LearningReportPage({
    Key? key,
    this.accountId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>(
      create: (context) => ReportBloc(repository: ReportRepository()),
      child: _LearningReportPageContent(accountId: accountId),
    );
  }
}

class _LearningReportPageContent extends StatefulWidget {
  final int? accountId;

  const _LearningReportPageContent({
    Key? key,
    this.accountId,
  }) : super(key: key);

  @override
  State<_LearningReportPageContent> createState() => _LearningReportPageContentState();
}

class _LearningReportPageContentState extends State<_LearningReportPageContent>
    with TickerProviderStateMixin {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late AnimationController _backgroundAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _fadeAnimation;

  int get accountId => widget.accountId ?? 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTodayReport();
  }

  void _initializeAnimations() {
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimationController.repeat(reverse: true);
    _fadeAnimationController.forward();
  }

  void _loadTodayReport() {
    final today = DateTime.now();
    setState(() {
      fromDate = today;
      toDate = today;
    });
    context.read<ReportBloc>().add(LoadDateRangeReport(
      accountId: accountId,
      from: fromDate,
      to: toDate,
    ));
  }

  void _loadDateRangeReport(DateTime from, DateTime to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    context.read<ReportBloc>().add(LoadDateRangeReport(
      accountId: accountId,
      from: from,
      to: to,
    ));
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const ReportHeader(),

                  Expanded(
                    child: BlocConsumer<ReportBloc, ReportState>(
                      listener: (context, state) {
                        if (state is ReportError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is ReportLoading) {
                          return const LoadingState();
                        } else if (state is ReportLoaded) {
                          return _buildLoadedContent(state);
                        } else if (state is ReportError) {
                          return ErrorState(
                            message: state.message,
                            details: state.details,
                            onRetry: () => _loadTodayReport(),
                          );
                        } else {
                          return const LoadingState();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80 + (30 * _backgroundAnimation.value),
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                top: 200 + (20 * (1 - _backgroundAnimation.value)),
                left: -60,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 100 + (25 * _backgroundAnimation.value),
                right: 30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadedContent(ReportLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadDateRangeReport(fromDate, toDate);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DateRangeSelector(
                    fromDate: fromDate,
                    toDate: toDate,
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: QuickDateButtons(
                    currentFromDate: fromDate,
                    currentToDate: toDate,
                    onDateRangeSelected: _loadDateRangeReport,
                  ),
                ),
              ],
            ),


            const SizedBox(height: 20),

            StudyTimeCard(
              totalStudyTimeMinutes: state.totalStudyTime,
            ),

            const SizedBox(height: 18),

            if (state.groupedLessons.isNotEmpty) ...[
              const Text(
                'Khóa học hôm nay',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              ...state.groupedLessons.entries.map((entry) {
                final course = entry.key;
                final lessons = entry.value;
                final studyTime = lessons.fold(0, (sum, lesson) => sum + lesson.duration);

                return CourseReportCard(
                  course: course,
                  lessons: lessons,
                  studyTimeMinutes: studyTime,
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có dữ liệu học tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy bắt đầu học để xem báo cáo chi tiết',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _loadDateRangeReport(picked.start, picked.end);
    }
  }
}

// Extension to provide easy provider access
extension LearningReportPageProviders on Widget {
  static Widget withProviders({required Widget child}) {
    return BlocProvider<ReportBloc>(
      create: (context) => ReportBloc(),
      child: child,
    );
  }
}