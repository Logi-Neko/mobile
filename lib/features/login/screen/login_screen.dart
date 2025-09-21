import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import '../widgets/branding_background.dart';
import '../widgets/login_form.dart';
@RoutePage()
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          // Nền gradient toàn màn hình
          BrandingBackground(),

          // Card chứa form đăng nhập
          LoginFormCard(),
        ],
      ),
    );
  }
}