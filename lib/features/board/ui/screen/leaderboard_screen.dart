import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/home/dto/show_user.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/leaderboard_bloc.dart';
import '../../dto/friendship_dto.dart';
import '../widgets/friend_request_dialog.dart';

@RoutePage()
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late LeaderboardBloc _leaderboardBloc;
  late AnimationController _starController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _leaderboardBloc = LeaderboardBloc();
    
    // Animation controllers for fun effects
    _starController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    // Load initial data
    _leaderboardBloc.add(LoadGlobalLeaderboard());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _leaderboardBloc.close();
    _starController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _leaderboardBloc,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
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
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button with fun design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primaryPink],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => context.router.pushAndPopUntil(
                const HomeRoute(),
                predicate: (route) => false,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.warning,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bảng Xếp Hạng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Color(0x40000000),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.stars,
                    color: AppColors.warning,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          // Add friend button with animation
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bounceController.value * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.gradientMiddle],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBackground.withOpacity(0.4), AppColors.cardBackground.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: AppColors.cardShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryPink, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        onTap: (index) {
          if (index == 0) {
            _leaderboardBloc.add(LoadGlobalLeaderboard());
          } else {
            _leaderboardBloc.add(LoadFriendsLeaderboard());
          }
        },
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.public, size: 18),
                SizedBox(width: 6),
                Text('BẢNG XẾP HẠNG'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 18),
                SizedBox(width: 6),
                Text('BẠN BÈ'),
              ],
            ),
          ),
        ],
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

    // Sort leaderboard by totalStar in descending order
    final sortedLeaderboard = List<AccountShowResponse>.from(leaderboard)
      ..sort((a, b) => b.totalStar.compareTo(a.totalStar));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          
          // Leaderboard list
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
    // Get rank colors and icons
    List<Color> getRankColors() {
      switch (rank) {
        case 1:
          return [AppColors.warning, const Color(0xFFFFD700)]; // Gold
        case 2:
          return [const Color(0xFFC0C0C0), const Color(0xFFE8E8E8)]; // Silver
        case 3:
          return [const Color(0xFFCD7F32), const Color(0xFFDEB887)]; // Bronze
        default:
          return [AppColors.primaryBlue, AppColors.accent];
      }
    }

    Widget getRankIcon() {
      switch (rank) {
        case 1:
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: getRankColors()),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.looks_one, color: Colors.white, size: 24),
          );
        case 2:
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: getRankColors()),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.looks_two, color: Colors.white, size: 24),
          );
        case 3:
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: getRankColors()),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.looks_3, color: Colors.white, size: 24),
          );
        default:
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: getRankColors()),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: rank <= 3 ? 1.0 + (_bounceController.value * 0.02) : 1.0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: rank <= 3 
                  ? LinearGradient(
                      colors: [
                        getRankColors().first.withOpacity(0.3),
                        getRankColors().last.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.cardBackground.withOpacity(0.3),
                        AppColors.cardBackground.withOpacity(0.1),
                      ],
                    ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: rank <= 3 ? getRankColors().first.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rank <= 3 
                      ? getRankColors().first.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Rank icon
                  getRankIcon(),
                  const SizedBox(width: 16),
                  
                  // Avatar with decorative border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rank <= 3 ? getRankColors().first : AppColors.primaryBlue,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (rank <= 3 ? getRankColors().first : AppColors.primaryBlue).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
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
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.warning.withOpacity(0.3), AppColors.accent.withOpacity(0.2)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color:Color.fromARGB(255, 252, 244, 243),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.totalStar}', //qưeqweqwe
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 241, 223, 218),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (user.premium == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primaryPink, AppColors.accent],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Trophy for top 3
                  if (rank <= 3)
                    AnimatedBuilder(
                      animation: _starController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _starController.value * 0.1,
                          child: Icon(
                            Icons.emoji_events,
                            color: getRankColors().first,
                            size: 32,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
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
                    fontSize: 18,
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
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
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
                    fontSize: 18,
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
                      size: 80,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              '🎈 Chưa có bạn bè nào! 🎈',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '✨ Hãy thêm bạn bè để cùng thi đấu nhé! ✨',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort friends by totalStar in descending order
    final sortedFriends = List<FriendDto>.from(friends)
      ..sort((a, b) => b.friendAccount.totalStar.compareTo(a.friendAccount.totalStar));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedFriends.length,
      itemBuilder: (context, index) {
        return _buildFriendItem(sortedFriends[index], index + 1);
      },
    );
  }

  Widget _buildFriendItem(FriendDto friend, int rank) {
    List<Color> getRankColors() {
      switch (rank) {
        case 1: return [const Color(0xFFFFD700), const Color(0xFFFFB347)]; // Gold
        case 2: return [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)]; // Silver
        case 3: return [const Color(0xFFCD7F32), const Color(0xFF8D4E00)]; // Bronze
        default: return [const Color(0xFF81C784), const Color(0xFF66BB6A)]; // Green
      }
    }

    Widget getRankIcon() {
      final colors = getRankColors();
      
      return Container(
        width: 55,
        height: 55,
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
        child: rank == 1 
          ? const Icon(Icons.emoji_events, color: Colors.white, size: 28)
          : rank == 2
            ? const Icon(Icons.military_tech, color: Colors.white, size: 28)
            : rank == 3
              ? const Icon(Icons.workspace_premium, color: Colors.white, size: 28)
              : Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
      );
    }

    String getRankEmoji() {
      switch (rank) {
        case 1: return '👑';
        case 2: return '🥈';
        case 3: return '🥉';
        default: return '🌟';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: rank <= 3 ? 1.0 + (_bounceController.value * 0.02) : 1.0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: rank <= 3 
                  ? LinearGradient(
                      colors: [
                        getRankColors().first.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0x30FFFFFF),
                        Color(0x15FFFFFF),
                      ],
                    ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: rank <= 3 
                    ? getRankColors().first.withOpacity(0.6)
                    : Colors.white.withOpacity(0.3), 
                  width: 2
                ),
                boxShadow: [
                  BoxShadow(
                    color: rank <= 3 
                      ? getRankColors().first.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  getRankIcon(),
                  const SizedBox(width: 16),
                  
                  // Avatar with decorative border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rank <= 3 ? getRankColors().first : const Color(0xFF81C784),
                        width: 3,
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
                      radius: 30,
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
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Friend Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${getRankEmoji()} ${friend.friendAccount.fullName.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x40FFFFFF), Color(0x20FFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${friend.friendAccount.totalStar} ⭐',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Gift icon with fun animation
                  AnimatedBuilder(
                    animation: _starController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_starController.value * 0.1).abs(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFFF8A65)],
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                            size: 24,
                          ),
                        ),
                      );
                    },
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
                '😢 Ôi không! Có lỗi xảy ra rồi!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
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
                    fontSize: 16,
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
                      icon: const Icon(Icons.refresh, size: 24),
                      label: const Text(
                        '🔄 Thử lại nhé!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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