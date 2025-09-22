import 'package:flutter/material.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/screen/screen.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/lesson.dart';
import '../../repository/lesson_repo.dart';
import '../widgets/lesson_grid_widget.dart';
import '../widgets/lesson_header_widget.dart';

class LessonScreen extends StatefulWidget {
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
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  final LessonRepository _repository = LessonRepositoryImpl();

  late TabController _tabController;

  List<Lesson> _allLessons = [];
  List<Lesson> _freeLessons = [];
  List<Lesson> _premiumLessons = [];
  List<Lesson> _completedLessons = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLessons();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLessons() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final lessons = await _repository.getLessonsByCourseId(widget.courseId);

      setState(() {
        _allLessons = lessons.where((lesson) => lesson.isActive).toList();
        _allLessons.sort((a, b) => a.order.compareTo(b.order));

        _freeLessons = _allLessons.where((lesson) => !lesson.isPremium).toList();
        _premiumLessons = _allLessons.where((lesson) => lesson.isPremium).toList();
        _completedLessons = []; // TODO: Filter completed lessons from user progress

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      LessonHeaderWidget(
                        courseName: widget.courseName,
                        courseDescription: widget.courseDescription,
                        totalLessons: _allLessons.length,
                        completedLessons: _completedLessons.length,
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ];
            },
            body: _buildTabView(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
        dividerColor: Colors.transparent,
        isScrollable: true,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.all_inclusive, size: 16),
                const SizedBox(width: 6),
                Text("Tất cả (${_allLessons.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline, size: 16),
                const SizedBox(width: 6),
                Text("Miễn phí (${_freeLessons.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 6),
                Text("Premium (${_premiumLessons.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 6),
                Text("Hoàn thành (${_completedLessons.length})"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        RefreshIndicator(
          onRefresh: _loadLessons,
          child: LessonGridWidget(
            lessons: _allLessons,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadLessons,
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: _loadLessons,
          child: LessonGridWidget(
            lessons: _freeLessons,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadLessons,
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học miễn phí nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: _loadLessons,
          child: LessonGridWidget(
            lessons: _premiumLessons,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadLessons,
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa có bài học premium nào",
          ),
        ),
        RefreshIndicator(
          onRefresh: _loadLessons,
          child: LessonGridWidget(
            lessons: _completedLessons,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadLessons,
            onLessonSelected: _onLessonSelected,
            emptyMessage: "Chưa hoàn thành bài học nào",
          ),
        ),
      ],
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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