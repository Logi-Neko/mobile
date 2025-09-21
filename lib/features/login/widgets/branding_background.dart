import 'package:flutter/material.dart';

import '../../../shared/color/app_color.dart';

class BrandingBackground extends StatelessWidget {
  const BrandingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          // Hiệu ứng ngôi sao nhỏ (dots)
          Positioned(
            top: 50,
            left: 50,
            child: _buildStarDot(),
          ),
          Positioned(
            bottom: 30,
            left: 100,
            child: _buildStarDot(),
          ),
          Positioned(
            top: 20,
            right: 80,
            child: _buildStarDot(),
          ),
          Positioned(
            bottom: 80,
            right: 50,
            child: _buildStarDot(),
          ),
        ],
      ),
    );
  }

  Widget _buildStarDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}