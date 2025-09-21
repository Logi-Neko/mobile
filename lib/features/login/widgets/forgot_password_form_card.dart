// lib/features/auth/widgets/forgot_password_form_card.dart

import 'package:flutter/material.dart';

import '../../../shared/color/app_color.dart';

class ForgotPasswordFormCard extends StatelessWidget {
  const ForgotPasswordFormCard({super.key});

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
              const Icon(
                Icons.email_outlined,
                color: AppColors.primaryPurple,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Quên mật khẩu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nhập tên đăng nhập của bạn và chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // Trường Username/Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  hintText: 'Nhập tên đăng nhập của bạn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                ),
              ),
              const SizedBox(height: 32),

              // Nút Gửi yêu cầu
              _buildSubmitButton(),
              const SizedBox(height: 16),

              // Nút Quay lại đăng nhập
              TextButton(
                onPressed: () {
                  // Xử lý điều hướng quay lại màn hình đăng nhập
                  Navigator.of(context).pop(); // Cách cơ bản
                },
                child: const Text(
                  'Quay lại đăng nhập',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: () {
          // Xử lý logic gửi yêu cầu quên mật khẩu
          print('Gửi yêu cầu quên mật khẩu');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'GỬI YÊU CẦU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}