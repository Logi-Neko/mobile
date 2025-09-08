import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/color/app_color.dart';
import '../widgets/auth_tab_content.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({super.key});

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Registration form controllers
  final _registrationFormKey = GlobalKey<FormState>();
  final _regUsernameController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regFirstNameController = TextEditingController();
  final _regLastNameController = TextEditingController();
  bool _regObscurePassword = true;
  bool _regIsLoading = false;

  // Login form controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _loginIsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
    _regEmailController.dispose();
    _regFirstNameController.dispose();
    _regLastNameController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _toggleRegPassword() {
    setState(() {
      _regObscurePassword = !_regObscurePassword;
    });
  }

  void _toggleLoginPassword() {
    setState(() {
      _loginObscurePassword = !_loginObscurePassword;
    });
  }

  Future<void> _handleRegistration() async {
    if (!_registrationFormKey.currentState!.validate()) return;

    setState(() {
      _regIsLoading = true;
    });

    try {
      // TODO: Implement registration logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _regIsLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _loginIsLoading = true;
    });

    try {
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loginIsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isHorizontal = screenWidth > screenHeight;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A5ACD),
              Color(0xFF9370DB),
              Color(0xFFBA55D3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 40 : 20,
                    vertical: isHorizontal ? 20 : 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with logo and title
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isHorizontal ? 20 : 24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6A5ACD), Color(0xFF9370DB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isTablet ? 20 : 16),
                              topRight: Radius.circular(isTablet ? 20 : 16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_circle,
                                size: isHorizontal ? 60 : 80,
                                color: Colors.white,
                              ),
                              SizedBox(height: isHorizontal ? 12 : 16),
                              Text(
                                'Chào mừng',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: isHorizontal ? 6 : 8),
                              Text(
                                'Đăng nhập vào tài khoản hoặc tạo tài khoản mới',
                                style: TextStyle(
                                  fontSize: isHorizontal ? 14 : 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        // Tab Bar
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF6A5ACD),
                            unselectedLabelColor: Colors.grey[600],
                            labelStyle: TextStyle(
                              fontSize: isHorizontal ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: isHorizontal ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                            indicator: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A5ACD), Color(0xFF9370DB)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6A5ACD).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: 'Đăng ký'),
                              Tab(text: 'Đăng nhập'),
                            ],
                          ),
                        ),
                        
                        // Tab Content
                        SizedBox(
                          height: 400, // Fixed height for TabBarView
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Registration Tab
                              SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isHorizontal ? 20 : 24,
                                  vertical: isHorizontal ? 16 : 20,
                                ),
                                child: RegistrationTabContent(
                                  formKey: _registrationFormKey,
                                  usernameController: _regUsernameController,
                                  passwordController: _regPasswordController,
                                  emailController: _regEmailController,
                                  firstNameController: _regFirstNameController,
                                  lastNameController: _regLastNameController,
                                  obscurePassword: _regObscurePassword,
                                  isLoading: _regIsLoading,
                                  onTogglePassword: _toggleRegPassword,
                                  onSubmit: _handleRegistration,
                                ),
                              ),
                              
                              // Login Tab
                              SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isHorizontal ? 20 : 24,
                                  vertical: isHorizontal ? 16 : 20,
                                ),
                                child: KeycloakTabContent(
                                  isLoading: _loginIsLoading,
                                  onSubmit: _handleLogin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}