import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../api/contest_api.dart';
import '../dto/leaderboard_entry.dart';

@RoutePage()
class ContestResultScreen extends StatefulWidget {
  final int contestId;
  final int totalScore;
  final int totalQuestions;
  final int correctAnswers;

  const ContestResultScreen({
    Key? key,
    required this.contestId,
    required this.totalScore,
    required this.totalQuestions,
    required this.correctAnswers,
  }) : super(key: key);

  @override
  State<ContestResultScreen> createState() => _ContestResultScreenState();
}

class _ContestResultScreenState extends State<ContestResultScreen> with TickerProviderStateMixin {
  final ContestService _contestService = ContestService();
  List<LeaderboardEntry> _topPlayers = [];
  bool _isLoading = true;
  late AnimationController _podiumController;
  late AnimationController _confettiController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _podiumController.dispose();
    _confettiController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      print('🏆 [ContestResult] Loading leaderboard for contest ${widget.contestId}');

      await _contestService.refreshLeaderboard(widget.contestId);
      await Future.delayed(const Duration(milliseconds: 500));

      final leaderboardData = await _contestService.getLeaderboard(widget.contestId);
      final leaderboard = leaderboardData
          .map((data) => LeaderboardEntry.fromJson(data))
          .toList();

      leaderboard.sort((a, b) => a.rank.compareTo(b.rank));

      setState(() {
        _topPlayers = leaderboard.take(5).toList();
        _isLoading = false;
      });

      _headerController.forward();
      _podiumController.forward();
      _confettiController.forward();

      print('✅ [ContestResult] Loaded top ${_topPlayers.length} players');
    } catch (e) {
      print('❌ [ContestResult] Error loading leaderboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : isLandscape
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang tính toán kết quả...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPodium(isLandscape: false),
                const SizedBox(height: 24),
                if (_topPlayers.length > 3) _buildRemainingPlayers(isLandscape: false),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Header and podium
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildHeader(compact: true),
                      const SizedBox(height: 20),
                      _buildPodium(isLandscape: true),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right side - Remaining players and button
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      if (_topPlayers.length > 3)
                        _buildRemainingPlayers(isLandscape: true),
                      const SizedBox(height: 16),
                      _buildActionButtons(isLandscape: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({bool compact = false}) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        final scale = Curves.elasticOut.transform(_headerController.value);
        final opacity = _headerController.value;

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.5 + (scale * 0.5),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.amber.withOpacity(0.8),
                    Colors.amber.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bảng xếp hạng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${widget.correctAnswers}/${widget.totalQuestions} câu đúng • ${widget.totalScore} điểm',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium({required bool isLandscape}) {
    if (_topPlayers.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final first = _topPlayers.length > 0 ? _topPlayers[0] : null;
    final second = _topPlayers.length > 1 ? _topPlayers[1] : null;
    final third = _topPlayers.length > 2 ? _topPlayers[2] : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (second != null)
            Expanded(
              child: _buildPodiumPlace(
                second, 2, isLandscape ? 120 : 150,
                Colors.grey.shade300, const Color(0xFFC0C0C0),
                delay: 200,
              ),
            ),
          SizedBox(width: isLandscape ? 8 : 12),
          if (first != null)
            Expanded(
              child: _buildPodiumPlace(
                first, 1, isLandscape ? 150 : 180,
                Colors.amber, const Color(0xFFFFD700),
                delay: 0,
              ),
            ),
          SizedBox(width: isLandscape ? 8 : 12),
          if (third != null)
            Expanded(
              child: _buildPodiumPlace(
                third, 3, isLandscape ? 100 : 130,
                Colors.brown.shade300, const Color(0xFFCD7F32),
                delay: 400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
      LeaderboardEntry player,
      int rank,
      double height,
      Color medalColor,
      Color podiumColor, {
        required int delay,
      }) {
    return AnimatedBuilder(
      animation: _podiumController,
      builder: (context, child) {
        final delayedProgress = Curves.easeOutBack.transform(
          (((_podiumController.value * 1000) - delay) / 1000).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: delayedProgress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - delayedProgress) * 50),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: rank == 1 ? 70 : 60,
            height: rank == 1 ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  medalColor,
                  medalColor.withOpacity(0.7),
                ],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: medalColor.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                style: TextStyle(fontSize: rank == 1 ? 36 : 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            child: Text(
              '${player.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  podiumColor,
                  podiumColor.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: podiumColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: rank == 1 ? 32 : 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingPlayers({required bool isLandscape}) {
    final remaining = _topPlayers.skip(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 0 : 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xếp hạng khác',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ...remaining.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final rank = index + 4;

            return AnimatedBuilder(
              animation: _podiumController,
              builder: (context, child) {
                final delayedProgress = Curves.easeOut.transform(
                  (((_podiumController.value * 1000) - (600 + index * 100)) / 1000).clamp(0.0, 1.0),
                );

                return Opacity(
                  opacity: delayedProgress,
                  child: Transform.translate(
                    offset: Offset((1 - delayedProgress) * 50, 0),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(isLandscape ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withOpacity(0.4),
                            AppColors.warning.withOpacity(0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${player.score}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons({bool isLandscape = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 0 : 20),
      child: SizedBox(
        width: double.infinity,
        height: isLandscape ? 48 : 54,
        child: ElevatedButton.icon(
          onPressed: () {
            context.router.popUntilRoot();
          },
          icon: const Icon(Icons.home_rounded, size: 22),
          label: const Text(
            'Về trang chủ',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            elevation: 10,
            shadowColor: Colors.black.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}