import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/router/app_router.dart';
import '../widgets/branding_background.dart';
import '../widgets/login_form.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Không tạo BlocProvider mới, sử dụng AuthBloc từ main.dart
    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient toàn màn hình (full screen)
          const BrandingBackground(),

          // SafeArea chỉ áp dụng cho content
          SafeArea(
            child: Stack(
              children: [
                // Card chứa form đăng nhập
                const LoginFormCard(),

                // Button quay lại với thiết kế đẹp hơn
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate về auth selection thay vì maybePop() vì stack có thể đã bị clear
                      context.router.pushAndPopUntil(
                        const AuthSelectionRoute(),
                        predicate: (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF002171)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}