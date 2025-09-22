// lib/features/auth/forgot_password_screen.dart

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import '../widgets/branding_background.dart';
import '../widgets/forgot_password_form_card.dart';
@RoutePage()
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient toàn màn hình
          const BrandingBackground(),

          // Card chứa form quên mật khẩu (loại bỏ const vì đây là StatefulWidget)
          ForgotPasswordFormCard(),
        ],
      ),
    );
  }
}