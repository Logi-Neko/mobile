import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/room/api/contest_api.dart';
import 'package:logi_neko/features/room/dto/contest.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ContestListScreen extends StatefulWidget {
  const ContestListScreen({Key? key}) : super(key: key);

  @override
  State<ContestListScreen> createState() => _ContestListScreenState();
}

class _ContestListScreenState extends State<ContestListScreen> {
  final ContestService _contestService = ContestService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Contest> _contests = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalElements = 0;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadContests();
  }

  Future<void> _loadContests() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await _contestService.getAllContests(
        keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
        page: _currentPage,
        size: 10,
      );

      if (mounted) {
        setState(() {
          _contests = response.content;
          _totalPages = response.totalPages;
          _totalElements = response.totalElements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Không thể tải danh sách contest: $e');
      }
    }
  }

  Future<void> _joinContest(int contestId) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('currentUserId');

      if (accountId == null) {
        _showErrorDialog('Vui lòng đăng nhập để tham gia contest');
        return;
      }

      print('🔑 [ContestList] Joining contest $contestId with accountId: $accountId');

      await _contestService.joinContest(contestId, accountId);

      final participantId = await _contestService.joinContest(contestId, accountId);

      int? finalParticipantId = participantId;

      if (finalParticipantId == null) {
        print('⚠️ [ContestList] No participantId in join response, fetching from participants list...');
        final participants = await _contestService.getAllParticipantsInContest(contestId);
        print('📋 [ContestList] All participants after join: ${participants.length} participants');

        if (participants.isNotEmpty) {
          participants.sort((a, b) {
            if (a.joinAt == null) return 1;
            if (b.joinAt == null) return -1;
            return b.joinAt!.compareTo(a.joinAt!);
          });

          final myParticipant = participants.first;
          finalParticipantId = myParticipant.id;
          print('📋 [ContestList] Found newest participant: id=${myParticipant.id}, name=${myParticipant.accountName}, joinAt=${myParticipant.joinAt}');
        }
      }

      if (finalParticipantId != null) {
        await prefs.setInt('participantId_$contestId', finalParticipantId);
        print('💾 [ContestList] Saved participantId: $finalParticipantId for contest: $contestId (accountId: $accountId)');
      } else {
        print('❌ [ContestList] Could not find participant after joining');
        _showErrorDialog('Không thể lấy thông tin participant');
        return;
      }

      _showSuccessSnackBar('Đã tham gia contest thành công!');
      context.router.push(WaitingRoomRoute(contestId: contestId));
    } catch (e) {
      print('❌ [ContestList] Error joining contest: $e');
      _showErrorDialog('Không thể tham gia contest: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Lỗi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.error.withOpacity(0.1),
            ),
            child: const Text('Đóng', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _contests.isEmpty
                    ? _buildEmptyState()
                    : _buildContestGrid(),
              ),
              if (_totalPages > 1 && !_isLoading) _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF002171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => context.router.push(const HomeRoute()),
              iconSize: 24,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Danh sách Contest',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_totalElements cuộc thi có sẵn',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF002171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                context.router.push(const ContestHistoryRoute());
              },
              tooltip: 'Lịch sử thi đấu',
              iconSize: 20,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm contest theo tên...',
            hintStyle: TextStyle(color: AppColors.textLight.withOpacity(0.7), fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear_rounded, color: AppColors.textLight, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchKeyword = '';
                  _currentPage = 0;
                });
                _loadContests();
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchKeyword = value.trim();
              _currentPage = 0;
            });
            _loadContests();
          },
        ),
      ),
    );
  }

  Widget _buildContestGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính số cột dựa trên chiều rộng màn hình
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 600) {
          // Tablet hoặc màn hình rộng: 3 cột
          crossAxisCount = 3;
          childAspectRatio = 1.02;
        } else if (constraints.maxWidth > 400) {
          // Màn hình trung bình: 2 cột
          crossAxisCount = 2;
          childAspectRatio = 1;
        } else {
          // Màn hình nhỏ: 2 cột với tỷ lệ điều chỉnh
          crossAxisCount = 2;
          childAspectRatio = 1;
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _contests.length,
          itemBuilder: (context, index) {
            return _buildContestCard(_contests[index], index);
          },
        );
      },
    );
  }

  Widget _buildContestCard(Contest contest, int index) {
    final bool isJoinable = contest.status.toUpperCase() == 'OPEN';

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 20,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isJoinable ? () => _joinContest(contest.id) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon và Status
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: _getStatusGradient(contest.status),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusGradient(contest.status).colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(contest.status),
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                  // Title
                  Text(
                    contest.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 0.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  // Info chips
                  Column(
                    children: [
                      _buildCompactInfoChip(
                        Icons.qr_code_scanner_rounded,
                        contest.code,
                        AppColors.primaryPurple,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactInfoChip(
                        Icons.calendar_today_rounded,
                        _formatDate(contest.startTime),
                        AppColors.primaryBlue,
                      ),
                    ],
                  ),

                  // Join button
                  _buildCompactJoinButton(isJoinable, contest.id),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactJoinButton(bool isJoinable, int contestId) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isJoinable
            ? AppColors.primaryGradient
            : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
        boxShadow: isJoinable
            ? [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isJoinable ? () => _joinContest(contestId) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isJoinable ? Icons.login_rounded : Icons.lock_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isJoinable ? 'Tham gia' : 'Đã đóng',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Map<String, dynamic>> statusConfig = {
      'OPEN': {
        'color': AppColors.success,
        'text': 'Đang mở',
        'icon': Icons.circle,
      },
      'RUNNING': {
        'color': AppColors.primaryBlue,
        'text': 'Đang chạy',
        'icon': Icons.circle,
      },
      'CLOSED': {
        'color': AppColors.textLight,
        'text': 'Đã đóng',
        'icon': Icons.circle,
      },
    };

    final config = statusConfig[status.toUpperCase()] ?? statusConfig['CLOSED']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 7,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 5),
          Text(
            config['text'] as String,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: config['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoChip(IconData icon, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case 'RUNNING':
        return const LinearGradient(
          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
        );
      case 'CLOSED':
        return const LinearGradient(
          colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open_rounded;
      case 'RUNNING':
        return Icons.play_circle_filled_rounded;
      case 'CLOSED':
        return Icons.lock_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                onTap: () {
                  setState(() => _currentPage--);
                  _loadContests();
                },
              ),
              const SizedBox(width: 8),
              ..._buildPageNumbers(),
              const SizedBox(width: 8),
              _buildPaginationButton(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < _totalPages - 1,
                onTap: () {
                  setState(() => _currentPage++);
                  _loadContests();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.primaryGradient : null,
        color: enabled ? null : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Icon(
            icon,
            color: enabled ? Colors.white : AppColors.textLight,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    int displayPages = _totalPages > 5 ? 5 : _totalPages;

    for (int i = 0; i < displayPages; i++) {
      int pageNum;
      if (_totalPages <= 5) {
        pageNum = i;
      } else if (_currentPage < 3) {
        pageNum = i;
      } else if (_currentPage > _totalPages - 3) {
        pageNum = _totalPages - 5 + i;
      } else {
        pageNum = _currentPage - 2 + i;
      }

      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: _buildPageNumberButton(pageNum),
        ),
      );
    }

    return pages;
  }

  Widget _buildPageNumberButton(int pageNum) {
    final isSelected = _currentPage == pageNum;

    return InkWell(
      onTap: () {
        setState(() => _currentPage = pageNum);
        _loadContests();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: AppColors.textLight.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            '${pageNum + 1}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
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
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Chưa có contest nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchKeyword.isNotEmpty
                  ? 'Không tìm thấy kết quả phù hợp'
                  : 'Danh sách contest đang trống',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}