import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
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
              return NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(state),
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


    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildLessonDetailSheet(lesson),
        );
      },
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

  Widget _buildLessonDetailSheet(Lesson lesson) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
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
              padding: const EdgeInsets.all(15),
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
                  const SizedBox(height: 8),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (lesson.hasProgress)
                    Column(
                      children: [
                        _buildProgressSection(lesson),
                        const SizedBox(height: 10),
                      ],
                    )
                  else
                    const SizedBox(height: 40),

                  if (lesson.totalVideo > 0)
                    Column(
                      children: [
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
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToQuizScreen(lesson);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lesson.isCompleted ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              lesson.isCompleted ? "Học lại" : "Bắt đầu học",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Chưa có video nào",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Nội dung đang được cập nhật",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
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