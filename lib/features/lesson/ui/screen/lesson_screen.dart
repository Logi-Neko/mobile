import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/lesson/ui/widgets/lesson_detail_screen.dart';
import 'package:logi_neko/features/video/video_quiz/ui/screen/screen.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../dto/lesson.dart';
import '../../bloc/lesson_bloc.dart';
import '../../repository/lesson_repo.dart';
import '../widgets/lesson_grid_widget.dart';
import '../widgets/lesson_header_widget.dart';

class LessonScreen extends StatelessWidget {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool userIsPremium;
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    this.courseDescription = '',
    required this.userIsPremium,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonBloc(LessonRepositoryImpl())
        ..add(LoadLessonsByCourseId(courseId)),
      child: LessonView(
        courseId: courseId,
        courseName: courseName,
        courseDescription: courseDescription,
        userIsPremium: userIsPremium,
      ),
    );
  }
}

class LessonView extends StatefulWidget {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool userIsPremium;

  const LessonView({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.userIsPremium,
  });

  @override
  State<LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<LessonView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: BlocConsumer<LessonBloc, LessonState>(
            listener: (context, state) {
              if (state is LessonError) {
                _showErrorSnackBar(context, state);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(state),
                  Expanded(
                    child: _buildTabView(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LessonState state) {
    int totalLessons = 0;
    int completedLessons = 0;

    if (state is LessonsLoaded) {
      final activeLessons = state.lessons.where((lesson) => lesson.isActive).toList();
      totalLessons = activeLessons.length;
      completedLessons = activeLessons.where((lesson) => lesson.isCompleted).length;
    }

    return LessonHeaderWidget(
      courseName: widget.courseName,
      courseDescription: widget.courseDescription,
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildTabView(LessonState state) {
    List<Lesson> allLessons = [];

    if (state is LessonsLoaded) {
      allLessons = state.lessons.where((lesson) => lesson.isActive).toList();
      allLessons.sort((a, b) => a.order.compareTo(b.order));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          },
          child: LessonGridWidget(
            lessons: allLessons,
            userIsPremium: widget.userIsPremium,
            isLoading: state is LessonLoading,
            error: state is LessonError ? state.message : null,
            errorCode: state is LessonError ? state.errorCode : null,
            onRetry: () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId)),
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học nào",
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, LessonError state) {
    Color backgroundColor = Colors.red;
    IconData icon = Icons.error;
    String? actionLabel;
    VoidCallback? action;

    if (state.errorCode != null) {
      switch (state.errorCode!) {
        case 'NETWORK_ERROR':
          backgroundColor = Colors.orange;
          icon = Icons.wifi_off;
          actionLabel = 'Thử lại';
          action = () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          break;
        case 'UNAUTHORIZED':
          backgroundColor = Colors.purple;
          icon = Icons.lock;
          actionLabel = 'Đăng nhập';
          break;
        case 'TIMEOUT_ERROR':
          backgroundColor = Colors.amber;
          icon = Icons.access_time;
          actionLabel = 'Thử lại';
          action = () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          break;
        default:
          actionLabel = 'Thử lại';
          action = () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: actionLabel != null && action != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: action,
        )
            : null,
      ),
    );
  }

  void _onLessonSelected(Lesson lesson) {
    if (!lesson.canAccess) {
      _showAccessDeniedDialog(lesson);
      return;
    }

    if (lesson.isPremium && !widget.userIsPremium) {
      _showAccessDeniedDialog(lesson);
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LessonDetailScreen(
          lesson: lesson,
          userIsPremium: widget.userIsPremium,
          onStartLearning: () async {
             _navigateToQuizScreen(lesson);

            return true;
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((result) {
      if (mounted) {
        context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
      }
    });
  }

  void _showAccessDeniedDialog(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text("Bài học Premium"),
          ],
        ),
        content: Text(
          "Bạn cần nâng cấp lên Premium để truy cập bài học này.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () {
              context.router.pushAndPopUntil(
                const SubscriptionRoute(),
                predicate: (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text("Nâng cấp"),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tiến độ học tập",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lesson.isCompleted ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lesson.progressText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: lesson.progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              lesson.isCompleted ? Colors.green : Colors.blue,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _navigateToQuizScreen(Lesson lesson) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizChoiceScreen(
          lessonId: lesson.id,
          lessonName: lesson.name,
        ),
      ),
    );
    if (mounted) {
      context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
    }
  }
}