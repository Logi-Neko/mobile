import 'package:flutter/material.dart';
import '../../../shared/color/app_color.dart';
import 'auth_button.dart';

class AuthOptionsSection extends StatelessWidget {
  final VoidCallback onSignUpTap;
  final VoidCallback onLoginTap;

  const AuthOptionsSection({
    Key? key,
    required this.onSignUpTap,
    required this.onLoginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Center(
          child: Container(
            width: isSmallScreen ? screenWidth * 0.9 : 500,
            margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
            child: Card(
              elevation: 20,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bắt đầu ngay',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 15),
                      Text(
                        'Chọn một tùy chọn để tiếp tục',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 15),
                      AnimatedAuthButton(
                        title: 'Đăng ký',
                        subtitle: 'Tạo tài khoản mới',
                        icon: Icons.person_add,
                        isPrimary: true,
                        onTap: onSignUpTap,
                        isCompact: isSmallScreen,
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 20),

                      AnimatedAuthButton(
                        title: 'Đăng nhập',
                        subtitle: 'Đã có tài khoản',
                        icon: Icons.login,
                        isPrimary: false,
                        onTap: onLoginTap,
                        isCompact: isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
