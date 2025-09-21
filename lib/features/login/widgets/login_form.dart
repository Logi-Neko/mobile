// lib/features/auth/widgets/login_form_card.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/color/app_color.dart';

class LoginFormCard extends StatefulWidget {
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32.0),
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Đăng nhập',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Trường Username
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10), // khoảng trống 2 bên
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    hintText: 'Nhập tên đăng nhập...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                  ),
                ),
              ),
              const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // khoảng trống 2 bên
            child:
              TextFormField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground, // Màu nền cho input field
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.router.push(const ForgotPasswordRoute());
                    print('Điều hướng đến màn hình Quên mật khẩu');
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: ),

              // Nút Đăng nhập chính
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // khoảng trống 2 bên
            child:
              _buildLoginButton()
              ),
              const SizedBox(height: 16), // Giảm khoảng cách cho vừa màn hình

              // Nút Đăng nhập với Google
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10), // khoảng trống 2 bên
                  child:
                  _buildGoogleLoginButton()
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: () {
          // Xử lý logic đăng nhập ở đây
          print('Đăng nhập');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Nền trong suốt để hiển thị gradient
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Xử lý logic đăng nhập Google ở đây
        print('Đăng nhập với Google');
      },
      icon: Image.asset('lib/shared/assets/images/google.jpg', height: 16.0), // Đảm bảo có logo Google trong assets
      label: const Text(
        'Đăng nhập với Google',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.textLight), // Viền nhẹ
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}