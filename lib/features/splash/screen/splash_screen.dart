import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/core/storage/token_storage.dart';
import 'package:logi_neko/core/config/logger.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import 'package:logi_neko/features/auth/bloc/auth_bloc.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  
  final TokenStorage _tokenStorage = TokenStorage.instance;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _logoController.forward();
    _fadeController.forward();
    
    // Check auto-login after a short delay
    _checkAutoLogin();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      logger.i('🔍 Checking auto-login...');
      
      // Check if user is already logged in
      final isLoggedIn = await _tokenStorage.isLoggedIn();
      
      if (isLoggedIn) {
        final refreshToken = await _tokenStorage.getRefreshToken();
        
        if (refreshToken != null) {
          logger.i('🔑 Found refresh token, attempting auto-login...');
          
          // Try to refresh token to validate it's still valid
          if (mounted) {
            final authBloc = context.read<AuthBloc>();
            
            // Listen for auth state changes with a subscription
            StreamSubscription? subscription;
            Timer? timeoutTimer;
            bool hasNavigated = false;
            
            subscription = authBloc.stream.listen((state) {
              if (hasNavigated) return; // Prevent multiple navigations
              
              if (state is AuthRefreshTokenSuccess) {
                logger.i('✅ Auto-login successful - navigating to home');
                hasNavigated = true;
                subscription?.cancel();
                timeoutTimer?.cancel();
                if (mounted) {
                  context.router.pushAndPopUntil(
                    const HomeRoute(),
                    predicate: (route) => false,
                  );
                }
              } else if (state is AuthFailure) {
                logger.w('❌ Auto-login failed: ${state.error}');
                hasNavigated = true;
                subscription?.cancel();
                timeoutTimer?.cancel();
                _tokenStorage.clearRefreshToken().then((_) {
                  if (mounted) {
                    _navigateToStart();
                  }
                });
              }
            });
            
            // Add timeout to prevent infinite waiting
            timeoutTimer = Timer(const Duration(seconds: 10), () {
              if (!hasNavigated) {
                hasNavigated = true;
                subscription?.cancel();
                if (mounted) {
                  logger.w('⏰ Auto-login timeout - navigating to start');
                  _navigateToStart();
                }
              }
            });
            
            // Trigger refresh token
            authBloc.add(
              AuthRefreshTokenSubmitted(refreshToken: refreshToken),
            );
          }
        } else {
          logger.i('❌ No refresh token found');
          _navigateToStart();
        }
      } else {
        logger.i('❌ User not logged in');
        _navigateToStart();
      }
    } catch (e) {
      logger.e('❌ Error during auto-login check: $e');
      _navigateToStart();
    }
  }

  void _navigateToStart() {
    if (mounted) {
      context.router.pushAndPopUntil(
        const StartRoute(),
        predicate: (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/shared/assets/images/LOGO.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App name with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'LogiNeko',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'LEARN FROM HOME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Loading text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Đang kiểm tra đăng nhập...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}