import 'package:flutter/material.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/ui/widgets/user_detail_dialog.dart';
import 'package:auto_route/auto_route.dart';

class HeaderWidget extends StatelessWidget {
  final User? user;
  final bool isUpdating;

  const HeaderWidget({
    Key? key,
    this.user,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              children: [
                _buildUserInfo(context, constraints.maxWidth),
                const SizedBox(width: 8),
                _buildRightSection(context, constraints.maxWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(BuildContext context, double screenWidth) {
    final isSmallScreen = screenWidth < 800;

    return Expanded(
      flex: 2,
      child: GestureDetector(
        onTap: () {
          if (user != null) {
            UserDetailDialog.show(context, user!);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF5C6BC0),
                const Color(0xFF5C6BC0).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5C6BC0).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isSmallScreen ? 36 : 40,
                height: isSmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.orange.shade700],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  image: user?.avatarUrl != null
                      ? DecorationImage(
                    image: NetworkImage(user!.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                      : const DecorationImage(
                    image: AssetImage("lib/shared/assets/images/LOGO.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            user?.fullName ?? 'Người dùng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUpdating) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: isSmallScreen ? 10 : 12,
                            height: isSmallScreen ? 10 : 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                      const SizedBox(height: 2),
                      Text(
                        user?.displayAge ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightSection(BuildContext context, double screenWidth) {
    final isVerySmallScreen = screenWidth < 800;

    return Expanded(
      flex: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildStarContainer(isVerySmallScreen),
          SizedBox(width: isVerySmallScreen ? 4 : 6),

          if (screenWidth > 360) ...[
            _buildMyCharacter(context, isVerySmallScreen),
            SizedBox(width: isVerySmallScreen ? 4 : 6),
          ],

          if (screenWidth > 400) ...[
            _buildParentContainer(context, isVerySmallScreen),
            SizedBox(width: isVerySmallScreen ? 4 : 6),
          ],

          // Premium - luôn hiển thị
          _buildPremiumContainer(context, isVerySmallScreen),
        ],
      ),
    );
  }

  Widget _buildStarContainer(bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isVerySmallScreen ? 10 : 12,
          vertical: 12
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF8C42),
            const Color(0xFFFF8C42).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isVerySmallScreen ? 22 : 24,
            height: isVerySmallScreen ? 22 : 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: Colors.white,
              size: isVerySmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 6 : 8),
          Text(
            user?.starDisplay ?? '0',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentContainer(BuildContext context, bool isVerySmallScreen) {
    return GestureDetector(
        onTap: () {
          if (user?.id != null) {
            context.router.push(
              LearningReportRoute(accountId: user!.id),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 10 : 12,
              vertical: 12
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF9575CD), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isVerySmallScreen ? 22 : 24,
                height: isVerySmallScreen ? 22 : 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C42),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people,
                  color: Colors.white,
                  size: isVerySmallScreen ? 12 : 14,
                ),
              ),
              SizedBox(width: isVerySmallScreen ? 6 : 8),
              Text(
                "Phụ huynh",
                style: TextStyle(
                  color: Color(0xFF5C6BC0),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildPremiumContainer(BuildContext context, bool isVerySmallScreen) {
    return GestureDetector(
      onTap: () {
        context.router.push(const SubscriptionRoute());
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 10 : 12,
            vertical: 12
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF8C42),
              Colors.deepOrange.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isVerySmallScreen ? 22 : 24,
              height: isVerySmallScreen ? 22 : 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: isVerySmallScreen ? 12 : 14,
              ),
            ),
            SizedBox(width: isVerySmallScreen ? 6 : 8),
            Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCharacter(BuildContext context, bool isVerySmallScreen) {
    return GestureDetector(
      onTap: () {
        context.router.push(const MyCharacterRoute());
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 10 : 12,
            vertical: 12
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9C27B0),
              const Color(0xFF7B1FA2),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isVerySmallScreen ? 22 : 24,
              height: isVerySmallScreen ? 22 : 24,
              decoration: BoxDecoration(
                color: const Color(0xFFBA68C8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections,
                color: Colors.white,
                size: isVerySmallScreen ? 12 : 14,
              ),
            ),
            SizedBox(width: isVerySmallScreen ? 6 : 8),
            Text(
              isVerySmallScreen ? "BST" : "Bộ sưu tập",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderLoadingWidget extends StatelessWidget {
  const HeaderLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return Row(
          children: [
            _buildLoadingUserInfo(isSmallScreen),
            const SizedBox(width: 8),
            _buildLoadingRightSection(isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildLoadingUserInfo(bool isSmallScreen) {
    return Expanded(
      flex: isSmallScreen ? 2 : 3,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 10
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF5C6BC0).withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmallScreen ? 28 : 35,
              height: isSmallScreen ? 28 : 35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 17.5),
              ),
              child: Center(
                child: SizedBox(
                  width: isSmallScreen ? 16 : 20,
                  height: isSmallScreen ? 16 : 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5C6BC0)),
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading placeholder for name
                  Container(
                    width: isSmallScreen ? 60 : 80,
                    height: isSmallScreen ? 12 : 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (!isSmallScreen) ...[
                    const SizedBox(height: 4),
                    // Loading placeholder for age
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingRightSection(bool isSmallScreen) {
    return Expanded(
      flex: isSmallScreen ? 3 : 5,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading star count
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C42).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB74D),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: isSmallScreen ? 10 : 14,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Container(
                    width: isSmallScreen ? 16 : 20,
                    height: isSmallScreen ? 10 : 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),

            // Loading premium status
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: isSmallScreen ? 10 : 14,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Container(
                    width: isSmallScreen ? 24 : 30,
                    height: isSmallScreen ? 10 : 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
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
}

// Header Error Widget - hiển thị khi có lỗi nhưng vẫn muốn show header
class HeaderErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const HeaderErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return Row(
          children: [
            _buildErrorUserInfo(isSmallScreen),
            const SizedBox(width: 8),
            _buildErrorRightSection(isSmallScreen),
          ],
        );
      },
    );
  }

  Widget _buildErrorUserInfo(bool isSmallScreen) {
    return Expanded(
      flex: isSmallScreen ? 2 : 3,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 10
        ),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onRetry,
              child: Container(
                width: isSmallScreen ? 28 : 35,
                height: isSmallScreen ? 28 : 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 17.5),
                ),
                child: Icon(
                  Icons.refresh,
                  color: Colors.red.shade400,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lỗi tải dữ liệu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isSmallScreen)
                    Text(
                      'Nhấn để thử lại',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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

  Widget _buildErrorRightSection(bool isSmallScreen) {
    return Expanded(
      flex: isSmallScreen ? 3 : 5,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error star count
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_border,
                      color: Colors.white,
                      size: isSmallScreen ? 10 : 14,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    '--',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 4 : 8),

            // Error premium status
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: isSmallScreen ? 10 : 14,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 10 : 12,
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
}