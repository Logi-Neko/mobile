import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc _homeBloc;

  final List<Map<String, dynamic>> learningTopics = const [
    {
      'title': 'Học tập',
      'icon': Icons.psychology,
      'color': Color(0xFF9C5AB8),
      'bgColor': Color(0xFFE1BEF0),
      'imagePath': 'lib/shared/assets/images/hoctap.jpg',
    },
    {
      'title': 'Cuộc thi cho bé',
      'icon': Icons.sports_esports,
      'color': Color(0xFFFF8C42),
      'bgColor': Color(0xFFFFE0CC),
      'imagePath': 'lib/shared/assets/images/cuocthi.png',
    },
    {
      'title': 'Cửa hàng nhân vật',
      'icon': Icons.store,
      'color': Color(0xFF4CAF50),
      'bgColor': Color(0xFFDCF2DD),
      'imagePath': 'lib/shared/assets/images/cuahang.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(HomeRepositoryImpl());
    _homeBloc.add(GetUserInfo());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: BlocConsumer<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state is HomeError) {
                  _showErrorSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      _buildHeader(state),
                      const SizedBox(height: 18),
                      _buildContent(context, state),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(HomeState state) {
    if (state is HomeLoading) {
      return const HeaderLoadingWidget();
    } else if (state is UserInfoLoaded) {
      return HeaderWidget(
        user: state.user,
        isUpdating: false,
      );
    } else if (state is UserInfoUpdating) {
      return HeaderWidget(
        user: state.currentUser,
        isUpdating: true,
      );
    } else if (state is HomeError) {
      return HeaderErrorWidget(
        onRetry: () => _homeBloc.add(GetUserInfo()),
      );
    }

    return const HeaderLoadingWidget();
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeError) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLearningCards(),
            const SizedBox(height: 40),
            _buildErrorSection(context, state),
          ],
        ),
      );
    }

    return Expanded(
      child: _buildLearningCards(),
    );
  }

  Widget _buildLearningCards() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: LearningCardWidget(
                  title: learningTopics[0]['title'],
                  icon: learningTopics[0]['icon'],
                  color: learningTopics[0]['color'],
                  bgColor: learningTopics[0]['bgColor'],
                  imagePath: learningTopics[0]['imagePath'],
                    onTap: () {
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
                    }
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LearningCardWidget(
                  title: learningTopics[1]['title'],
                  icon: learningTopics[1]['icon'],
                  color: learningTopics[1]['color'],
                  bgColor: learningTopics[1]['bgColor'],
                  imagePath: learningTopics[1]['imagePath'],
                 onTap: () {
                    context.router.pushAndPopUntil(
                      const WaitingRoomRoute(),
                      predicate: (route) => false,
                    );                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LearningCardWidget(
                  title: learningTopics[2]['title'],
                  icon: learningTopics[2]['icon'],
                  color: learningTopics[2]['color'],
                  bgColor: learningTopics[2]['bgColor'],
                  imagePath: learningTopics[2]['imagePath'],
                  onTap: () {
                    context.router.pushAndPopUntil(
                      const CharacterRoute(),
                      predicate: (route) => false,
                    );                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(BuildContext context, HomeError errorState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 42,
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
              ElevatedButton.icon(
                onPressed: () {
                  _homeBloc.add(GetUserInfo());
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  _homeBloc.add(ClearError());
                },
                child: Text(
                  'Ẩn lỗi',
                  style: TextStyle(
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          onPressed: () {
            _homeBloc.add(GetUserInfo());
          },
        ),
      ),
    );
  }
}