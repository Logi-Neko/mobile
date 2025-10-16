import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/features/room/api/contest_api.dart';
import 'package:logi_neko/features/room/dto/contest.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ContestHistoryScreen extends StatefulWidget {
  const ContestHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ContestHistoryScreen> createState() => _ContestHistoryScreenState();
}

class _ContestHistoryScreenState extends State<ContestHistoryScreen> {
  final ContestService _contestService = ContestService();
  List<ContestHistory> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('currentUserId');

      if (accountId == null) {
        throw Exception("Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.");
      }

      final history = await _contestService.getContestHistory(accountId);
      history.sort((a, b) => b.startTime.compareTo(a.startTime));
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử thi đấu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Xem lại các kỳ thi của bạn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade300,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                "Lỗi tải dữ liệu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chưa có lịch sử thi đấu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy tham gia một cuộc thi để bắt đầu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildContestCard(item, index);
      },
    );
  }

  Widget _buildContestCard(ContestHistory item, int index) {
    final stars = _getStarsForRank(item.rank);
    final isTopThree = item.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient border for top 3
          if (isTopThree)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    _getGradientForRank(item.rank)[0].withOpacity(0.2),
                    _getGradientForRank(item.rank)[1].withOpacity(0.05),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Rank Circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isTopThree
                            ? LinearGradient(
                          colors: _getGradientForRank(item.rank),
                        )
                            : null,
                        color: !isTopThree ? Colors.grey.shade200 : null,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isTopThree
                                ? _getGradientForRank(item.rank)[0].withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${item.rank}',
                          style: TextStyle(
                            color: isTopThree ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Contest Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.contestTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(item.startTime),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Score
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.score}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'điểm',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stars
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ...List.generate(
                        5,
                            (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.star_rounded,
                            color: i < stars ? Colors.orange : Colors.grey.shade300,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$stars sao',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _getStarDescription(stars),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getRankBadge(item.rank),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getStarsForRank(int rank) {
    switch (rank) {
      case 1:
        return 5; // 100 điểm
      case 2:
        return 4; // 80 điểm
      case 3:
        return 3; // 60 điểm
      case 4:
        return 2; // 40 điểm
      case 5:
        return 1; // 20 điểm
      default:
        return 0;
    }
  }

  String _getStarDescription(int stars) {
    switch (stars) {
      case 5:
        return 'Xuất sắc! 🏆';
      case 4:
        return 'Rất tốt! ⭐';
      case 3:
        return 'Tốt! 👍';
      case 2:
        return 'Khá 💪';
      case 1:
        return 'Cố gắng thêm 📈';
      default:
        return '';
    }
  }

  String _getRankBadge(int rank) {
    switch (rank) {
      case 1:
        return '🥇 Hạng 1';
      case 2:
        return '🥈 Hạng 2';
      case 3:
        return '🥉 Hạng 3';
      default:
        return 'Hạng $rank';
    }
  }

  List<Color> _getGradientForRank(int rank) {
    switch (rank) {
      case 1:
        return [Colors.amber.shade300, Colors.amber.shade600];
      case 2:
        return [Colors.grey.shade300, Colors.grey.shade500];
      case 3:
        return [Colors.brown.shade300, Colors.brown.shade600];
      default:
        return [Colors.grey.shade300, Colors.grey.shade400];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}