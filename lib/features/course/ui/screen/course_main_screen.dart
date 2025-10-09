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
  AnimationController? _backgroundController;
  Animation<double>? _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController!,
      curve: Curves.easeInOut,
    ));

    // Start animations after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _backgroundController != null) {
        _backgroundController!.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _backgroundController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide default values if animations are not ready
    final backgroundAnimationValue = _backgroundAnimation?.value ?? 0.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final backgroundController = _backgroundController;
    if (backgroundController == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final delay = index * 0.3;
            final animationValue = (backgroundController.value + delay) % 1.0;

            return Positioned(
              left: (index * 80.0 + 30) % MediaQuery.of(context).size.width,
              top: (index * 120.0 + 80) % MediaQuery.of(context).size.height,
              child: Transform.scale(
                scale: 0.3 + (animationValue * 0.7),
                child: Opacity(
                  opacity: (1 - animationValue) * 0.4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 12 : 16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout - stacked vertically
            return Column(
              children: [
                Row(
                  children: [
                    _buildBackButton(isSmallScreen),
                    const Spacer(),
                    _buildPremiumContainer(context, isSmallScreen),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTitle(isSmallScreen),
              ],
            );
          } else {
            // Desktop/Tablet layout - horizontal
            return Row(
              children: [
                _buildBackButton(isSmallScreen),
                const Spacer(),
                _buildTitle(isSmallScreen),
                const Spacer(),
                _buildPremiumContainer(context, isSmallScreen),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildBackButton(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => context.router.pushAndPopUntil(
            const HomeRoute(),
            predicate: (route) => false,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 10 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  color: const Color(0xFF2E3A87),
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  "Quay lại",
                  style: TextStyle(
                    color: const Color(0xFF2E3A87),
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isSmallScreen) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(
              "Khóa học",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            if (state is CourseLoaded)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 10 : 12,
                  vertical: isSmallScreen ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${state.courses.where((course) => course.isActive).length} khóa học",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseError) {
          _showErrorSnackBar(context, state);
        }
      },
      builder: (context, state) {
        if (state is CourseLoading) {
          return _buildLoadingContent();
        }

        if (state is CourseLoaded) {
          final allCourses = state.courses.where((course) => course.isActive).toList();
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CourseBloc>().add(LoadCourses());
            },
            child: CourseGridWidget(
              courses: allCourses,
              userIsPremium: widget.userIsPremium,
              isLoading: false,
              error: null,
              errorCode: null,
              onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
              onCourseSelected: _onCourseSelected,
              emptyMessage: "Chưa có khóa học nào",
            ),
          );
        }

        if (state is CourseError) {
          return _buildErrorContent(state);
        }

        return _buildEmptyContent();
      },
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 4,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Đang tải khóa học...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Vui lòng chờ một chút",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(CourseError state) {
    return CourseGridWidget(
      courses: const [],
      userIsPremium: widget.userIsPremium,
      isLoading: false,
      error: state.message,
      errorCode: state.errorCode,
      onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
      onCourseSelected: _onCourseSelected,
      emptyMessage: "Chưa có khóa học nào",
    );
  }

  Widget _buildEmptyContent() {
    return CourseGridWidget(
      courses: const [],
      userIsPremium: widget.userIsPremium,
      isLoading: false,
      error: null,
      errorCode: null,
      onRetry: () => context.read<CourseBloc>().add(LoadCourses()),
      onCourseSelected: _onCourseSelected,
      emptyMessage: "Chưa có khóa học nào",
    );
  }

  void _showErrorSnackBar(BuildContext context, CourseError state) {
    Color backgroundColor = Colors.red.shade600;
    IconData icon = Icons.error_outline;
    String? actionLabel;
    VoidCallback? action;

    if (state.errorCode != null) {
      switch (state.errorCode!) {
        case 'NETWORK_ERROR':
          backgroundColor = Colors.orange.shade600;
          icon = Icons.wifi_off;
          actionLabel = 'Thử lại';
          action = () => context.read<CourseBloc>().add(LoadCourses());
          break;
        case 'UNAUTHORIZED':
          backgroundColor = Colors.purple.shade600;
          icon = Icons.lock;
          actionLabel = 'Đăng nhập';
          action = () {
            // Navigate to login
          };
          break;
        case 'TIMEOUT_ERROR':
          backgroundColor = Colors.amber.shade600;
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(
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
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: actionLabel != null && action != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock, color: Colors.orange.shade600, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Khóa học Premium",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bạn cần nâng cấp lên Premium để truy cập khóa học này.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Đóng",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.orange.shade600],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.router.pushAndPopUntil(
                              const SubscriptionRoute(),
                              predicate: (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Nâng cấp",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCourseInactiveDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 350,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning, color: Colors.orange.shade600, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Khóa học chưa mở",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Khóa học này chưa được kích hoạt. Vui lòng quay lại sau.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Đóng",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumContainer(BuildContext context, [bool isSmallScreen = false]) {
    return GestureDetector(
      onTap: () {
        context.router.pushAndPopUntil(
          const SubscriptionRoute(),
          predicate: (route) => false,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade400,
              Colors.orange.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.amber.shade100],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.star,
                color: Colors.orange.shade600,
                size: isSmallScreen ? 12 : 14,
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
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