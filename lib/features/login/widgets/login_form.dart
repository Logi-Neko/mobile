// lib/features/auth/widgets/login_form_card.dart

import 'dart:math' as logger;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/google_sign_in_service.dart';
import '../../../shared/color/app_color.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/dto/login_request.dart';

class LoginFormCard extends StatefulWidget {
  const LoginFormCard({super.key});

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage; // Thêm biến để lưu error message

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          // Đăng nhập thành công (cả login thường và Google login)
          setState(() {
            _errorMessage = null; // Clear error khi thành công
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to home screen - xóa toàn bộ stack và chuyển về home
          // context.router.pushAndClearStack(const HomeRoute());
        } else if (state is AuthFailure) {
          // Đăng nhập thất bại - lưu lỗi vào state để hiển thị
          setState(() {
            _errorMessage = state.error; // Sử dụng state.error thay vì state.message
          });

          // Hiện snackbar cho lỗi Google login để user biết
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thất bại: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is AuthLoading) {
          // Clear error khi bắt đầu loading
          setState(() {
            _errorMessage = null;
          });
        }
      },
      child: Form(
        key: _formKey,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: screenHeight * 0.9,
              minHeight: 300,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header chỉ có title
                  const Text(
                    'Đăng nhập',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Trường Username với validation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Tên đăng nhập',
                        hintText: 'Nhập tên đăng nhập...',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Trường Password với validation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu...',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  // Quên mật khẩu - giảm size
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.router.push(const ForgotPasswordRoute());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  // Hiển thị lỗi dưới dạng text field nếu có
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
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
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Nút Đăng nhập với loading state
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildLoginButton()
                  ),
                  const SizedBox(height: 16),

                  // Đăng nhập với social media - giảm size
                  _buildSocialLoginSection(),

                  // Thêm padding bottom để tránh bị che bởi keyboard
                  SizedBox(height: keyboardHeight > 0 ? 10 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppColors.buttonShadow,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () {
              if (_formKey.currentState!.validate()) {
                // Lấy dữ liệu từ form và tạo Map
                final loginData = {
                  'username': _usernameController.text.trim(),
                  'password': _passwordController.text.trim(),
                };

                // Gọi Bloc để thực hiện đăng nhập
                context.read<AuthBloc>().add(
                  AuthLoginSubmitted(loginData: loginData),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          );
      },
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        const Text(
          'Hoặc đăng nhập bằng',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12, // Giảm từ 14 xuống 12
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8), // Giảm từ 16 xuống 12
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGoogleIcon(),
            const SizedBox(width: 16), // Giảm từ 24 xuống 16
            _buildFacebookIcon(),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return GestureDetector(
          onTap: isLoading ? null : () async {
            try {
              // Clear error trước khi bắt đầu
              setState(() {
                _errorMessage = null;
              });

              // Thực hiện Google Sign-In
              final String? idToken = await GoogleSignInService.instance.signInWithGoogle();

              if (idToken != null) {
                // Gửi ID token đến BLoC để xử lý đăng nhập
                context.read<AuthBloc>().add(
                  AuthGoogleLoginSubmitted(idToken: idToken),
                );
              } else {
                // User cancelled Google Sign-In hoặc có lỗi
                setState(() {
                  _errorMessage = 'Đăng nhập Google bị hủy hoặc thất bại';
                });
              }
            } catch (e) {
              // Xử lý lỗi Google Sign-In
              logger.e;
              setState(() {
                if (e.toString().contains('PlatformException') || e.toString().contains('channel-error')) {
                  _errorMessage = 'Google Sign-In chưa được cấu hình đầy đủ. Vui lòng sử dụng đăng nhập thông thường.';
                } else {
                  _errorMessage = 'Lỗi đăng nhập Google: ${e.toString()}';
                }
              });
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLoading ? Colors.grey.shade300 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/shared/assets/images/google.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFacebookIcon() {
    return GestureDetector(
      onTap: () {
        // Xử lý logic đăng nhập Facebook ở đây
        print('Đăng nhập với Facebook');
      },
      child: Container(
        width: 40, // Giảm từ 48 xuống 40
        height: 40, // Giảm từ 48 xuống 40
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6, // Giảm từ 8 xuống 6
              offset: const Offset(0, 3), // Giảm từ 4 xuống 3
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Giảm từ 10 xuống 8
          child: ClipOval(
            child: Image.asset(
              'lib/shared/assets/images/facebook.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
