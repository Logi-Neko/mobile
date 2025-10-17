import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/home/dto/show_user.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/leaderboard_bloc.dart';
import '../../dto/friendship_dto.dart';
import '../widgets/friend_request_dialog.dart';
import '../widgets/sendfriend_request_dialog.dart';

@RoutePage()
class LeaderboardScreen extends StatefulWidget {
  final User? currentUser;

  const LeaderboardScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late LeaderboardBloc _leaderboardBloc;
  late AnimationController _starController;
  late AnimationController _bounceController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _leaderboardBloc = LeaderboardBloc();

    _starController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _leaderboardBloc.add(LoadGlobalLeaderboard());
    _leaderboardBloc.add(LoadFriendsLeaderboard());
  }

  bool _isCurrentUser(AccountShowResponse user) {
    return widget.currentUser?.id == user.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _leaderboardBloc.close();
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _tabController.animateTo(index);

    if (index == 0) {
      _leaderboardBloc.add(LoadGlobalLeaderboard());
    } else {
      _leaderboardBloc.add(LoadFriendsLeaderboard());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _leaderboardBloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF002171),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildCompactAppBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildGlobalLeaderboard(),
                      _buildFriendsLeaderboard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingNavigation(),
      ),
    );
  }

  Widget _buildCompactAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.router.push(const HomeRoute()),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.primaryPink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              _currentTabIndex == 0 ? 'Bảng Xếp Hạng' : 'Bạn Bè',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Notification/Friends request button
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bounceController.value * 0.08),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.gradientMiddle],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mail, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => BlocProvider.value(
                          value: _leaderboardBloc,
                          child: const FriendRequestDialog(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryPink, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFabButton(
            icon: Icons.public,
            label: 'Bảng Xếp Hạng',
            isActive: _currentTabIndex == 0,
            onTap: () => _switchTab(0),
          ),
          const SizedBox(width: 4),
          _buildFabButton(
            icon: Icons.group,
            label: 'Bạn Bè',
            isActive: _currentTabIndex == 1,
            onTap: () => _switchTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildFabButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalContent(List<AccountShowResponse> leaderboard) {
    if (leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _starController.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.stars,
                    color: AppColors.warning,
                    size: 80,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có dữ liệu bảng xếp hạng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final sortedLeaderboard = List<AccountShowResponse>.from(leaderboard)
      ..sort((a, b) => b.totalStar.compareTo(a.totalStar));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...sortedLeaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final rank = index + 1;
            return _buildUserCard(user, rank);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUserCard(AccountShowResponse user, int rank) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        final isCurrentUser = _isCurrentUser(user);
        final isFriend = _leaderboardBloc.isFriend(user.id);
        final hasPending = _leaderboardBloc.hasPendingRequest(user.id);

        List<Color> getRankColors() {
          switch (rank) {
            case 1:
              return [AppColors.warning, const Color(0xFFFFD700)];
            case 2:
              return [const Color(0xFFD3D3D3), const Color(0xFFC0C0C0)];
            case 3:
              return [const Color(0xFFCD7F32), const Color(0xFFDEB887)];
            default:
              return [AppColors.primaryBlue, AppColors.accent];
          }
        }

        Widget getRankIcon() {
          final colors = getRankColors();
          IconData icon;

          switch (rank) {
            case 1:
              icon = Icons.looks_one;
              break;
            case 2:
              icon = Icons.looks_two;
              break;
            case 3:
              icon = Icons.looks_3;
              break;
            default:
              icon = Icons.star;
          }

          return Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scale: rank <= 3 ? 1.0 + (_bounceController.value * 0.02) : 1.0,
                child: GestureDetector(
                  onTap: isCurrentUser ? null : () {
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: _leaderboardBloc,
                        child: SendFriendRequestDialog(
                          user: user,
                          onSuccess: () {
                            _leaderboardBloc.add(LoadGlobalLeaderboard());
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentUser ? AppColors.accent.withOpacity(0.9) :
                        isFriend ? AppColors.success.withOpacity(0.9) :
                        hasPending ? AppColors.warning.withOpacity(0.9) :
                        rank <= 3 ? getRankColors().first.withOpacity(1) :
                        Colors.white.withOpacity(0.4),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrentUser ? AppColors.accent.withOpacity(0.15) :
                          isFriend ? AppColors.success.withOpacity(0.15) :
                          hasPending ? AppColors.warning.withOpacity(0.15) :
                          rank <= 3
                              ? getRankColors().first.withOpacity(0.2)
                              : Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        getRankIcon(),
                        const SizedBox(width: 12),

                        // Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentUser ? AppColors.accent :
                              isFriend ? AppColors.success :
                              hasPending ? AppColors.warning :
                              rank <= 3 ? getRankColors().first : AppColors.primaryBlue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isCurrentUser ? AppColors.accent :
                                isFriend ? AppColors.success :
                                hasPending ? AppColors.warning :
                                rank <= 3 ? getRankColors().first : AppColors.primaryBlue).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.cardBackground.withOpacity(0.2),
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.primaryBlue.withOpacity(0.8), AppColors.accent.withOpacity(0.6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: ClipOval(
                                  child: Image.asset(
                                    "lib/shared/assets/images/LOGO.jpg",
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCurrentUser) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.accent, AppColors.primaryPink],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Bạn',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ] else if (isFriend) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.success, AppColors.buttonPrimary],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Bạn Bè',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ] else if (hasPending) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.warning, AppColors.accent],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Chờ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.warning.withOpacity(0.3), AppColors.accent.withOpacity(0.2)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellowAccent,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${user.totalStar}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Trophy + Status icon
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (rank <= 3)
                              AnimatedBuilder(
                                animation: _starController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _starController.value * 0.1,
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: getRankColors().first,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            else
                              Icon(
                                isCurrentUser ? Icons.person :
                                isFriend ? Icons.people :
                                hasPending ? Icons.hourglass_empty : Icons.person_add,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGlobalLeaderboard() {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _starController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _starController.value * 2 * 3.14159,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryPink, AppColors.warning],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.stars,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Đang tải...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else if (state is GlobalLeaderboardLoaded) {
          return _buildGlobalContent(state.leaderboard);
        } else if (state is LeaderboardError) {
          return _buildErrorWidget(state.message, () {
            _leaderboardBloc.add(LoadGlobalLeaderboard());
          });
        }

        return const Center(
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      },
    );
  }

  Widget _buildFriendsLeaderboard() {
    return BlocListener<LeaderboardBloc, LeaderboardState>(
      listener: (context, state) {
        if (state is FriendRemoved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_bounceController.value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF42A5F5)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Đang tải bạn bè...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is FriendsLeaderboardLoaded) {
            return _buildFriendsContent(state.friends);
          } else if (state is LeaderboardError) {
            return _buildErrorWidget(state.message, () {
              _leaderboardBloc.add(LoadFriendsLeaderboard());
            });
          }

          return const Center(
            child: Text(
              'Chưa có dữ liệu',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsContent(List<FriendDto> friends) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_bounceController.value * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF42A5F5)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có bạn bè nào!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hãy thêm bạn bè để cùng thi đấu!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedFriends = List<FriendDto>.from(friends)
      ..sort((a, b) => b.friendAccount.totalStar.compareTo(a.friendAccount.totalStar));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedFriends.length,
      itemBuilder: (context, index) {
        return _buildFriendItem(sortedFriends[index], index + 1);
      },
    );
  }

  Widget _buildFriendItem(FriendDto friend, int rank) {
    List<Color> getRankColors() {
      switch (rank) {
        case 1: return [const Color(0xFFFFD700), const Color(0xFFFFB347)];
        case 2: return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)];
        case 3: return [const Color(0xFFCD7F32), const Color(0xFF8D4E00)];
        default: return [const Color(0xFF81C784), const Color(0xFF66BB6A)];
      }
    }

    Widget getRankIcon() {
      final colors = getRankColors();
      IconData icon;

      switch (rank) {
        case 1: icon = Icons.emoji_events; break;
        case 2: icon = Icons.military_tech; break;
        case 3: icon = Icons.workspace_premium; break;
        default: icon = Icons.star;
      }

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: rank <= 3
            ? Icon(icon, color: Colors.white, size: 22)
            : Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    void _showRemoveFriendDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Xóa bạn bè?',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Xóa ${friend.friendAccount.fullName} khỏi danh sách bạn bè?',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<LeaderboardBloc>().add(RemoveFriend(friend.id));
              },
              child: const Text(
                'XÓA',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: rank <= 3 ? 1.0 + (_bounceController.value * 0.02) : 1.0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: rank <= 3
                        ? getRankColors().first.withOpacity(0.8)
                        : Colors.white.withOpacity(0.4),
                    width: 2.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: rank <= 3
                        ? getRankColors().first.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  getRankIcon(),
                  const SizedBox(width: 12),

                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rank <= 3 ? getRankColors().first : const Color(0xFF81C784),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (rank <= 3 ? getRankColors().first : const Color(0xFF81C784)).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.cardBackground.withOpacity(0.2),
                      backgroundImage: friend.friendAccount.avatarUrl != null
                          ? NetworkImage(friend.friendAccount.avatarUrl!)
                          : null,
                      child: friend.friendAccount.avatarUrl == null
                          ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primaryPink.withOpacity(0.8), AppColors.accent.withOpacity(0.6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              "lib/shared/assets/images/LOGO.jpg",
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Friend Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          friend.friendAccount.fullName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x40FFFFFF), Color(0x20FFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.yellow),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${friend.friendAccount.totalStar}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Action buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _starController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_starController.value * 0.1).abs(),
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B9D), Color(0xFFFF8A65)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<LeaderboardBloc, LeaderboardState>(
                        builder: (context, state) {
                          final isLoading = state is LeaderboardOperationLoading;

                          return GestureDetector(
                            onTap: isLoading ? null : () => _showRemoveFriendDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.error.withOpacity(0.8),
                                    AppColors.error.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.error.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Icon(
                                Icons.person_remove,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_bounceController.value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Ôi không! Có lỗi xảy ra rồi!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_bounceController.value * 0.05),
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        'Thử lại nhé!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}