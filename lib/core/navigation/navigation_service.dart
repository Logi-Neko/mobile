// lib/core/navigation/navigation_service.dart

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../config/logger.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  // Store reference to app router context
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> navigateToLogin() async {
    try {
      if (_context != null) {
        // Sử dụng auto_route để navigate về login và clear stack
        _context!.router.pushAndPopUntil(
          '/login' as PageRouteInfo,
          predicate: (route) => false,
        );
        logger.i('🔄 Navigated to login screen');
      } else {
        logger.e('❌ Navigation context is null');
      }
    } catch (e) {
      logger.e('❌ Error navigating to login: $e');
    }
  }

  Future<void> showTokenExpiredDialog() async {
    try {
      if (_context != null) {
        await showDialog(
          context: _context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Phiên đăng nhập hết hạn'),
              content: const Text('Vui lòng đăng nhập lại để tiếp tục sử dụng.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    navigateToLogin();
                  },
                  child: const Text('Đăng nhập lại'),
                ),
              ],
            );
          },
        );
      } else {
        logger.e('❌ Cannot show dialog - context is null');
        navigateToLogin();
      }
    } catch (e) {
      logger.e('❌ Error showing token expired dialog: $e');
      // Fallback: navigate directly to login
      navigateToLogin();
    }
  }
}
