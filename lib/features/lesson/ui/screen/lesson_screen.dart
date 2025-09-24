import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    this.courseDescription = '',
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
      ),
    );
  }
}

class LessonView extends StatefulWidget {
  final int courseId;
  final String courseName;
  final String courseDescription;

  const LessonView({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
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
    _tabController = TabController(length: 4, vsync: this);
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
              return NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(state),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ];
                },
                body: _buildTabView(state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LessonState state) {
    int totalLessons = 0;
    int completedLessons = 0; // TODO: Get from user progress

    if (state is LessonsLoaded) {
      totalLessons = state.lessons.where((lesson) => lesson.isActive).length;
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
    List<Lesson> freeLessons = [];
    List<Lesson> premiumLessons = [];
    List<Lesson> completedLessons = [];

    if (state is LessonsLoaded) {
      allLessons = state.lessons.where((lesson) => lesson.isActive).toList();
      allLessons.sort((a, b) => a.order.compareTo(b.order));

      freeLessons = allLessons.where((lesson) => !lesson.isPremium).toList();
      premiumLessons = allLessons.where((lesson) => lesson.isPremium).toList();
      completedLessons = []; // TODO: Filter completed lessons from user progress
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
            isLoading: state is LessonLoading,
            error: state is LessonError ? state.message : null,
            errorCode: state is LessonError ? state.errorCode : null, // ✅ THÊM errorCode
            onRetry: () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId)),
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          },
          child: LessonGridWidget(
            lessons: freeLessons,
            isLoading: state is LessonLoading,
            error: state is LessonError ? state.message : null,
            errorCode: state is LessonError ? state.errorCode : null, // ✅ THÊM errorCode
            onRetry: () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId)),
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học miễn phí nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          },
          child: LessonGridWidget(
            lessons: premiumLessons,
            isLoading: state is LessonLoading,
            error: state is LessonError ? state.message : null,
            errorCode: state is LessonError ? state.errorCode : null, // ✅ THÊM errorCode
            onRetry: () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId)),
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học premium nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId));
          },
          child: LessonGridWidget(
            lessons: completedLessons,
            isLoading: state is LessonLoading,
            error: state is LessonError ? state.message : null,
            errorCode: state is LessonError ? state.errorCode : null, // ✅ THÊM errorCode
            onRetry: () => context.read<LessonBloc>().add(LoadLessonsByCourseId(widget.courseId)),
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa hoàn thành bài học nào",
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLessonDetailSheet(lesson),
    );
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
              Navigator.pop(context);
              // TODO: Navigate to premium upgrade screen
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

  Widget _buildLessonDetailSheet(Lesson lesson) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (lesson.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Premium",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoCard(
                        icon: Icons.play_circle_outline,
                        title: "Video",
                        value: "${lesson.totalVideo}",
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: "Thời lượng",
                        value: lesson.formattedDuration,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        icon: Icons.star,
                        title: "Đánh giá",
                        value: "${lesson.star}/5",
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToQuizScreen(lesson);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Bắt đầu học",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  void _navigateToQuizScreen(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizChoiceScreen(
          lessonId: lesson.id,
          lessonName: lesson.name,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}