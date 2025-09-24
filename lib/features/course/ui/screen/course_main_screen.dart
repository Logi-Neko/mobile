import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/lesson/ui/screen/lesson_screen.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/course_bloc.dart';
import '../../repository/course_repository.dart';
import '../../dto/course.dart';
import '../widgets/course_grid_widget.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseBloc(CourseRepositoryImpl())..add(LoadCourses()),
      child: const CourseView(),
    );
  }
}

class CourseView extends StatefulWidget {
  const CourseView({super.key});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          child: Column(
            children: [
              _buildHeader(),
              _buildTitle(),
              const SizedBox(height: 16),
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
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
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
            if (state is CourseLoaded)
              Text(
                "${state.courses.where((course) => course.isActive).length} khóa học có sẵn",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        );
      },
    );
  }
  Widget _buildTabView() {
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseError) {
          _showErrorSnackBar(context, state);
        }
      },
      builder: (context, state) {
        if (state is CourseLoading) {
          return _buildLoadingTabView();
        }

        if (state is CourseLoaded) {
          final allCourses = state.courses.where((course) => course.isActive).toList();
          final freeCourses = allCourses.where((course) => !course.isPremium).toList();
          final premiumCourses = allCourses.where((course) => course.isPremium).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CourseBloc>().add(LoadCourses());
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                CourseGridWidget(
                  courses: allCourses,
                  isLoading: false,
                  error: null,
                  errorCode: null,
                  onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
                  onCourseSelected: _onCourseSelected,
                  emptyMessage: "Chưa có khóa học nào",
                ),
                CourseGridWidget(
                  courses: freeCourses,
                  isLoading: false,
                  error: null,
                  errorCode: null,
                  onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
                  onCourseSelected: _onCourseSelected,
                  emptyMessage: "Chưa có khóa học miễn phí nào",
                ),
                CourseGridWidget(
                  courses: premiumCourses,
                  isLoading: false,
                  error: null,
                  errorCode: null,
                  onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
                  onCourseSelected: _onCourseSelected,
                  emptyMessage: "Chưa có khóa học premium nào",
                ),
              ],
            ),
          );
        }

        if (state is CourseError) {
          return _buildErrorTabView(state);
        }

        return _buildEmptyTabView();
      },
    );
  }

  Widget _buildLoadingTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        CourseGridWidget(
          courses: const [],
          isLoading: true,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: true,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học miễn phí nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: true,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học premium nào",
        ),
      ],
    );
  }

  Widget _buildErrorTabView(CourseError state) {
    return TabBarView(
      controller: _tabController,
      children: [
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: state.message,
          errorCode: state.errorCode,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: state.message,
          errorCode: state.errorCode,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học miễn phí nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: state.message,
          errorCode: state.errorCode,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học premium nào",
        ),
      ],
    );
  }

  Widget _buildEmptyTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học miễn phí nào",
        ),
        CourseGridWidget(
          courses: const [],
          isLoading: false,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học premium nào",
        ),
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, CourseError state) {
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
          action = () => context.read<CourseBloc>().add(LoadCourses());
          break;
        case 'UNAUTHORIZED':
          backgroundColor = Colors.purple;
          icon = Icons.lock;
          actionLabel = 'Đăng nhập';
          action = () {
            // Navigate to login
          };
          break;
        case 'TIMEOUT_ERROR':
          backgroundColor = Colors.amber;
          icon = Icons.access_time;
          actionLabel = 'Thử lại';
          action = () => context.read<CourseBloc>().add(LoadCourses());
          break;
        default:
          actionLabel = 'Thử lại';
          action = () => context.read<CourseBloc>().add(LoadCourses());
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lỗi tải dữ liệu',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
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
