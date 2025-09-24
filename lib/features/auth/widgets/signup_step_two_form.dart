// lib/features/auth/widgets/signup_step_two_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../core/config/logger.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/color/app_color.dart';
import '../bloc/auth_bloc.dart';
import '../dto/signup_request.dart';

class SignUpStepTwoForm extends StatefulWidget {
  final String username;
  final String email;

  const SignUpStepTwoForm({
    super.key,
    required this.username,
    required this.email,
  });

  @override
  State<SignUpStepTwoForm> createState() => _SignUpStepTwoFormState();
}

class _SignUpStepTwoFormState extends State<SignUpStepTwoForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage; // Thêm biến để lưu error message

  @override
  void dispose() {
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Trong hàm _submitRegistration của signup_step_two_form.dart

  void _submitRegistration() {
    logger.i('Submit button clicked!');
    if (_formKey.currentState!.validate()) {
      // 1. Tạo một đối tượng SignUpRequest từ dữ liệu đã thu thập
      final signUpRequest = SignUpRequest(
        username: widget.username,
        email: widget.email,
        fullName: _fullNameController.text,
        password: _passwordController.text,
      );

      // 2. Gửi sự kiện đến BLoC với chỉ 1 đối tượng duy nhất
      context.read<AuthBloc>().add(
        AuthRegisterSubmitted(request: signUpRequest),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          // Đăng ký thành công
          logger.i('✅ Registration successful!');
          setState(() {
            _errorMessage = null; // Clear error khi thành công
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Chuyển đến trang login
          context.router.pushAndPopUntil(
            const LoginRoute(),
            predicate: (route) => false,
          );

        } else if (state is AuthFailure) {
          // Đăng ký thất bại - lưu lỗi vào state để hiển thị
          logger.e('❌ Registration failed: ${state.error}');
          setState(() {
            _errorMessage = state.error;
          });
        } else if (state is AuthLoading) {
          // Clear error khi bắt đầu loading
          setState(() {
            _errorMessage = null;
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
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
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgressBar(),
                      const SizedBox(height: 32),
                      const Text(
                        'Thông tin cá nhân',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),


                      // Trường Họ và Tên
                      TextFormField(
                        controller: _fullNameController,
                        enabled: !isLoading, // Disable khi đang loading
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập đầy đủ họ và tên...',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ và tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Trường Mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading, // Disable khi đang loading
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu của bạn...',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Hiển thị lỗi dưới dạng text field nếu có
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red.shade600,
                                  size: 16,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildActionButtons(context, isLoading),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bước 2 / 2', style: TextStyle(/* ... */)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 1.0, // 100%
            minHeight: 10,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Row(
      children: [
        // Nút Quay lại
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
        // Nút Hoàn thành
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.buttonShadow,
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitRegistration, // Gọi hàm xử lý
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Hoàn thành', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),),
            ),
          ),
        ),
      ],
    );
  }
}
