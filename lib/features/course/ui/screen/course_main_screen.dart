import 'package:flutter/material.dart';
import 'package:logi_neko/features/lesson/ui/screen/lesson_screen.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/course.dart';
import '../../repository/course_repository.dart';
import '../widgets/course_grid_widget.dart';

class MainCoursesScreen extends StatefulWidget {
  const MainCoursesScreen({super.key});

  @override
  State<MainCoursesScreen> createState() => _MainCoursesScreenState();
}

class _MainCoursesScreenState extends State<MainCoursesScreen>
    with SingleTickerProviderStateMixin {
  final CourseRepository _repository = CourseRepositoryImpl();

  late TabController _tabController;

  List<Course> _allCourses = [];
  List<Course> _freeCourses = [];
  List<Course> _premiumCourses = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final courses = await _repository.getCourses();

      setState(() {
        _allCourses = courses.where((course) => course.isActive).toList();
        _freeCourses = _allCourses.where((course) => !course.isPremium).toList();
        _premiumCourses = _allCourses.where((course) => course.isPremium).toList();
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
          child: Column(
            children: [
              _buildHeader(),
              _buildTitle(),
              const SizedBox(height: 12),
              // _buildTabBar(),
              const SizedBox(height: 8),
              Expanded(child: _buildTabView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.black),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text("Quay lại", style: TextStyle(color: Colors.black)),
          ),
          Row(
            children: [
              _topButton("Phụ huynh", Icons.family_restroom, purple: true),
              const SizedBox(width: 8),
              _topButton("Premium", Icons.star, orange: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          "Khóa học",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!_isLoading && _error == null)
          Text(
            "${_allCourses.length} khóa học có sẵn",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.all_inclusive, size: 18),
                const SizedBox(width: 8),
                Text("Tất cả (${_allCourses.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.free_breakfast, size: 18),
                const SizedBox(width: 8),
                Text("Miễn phí (${_freeCourses.length})"),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 18),
                const SizedBox(width: 8),
                Text("Premium (${_premiumCourses.length})"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return RefreshIndicator(
      onRefresh: _loadCourses,
      child: TabBarView(
        controller: _tabController,
        children: [
          CourseGridWidget(
            courses: _allCourses,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadCourses,
            onCourseSelected: _onCourseSelected,
            emptyMessage: "Chưa có khóa học nào",
          ),
          CourseGridWidget(
            courses: _freeCourses,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadCourses,
            onCourseSelected: _onCourseSelected,
            emptyMessage: "Chưa có khóa học miễn phí nào",
          ),
          CourseGridWidget(
            courses: _premiumCourses,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadCourses,
            onCourseSelected: _onCourseSelected,
            emptyMessage: "Chưa có khóa học premium nào",
          ),
        ],
      ),
    );
  }

  void _onCourseSelected(Course course) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: _buildCoursePreview(course),
        );
      },
    );
  }

  Widget _buildCoursePreview(Course course) {
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
            margin: const EdgeInsets.symmetric(vertical: 4),
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
                          course.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (course.isPremium)
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
                    course.description,
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
                        title: "Bài học",
                        value: "${course.totalLesson}",
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: "Thời lượng",
                        value: "~${course.totalLesson * 10}p",
                      ),
                      const SizedBox(width: 16),
                      _buildInfoCard(
                        icon: Icons.attach_money,
                        title: "Giá",
                        value: course.price > 0
                            ? "${course.price.toStringAsFixed(0)}đ"
                            : "Miễn phí",
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonScreen(
                              courseId: course.id,
                              courseName: course.name,
                              courseDescription: course.description,
                            ),
                          ),
                        );
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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

  Widget _topButton(String text, IconData icon,
      {bool purple = false, bool orange = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: purple
            ? Colors.purple.shade100
            : orange
            ? Colors.orange
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: orange ? Colors.white : Colors.black),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: orange ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}