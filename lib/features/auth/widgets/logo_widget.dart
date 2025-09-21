import 'package:flutter/material.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 136,
        height: 136,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'lib/shared/assets/images/LOGO.jpg',
            fit: BoxFit.cover,
          ),
        )
    );
  }
}
