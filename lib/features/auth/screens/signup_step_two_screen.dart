// lib/features/auth/signup_step_two_screen.dart

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import '../../login/widgets/branding_background.dart';
import '../widgets/signup_step_two_form.dart';
@RoutePage()
class SignUpStepTwoScreen extends StatelessWidget {
  final String username;
  final String email;

  const SignUpStepTwoScreen({
    super.key,
    @PathParam('username') required this.username,
    // Annotation để auto_route biết 'email' đến từ path
    @PathParam('email') required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BrandingBackground(),
          SignUpStepTwoForm(
            username: username,
            email: email,
          ),
        ],
      ),
    );
  }
}