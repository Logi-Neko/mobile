import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/board/ui/screen/leaderboard_screen.dart';
import 'package:logi_neko/features/character/ui/screen/character_screen.dart';
import 'package:logi_neko/features/home/bloc/home_bloc.dart';
import 'package:logi_neko/features/home/repository/home_repo.dart';
import 'package:logi_neko/features/home/ui/widgets/header_widget.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../../course/ui/screen/course_main_screen.dart';
import '../widgets/learning_card_widget.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeBloc _homeBloc;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _backgroundController;

  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _backgroundAnimation;

  final List<Map<String, dynamic>> learningTopics = const [
    {
      'title': 'Học tập',
      'icon': Icons.psychology,
      'color': Color(0xFF9C5AB8),
      'bgColor': Color(0xFFE1BEF0),
      'imagePath': 'lib/shared/assets/images/hoctap.jpg',
    },
    {
      'title': 'Cuộc thi',
      'icon': Icons.sports_esports,
      'color': Color(0xFFFF8C42),
      'bgColor': Color(0xFFFFE0CC),
      'imagePath': 'lib/shared/assets/images/cuocthi.png',
    },
    {
      'title': 'Nhân vật',
      'icon': Icons.store,
      'color': Color(0xFF4CAF50),
      'bgColor': Color(0xFFDCF2DD),
      'imagePath': 'lib/shared/assets/images/cuahang.jpg',
    },
    {
      'title': 'Bảng xếp hạng',
      'icon': Icons.leaderboard,
      'color': Color(0xFFE91E63),
      'bgColor': Color(0xFFFCE4EC),
      'imagePath': 'lib/shared/assets/images/leaderboard.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(HomeRepositoryImpl());
    _homeBloc.add(GetUserInfo());

    _setupAnimations();
  }

  void _setupAnimations() {
    // Floating animation cho header
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation cho các card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Sparkle animation cho background
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
    _backgroundController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _backgroundController.dispose();
    _homeBloc.close();
    super.dispose();
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth > screenHeight) {
      if (screenWidth > 1000) return 4;
      if (screenWidth > 800) return 4;
      if (screenWidth > 650) return 4;
      return 4;
    } else {
      if (screenWidth > 600) return 2;
      return 2;
    }
  }

  double _calculateChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth > screenHeight) {
      if (screenWidth > 1000) return 1.0;
      if (screenWidth > 800) return 0.9;
      if (screenWidth > 650) return 0.85;
      return 0.85;
    } else {
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Stack(
                children: [
                  _buildAnimatedBackground(),
                  SafeArea(
                    child: BlocConsumer<HomeBloc, HomeState>(
                      listener: (context, state) {
                        if (state is HomeError) {
                          _showErrorSnackBar(context, state.message);
                        }
                      },
                      builder: (context, state) {
                        return Column(
                          children: [
                            // Animated Header
                            AnimatedBuilder(
                              animation: _floatingAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatingAnimation.value),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
                                    child: _buildHeader(state),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 18),
                            // Animated Content
                            Expanded(
                              child: _buildContent(context, state),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final delay = index * 0.2;
            final animationValue = (_sparkleAnimation.value + delay) % 1.0;

            return Positioned(
              left: (index * 50.0 + 20) % MediaQuery.of(context).size.width,
              top: (index * 80.0 + 50) % MediaQuery.of(context).size.height,
              child: Transform.scale(
                scale: 0.5 + (animationValue * 1.5),
                child: Opacity(
                  opacity: (1 - animationValue) * 0.6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 4,
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

  Widget _buildHeader(HomeState state) {
    Widget headerContent;

    if (state is HomeLoading) {
      headerContent = const HeaderLoadingWidget();
    } else if (state is UserInfoLoaded) {
      headerContent = HeaderWidget(
        user: state.user,
        isUpdating: false,
      );
    } else if (state is UserInfoUpdating) {
      headerContent = HeaderWidget(
        user: state.currentUser,
        isUpdating: true,
      );
    } else if (state is HomeError) {
      headerContent = HeaderErrorWidget(
        onRetry: () => _homeBloc.add(GetUserInfo()),
      );
    } else {
      headerContent = const HeaderLoadingWidget();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: headerContent,
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeError) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            _buildLearningCards(context),
            const SizedBox(height: 20),
            _buildErrorSection(context, state),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: _buildLearningCards(context),
    );
  }

  Widget _buildLearningCards(BuildContext context) {
    final crossAxisCount = _calculateCrossAxisCount(context);
    final childAspectRatio = _calculateChildAspectRatio(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final spacing = screenWidth > 1000 ? 16.0 : screenWidth > 700 ? 12.0 : 8.0;

    final availableWidth = screenWidth * 0.9;
    final cardWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
    final cardHeight = cardWidth / childAspectRatio;
    final rows = (learningTopics.length / crossAxisCount).ceil();
    final totalGridHeight = (cardHeight * rows) + (spacing * (rows - 1));

    final availableHeight = screenHeight - 200;

    final adjustedAspectRatio = totalGridHeight > availableHeight
        ? cardWidth / (availableHeight / rows - spacing * (rows - 1) / rows)
        : childAspectRatio;

    return Center(
      child: Container(
        width: availableWidth,
        constraints: BoxConstraints(
          maxHeight: availableHeight,
        ),
        child: _buildGrid(context, crossAxisCount, adjustedAspectRatio, spacing),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, int crossAxisCount, double childAspectRatio, double spacing) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: learningTopics.length,
      itemBuilder: (context, index) {
        final topic = learningTopics[index];

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            // Stagger animations for different cards
            final delay = index * 0.1;
            final adjustedAnimation = (_pulseController.value + delay) % 1.0;
            final scale = 1.0 + (adjustedAnimation * 0.03);

            return Transform.scale(
              scale: scale,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 100)),
                curve: Curves.elasticOut,
                builder: (context, animation, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - animation)),
                    child: Opacity(
                      opacity: animation.clamp(0.0, 1.0),
                      child: LearningCardWidget(
                        title: topic['title'],
                        icon: topic['icon'],
                        color: topic['color'],
                        bgColor: topic['bgColor'],
                        imagePath: topic['imagePath'],
                        onTap: () => _handleCardTap(context, index),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _handleCardTap(BuildContext context, int index) {
    switch (index) {
      case 0: // Học tập
        final userIsPremium = _homeBloc.currentUser?.isPremium ?? false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _homeBloc,
              child: CourseScreen(userIsPremium: userIsPremium),
            ),
          ),
        );
        break;
      case 1: // Cuộc thi
        context.router.pushAndPopUntil(
          const WaitingRoomRoute(),
          predicate: (route) => false,
        );
        break;
      case 2: // Nhân vật
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterScreen(user: _homeBloc.currentUser),
          ),
        );
        break;
      case 3: // Bảng xếp hạng
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _homeBloc,
              child: LeaderboardScreen(currentUser: _homeBloc.currentUser),
            ),
          ),
        );
        break;
    }
  }

  Widget _buildErrorSection(BuildContext context, HomeError errorState) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.bounceOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade50,
                  Colors.pink.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorState.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                ),
                if (errorState.errorCode != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mã lỗi: ${errorState.errorCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _homeBloc.add(GetUserInfo());
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        _homeBloc.add(ClearError());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Ẩn lỗi',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          onPressed: () {
            _homeBloc.add(GetUserInfo());
          },
        ),
      ),
    );
  }
}