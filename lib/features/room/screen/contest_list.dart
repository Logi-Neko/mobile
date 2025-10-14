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
    setState(() => _isLoading = true);

    try {
      final response = await _contestService.getAllContests(
        keyword: _searchKeyword.isEmpty ? null : _searchKeyword,
        page: _currentPage,
        size: 10,
      );

      setState(() {
        _contests = response.content;
        _totalPages = response.totalPages;
        _totalElements = response.totalElements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Không thể tải danh sách contest: $e');
    }
  }

  Future<void> _joinContest(int contestId) async {
    setState(() => _isLoading = true);
    try {
      // Get current logged-in user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accountId = prefs.getInt('currentUserId');
      
      if (accountId == null) {
        _showErrorDialog('Vui lòng đăng nhập để tham gia contest');
        return;
      }
      
      print('🔑 [ContestList] Joining contest $contestId with accountId: $accountId');
      
      await _contestService.joinContest(contestId, accountId);
      
      // Get the participant ID after joining
      final participants = await _contestService.getAllParticipantsInContest(contestId);
      print('📋 [ContestList] All participants: $participants');
      
      // Find the participant that was just created (usually the last one)
      // or find by accountName if available
      Participant? participant;
      if (participants.isNotEmpty) {
        // Try to find by accountName first, then fallback to last participant
        participant = participants.firstWhere(
          (p) => p.accountName?.toLowerCase().contains('user') == true || 
                 p.accountName?.toLowerCase().contains('minh') == true,
          orElse: () => participants.last,
        );
      }
      
      if (participant != null) {
        // Save participant ID for later use
        await prefs.setInt('participantId_$contestId', participant.id);
        print('💾 [ContestList] Saved participantId: ${participant.id} for contest: $contestId');
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
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEEF2FF),
              Color(0xFFFCE7F3),
            ],
          ),
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
                    : _buildContestList(),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          // Nút back
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => context.router.back(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Quản lý Contest',
                  style: TextStyle(
                    fontSize: 20, // nhỏ lại
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '$_totalElements cuộc thi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // để cân bằng với icon back bên trái
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm contest...',
            hintStyle: const TextStyle(color: AppColors.textLight),
            prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textLight),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchKeyword = value;
              _currentPage = 0;
            });
            _loadContests();
          },
        ),
      ),
    );
  }

  Widget _buildContestList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _contests.length,
      itemBuilder: (context, index) {
        final contest = _contests[index];
        return _buildContestCard(contest);
      },
    );
  }

  Widget _buildContestCard(Contest contest) {
    final bool isJoinable = contest.status.toUpperCase() == 'OPEN';
    final Gradient buttonGradient = isJoinable
        ? AppColors.primaryGradient
        : const LinearGradient(colors: [Color(0xFF94A3B8), Color(0xFF64748B)]);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFAFA)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to contest detail screen
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with fixed size
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: _getStatusGradient(contest.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          _getStatusIcon(contest.status),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  contest.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(contest.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contest.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                Icons.qr_code_rounded,
                                contest.code,
                                AppColors.primaryPurple,
                              ),
                              _buildInfoChip(
                                Icons.calendar_today_rounded,
                                _formatDate(contest.startTime),
                                AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Join Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: buttonGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isJoinable ? () => _joinContest(contest.id) : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isJoinable ? 'Tham gia' : 'Đã đóng/Đang diễn ra',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toUpperCase()) {
      case 'OPEN':
        color = AppColors.success;
        text = 'Mở';
        break;
      case 'RUNNING':
        color = AppColors.primaryBlue;
        text = 'Đang diễn ra';
        break;
      case 'CLOSED':
        color = AppColors.textLight;
        text = 'Đã đóng';
        break;
      default:
        color = AppColors.textLight;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
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
        return const LinearGradient(
          colors: [Color(0xFFC084FC), Color(0xFFF472B6)],
        );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Icons.lock_open_rounded;
      case 'RUNNING':
        return Icons.play_circle_rounded;
      case 'CLOSED':
        return Icons.lock_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 0
                  ? () {
                setState(() => _currentPage--);
                _loadContests();
              }
                  : null,
              color: AppColors.primaryPurple,
            ),
            ...List.generate(
              _totalPages > 5 ? 5 : _totalPages,
                  (index) {
                int pageNum;
                if (_totalPages <= 5) {
                  pageNum = index;
                } else if (_currentPage < 3) {
                  pageNum = index;
                } else if (_currentPage > _totalPages - 3) {
                  pageNum = _totalPages - 5 + index;
                } else {
                  pageNum = _currentPage - 2 + index;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() => _currentPage = pageNum);
                      _loadContests();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: _currentPage == pageNum
                            ? AppColors.primaryGradient
                            : null,
                        color: _currentPage == pageNum
                            ? null
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${pageNum + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _currentPage == pageNum
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < _totalPages - 1
                  ? () {
                setState(() => _currentPage++);
                _loadContests();
              }
                  : null,
              color: AppColors.primaryPurple,
            ),
          ],
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33C084FC),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang tải dữ liệu...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có contest nào',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy tạo contest đầu tiên của bạn',
              style: TextStyle(
                fontSize: 15,
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
    super.dispose();
  }
}