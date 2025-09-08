import 'package:flutter/material.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import 'auth_form_field.dart';
import 'auth_button.dart';

class RegistrationTabContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const RegistrationTabContent({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Title
          const _FormHeader(
            title: 'Tạo tài khoản mới',
            subtitle: 'Điền thông tin chi tiết để đăng ký',
          ),
          
          // Form Fields
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 500;
              
              if (isWideScreen) {
                return _WideScreenLayout(
                  firstNameController: firstNameController,
                  usernameController: usernameController,
                  emailController: emailController,
                  lastNameController: lastNameController,
                  passwordController: passwordController,
                  obscurePassword: obscurePassword,
                  onTogglePassword: onTogglePassword,
                  isLoading: isLoading,
                  onSubmit: onSubmit,
                );
              } else {
                return _MobileLayout(
                  usernameController: usernameController,
                  emailController: emailController,
                  firstNameController: firstNameController,
                  lastNameController: lastNameController,
                  passwordController: passwordController,
                  obscurePassword: obscurePassword,
                  onTogglePassword: onTogglePassword,
                  isLoading: isLoading,
                  onSubmit: onSubmit,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class KeycloakTabContent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const KeycloakTabContent({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Form title
        const _FormHeader(
          title: 'Đăng nhập',
          subtitle: 'Đăng nhập bảo mật với tổ chức của bạn',
        ),
        
        // SSO info section
        const _SSOInfoSection(),
        const SizedBox(height: 40),
        
        // Keycloak login button
        Center( 
          child: AuthButton(
            text: 'Đăng nhập',
            icon: Icons.security_rounded,
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Additional info
        Text(
          'Bạn sẽ được chuyển hướng đến trang đăng nhập\ncủa tổ chức để xác thực',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideScreenLayout extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController lastNameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _WideScreenLayout({
    required this.firstNameController,
    required this.usernameController,
    required this.emailController,
    required this.lastNameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
                  AuthFormField(
                    controller: firstNameController,
                    label: 'Họ',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AuthFormField(
                    controller: usernameController,
                    label: 'Tên đăng nhập',
                    icon: Icons.account_circle_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      if (value.length < 3) {
                        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AuthFormField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email của bạn';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
                        return 'Vui lòng nhập email hợp lệ';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right column
            Expanded(
              child: Column(
                children: [
                  AuthFormField(
                    controller: lastNameController,
                    label: 'Tên',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên của bạn';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AuthFormField(
                    controller: passwordController,
                    label: 'Mật khẩu',
                    icon: Icons.lock_outline_rounded,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
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
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: AuthButton(
            text: 'Đăng ký',
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const _MobileLayout({
    required this.usernameController,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthFormField(
          controller: usernameController,
          label: 'Tên đăng nhập',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên đăng nhập';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AuthFormField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email của bạn';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(value)) {
              return 'Vui lòng nhập email hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AuthFormField(
          controller: firstNameController,
          label: 'Họ',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ của bạn';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AuthFormField(
          controller: lastNameController,
          label: 'Tên',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên của bạn';
            }
            return null;
          },
        ),
        const SizedBox(height: 18),
        AuthFormField(
          controller: passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
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
        const SizedBox(height: 24),
        Center(
          child: AuthButton(
            text: 'Đăng ký',
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}



class _SSOInfoSection extends StatelessWidget {
  const _SSOInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.security_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const Text(
          'Keycloak SSO',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Xác thực bảo mật\nvới tổ chức của bạn',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}