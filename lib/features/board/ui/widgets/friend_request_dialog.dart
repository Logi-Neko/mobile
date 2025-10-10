import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../bloc/leaderboard_bloc.dart';
import '../../dto/friendship_dto.dart';

class FriendRequestDialog extends StatefulWidget {
  const FriendRequestDialog({Key? key}) : super(key: key);

  @override
  State<FriendRequestDialog> createState() => _FriendRequestDialogState();
}

class _FriendRequestDialogState extends State<FriendRequestDialog> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardBloc>().add(LoadPendingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            // Header với gradient và icon vui nhộn
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.accent],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        Icons.mail,
                        color: AppColors.textLight,
                        size: 28,
                      ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Lời Mời Kết Bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: AppColors.textLight, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content - Hiển thị trực tiếp danh sách lời mời kết bạn
            Expanded(
              child: _buildRequestsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryPink,
                  strokeWidth: 5,
                ),
                SizedBox(height: 16),
                Text(
                  'Đang tải...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        } else if (state is PendingRequestsLoaded) {
          if (state.pendingRequests.isEmpty) {
            return Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.2),
                            AppColors.primaryPink.withOpacity(0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mail_outline_rounded,
                        color: AppColors.primaryBlue,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Chưa có lời mời kết bạn',
                      style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hãy mời bạn bè cùng chơi nhé!',
                      style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: state.pendingRequests.length,
            itemBuilder: (context, index) {
              return _buildRequestItem(state.pendingRequests[index]);
            },
          );
        } else if (state is LeaderboardError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 60,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Oops! Có lỗi rồi',
                    style: TextStyle(
                        color: AppColors.error,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(LoadPendingRequests());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceLight,
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Thử Lại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Center(
          child: Text(
            'Chưa có dữ liệu',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        );
      },
    );
  }

  Widget _buildRequestItem(FriendDto request) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar với viền gradient
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.accent],
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.cardBackground.withOpacity(0.2),
                  backgroundImage: request.friendAccount.avatarUrl != null 
                    ? NetworkImage(request.friendAccount.avatarUrl!)
                    : null,
                  child: request.friendAccount.avatarUrl == null
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
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : null,
                ),
              ),
            ),
            SizedBox(width: 14),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.friendAccount.fullName,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warning.withOpacity(0.2),
                          AppColors.accent.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${request.friendAccount.totalStar}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                Container(
                  width: 90,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.success, AppColors.buttonPrimary],
                      ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(
                        AcceptFriendRequest(request.id),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Đồng ý',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.error, AppColors.error],
                      ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<LeaderboardBloc>().add(
                        DeclineFriendRequest(request.id),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Từ chối',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}