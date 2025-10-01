// lib/features/auth/widgets/signup_step_one_form.dart

import 'package:flutter/material.dart';
import '../../../shared/color/app_color.dart';
import '../screens/signup_step_two_screen.dart';

class SignUpStepOneForm extends StatefulWidget {
  const SignUpStepOneForm({super.key});

  @override
  State<SignUpStepOneForm> createState() => _SignUpStepOneFormState();
}

class _SignUpStepOneFormState extends State<SignUpStepOneForm> {
  // Tạo controller để lấy và quản lý dữ liệu text
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  // Hủy các controller khi widget không còn được sử dụng để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    // 4. Kiểm tra xem Form có hợp lệ không
    if (_formKey.currentState!.validate()) {
      // Nếu hợp lệ, lấy dữ liệu và điều hướng
      final username = _usernameController.text;
      final email = _emailController.text;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SignUpStepTwoScreen(
            username: username,
            email: email,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28.0),
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
        child: Form(
          key: _formKey, // Gán key cho Form
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 16),
              const Text(
                'Tạo tài khoản',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Trường Tên đăng nhập
              TextFormField(
                controller: _usernameController, // Gán controller
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  hintText: 'Nhập tên đăng nhập...',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null; // Hợp lệ
                },
              ),
              const SizedBox(height: 10),

              // Trường Email
              TextFormField(
                controller: _emailController, // Gán controller
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn...',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  // Kiểm tra định dạng email đơn giản
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Vui lòng nhập một email hợp lệ';
                  }
                  return null; // Hợp lệ
                },
              ),
              const SizedBox(height: 20),

              // Các nút bấm
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bước 1 / 2',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.5,
            minHeight: 5,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.textLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.buttonShadow,
            ),
            child: ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tiếp theo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}