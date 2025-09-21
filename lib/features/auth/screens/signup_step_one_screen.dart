// lib/features/auth/signup_step_one_screen.dart

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

import '../../login/widgets/branding_background.dart';
import '../widgets/signup_step_one_form.dart';
@RoutePage()
class SignUpStepOneScreen extends StatelessWidget {
  const SignUpStepOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          // Nền gradient toàn màn hình
          BrandingBackground(),

          // Card chứa form đăng ký bước 1
          SignUpStepOneForm(),
        ],
      ),
    );
  }
}