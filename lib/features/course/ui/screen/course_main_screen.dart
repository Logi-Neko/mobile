import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/home/bloc/home_bloc.dart';
import 'package:logi_neko/features/lesson/ui/screen/lesson_screen.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/course_bloc.dart';
import '../../repository/course_repository.dart';
import '../../dto/course.dart';
import '../widgets/course_grid_widget.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class CourseScreen extends StatelessWidget {
  final bool userIsPremium;

  const CourseScreen({
    super.key,
    this.userIsPremium = false,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseBloc(CourseRepositoryImpl())..add(LoadCourses()),
      child: CourseView(userIsPremium: userIsPremium),
    );
  }
}

class CourseView extends StatefulWidget {
  final bool userIsPremium;

  const CourseView({super.key, required this.userIsPremium});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView>
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
            onPressed: () => context.router.pushAndPopUntil(
              const HomeRoute(),
              predicate: (route) => false,
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text("Quay lại", style: TextStyle(color: Colors.black)),
          ),
          Row(
            children: [
              _buildParentContainer(),
              const SizedBox(width: 8),
              _buildPremiumContainer(context),
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
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CourseBloc>().add(LoadCourses());
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                CourseGridWidget(
                  courses: allCourses,
                  userIsPremium: widget.userIsPremium,
                  isLoading: false,
                  error: null,
                  errorCode: null,
                  onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
                  onCourseSelected: _onCourseSelected,
                  emptyMessage: "Chưa có khóa học nào",
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
          userIsPremium: widget.userIsPremium,
          isLoading: true,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
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
          userIsPremium: widget.userIsPremium,
          isLoading: false,
          error: state.message,
          errorCode: state.errorCode,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
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
          userIsPremium: widget.userIsPremium,
          isLoading: false,
          error: null,
          errorCode: null,
          onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
          onCourseSelected: _onCourseSelected,
          emptyMessage: "Chưa có khóa học nào",
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
    if (course.isPremium && !widget.userIsPremium) {
      _showCourseAccessDeniedDialog(course);
      return;
    }

    if (!course.isActive) {
      _showCourseInactiveDialog(course);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          courseId: course.id,
          courseName: course.name,
          courseDescription: course.description,
            userIsPremium: widget.userIsPremium,
        ),
      ),
    );
  }

  void _showCourseAccessDeniedDialog(Course course) {
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
            Text("Khóa học Premium"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bạn cần nâng cấp lên Premium để truy cập khóa học này."),
            SizedBox(height: 8),
            Text(
              "Với Premium bạn sẽ có:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• Truy cập tất cả khóa học"),
            Text("• Không giới hạn thời gian học"),
            Text("• Hỗ trợ ưu tiên"),
          ],
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

  void _showCourseInactiveDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text("Khóa học chưa mở"),
          ],
        ),
        content: Text("Khóa học này chưa được kích hoạt."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Đóng"),
          ),
        ],
      ),
    );
  }

  Widget _buildParentContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9575CD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9575CD).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF8C42), Colors.deepOrange.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C42).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Phụ huynh',
            style: TextStyle(
              color: Color(0xFF5C6BC0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContainer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.pushAndPopUntil(
          const SubscriptionRoute(),
          predicate: (route) => false,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF8C42),
              Colors.deepOrange.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFB74D), Colors.amber.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}