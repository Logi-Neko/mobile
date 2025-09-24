// lib/core/services/google_sign_in_service.dart

import 'package:google_sign_in/google_sign_in.dart';
import '../config/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  static GoogleSignInService get instance => _instance;

  GoogleSignIn? _googleSignIn;

  /// Khởi tạo Google Sign-In với cấu hình từ .env
  void initialize() {
    try {
      final String? clientId = dotenv.env['GOOGLE_CLIENT_ID'];

      if (clientId == null || clientId.isEmpty) {
        logger.e('❌ GOOGLE_CLIENT_ID not found in .env file');
        throw Exception('GOOGLE_CLIENT_ID is required for Google Sign-In');
      }

      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid', // Required for ID token
        ],
        // serverClientId để lấy ID token
        serverClientId: clientId,
      );

      logger.i('✅ Google Sign-In initialized with client ID: ${_maskClientId(clientId)}');
    } catch (e) {
      logger.e('❌ Failed to initialize Google Sign-In: $e');
      rethrow;
    }
  }

  /// Thực hiện đăng nhập Google và trả về ID token
  Future<String?> signInWithGoogle() async {
    if (_googleSignIn == null) {
      logger.e('❌ Google Sign-In not initialized. Call initialize() first.');
      throw Exception('Google Sign-In service not initialized');
    }

    try {
      logger.i('🔄 Starting Google Sign-In flow...');

      // Bước 1: Đăng nhập và lấy thông tin user
      final GoogleSignInAccount? account = await _googleSignIn!.signIn();

      if (account == null) {
        logger.w('⚠️ User cancelled Google Sign-In');
        return null;
      }

      logger.i('✅ User signed in: ${account.email}');

      // Bước 2: Lấy authentication tokens
      final GoogleSignInAuthentication auth = await account.authentication;

      // Bước 3: Trả về ID token
      if (auth.idToken != null && auth.idToken!.isNotEmpty) {
        logger.i('🔐 ID token retrieved successfully');
        logger.i('📝 ID token: ${auth.idToken!.substring(0, 20)}...');
        return auth.idToken;
      } else {
        logger.e('❌ No ID token received from Google');
        throw Exception('Failed to retrieve ID token from Google');
      }

    } catch (error) {
      logger.e('❌ Google Sign-In failed: $error');

      // Xử lý các lỗi phổ biến với hướng dẫn cụ thể
      if (error.toString().contains('ApiException: 10')) {
        logger.e('🔧 Configuration Error: Please ensure:');
        logger.e('   • OAuth 2.0 Client ID is created in Google Cloud Console');
        logger.e('   • Package name: com.example.logi_neko');
        logger.e('   • SHA-1 fingerprint is registered');
        logger.e('   • Google Sign-In API is enabled in your project');

        // Ném exception với thông báo rõ ràng cho user
        throw Exception(
          'Google Sign-In chưa được cấu hình. Vui lòng liên hệ nhà phát triển để hoàn tất thiết lập OAuth 2.0 Client ID.'
        );
      } else if (error.toString().contains('network_error') ||
                 error.toString().contains('NETWORK_ERROR')) {
        throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.');
      } else if (error.toString().contains('sign_in_canceled')) {
        // Đây không phải lỗi, user đã hủy
        return null;
      }

      // Ném lại lỗi gốc nếu không xử lý được
      throw Exception('Đăng nhập Google thất bại: ${error.toString()}');
    }
  }

  /// Đăng xuất khỏi Google
  Future<void> signOut() async {
    if (_googleSignIn == null) {
      logger.w('⚠️ Google Sign-In not initialized');
      return;
    }

    try {
      await _googleSignIn!.signOut();
      logger.i('✅ Successfully signed out from Google');
    } catch (error) {
      logger.e('❌ Error signing out: $error');
      rethrow;
    }
  }

  /// Ngắt kết nối hoàn toàn khỏi Google
  Future<void> disconnect() async {
    if (_googleSignIn == null) {
      logger.w('⚠️ Google Sign-In not initialized');
      return;
    }

    try {
      await _googleSignIn!.disconnect();
      logger.i('✅ Successfully disconnected from Google');
    } catch (error) {
      logger.e('❌ Error disconnecting: $error');
      rethrow;
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<bool> isSignedIn() async {
    if (_googleSignIn == null) return false;
    return await _googleSignIn!.isSignedIn();
  }

  /// Lấy thông tin user hiện tại
  GoogleSignInAccount? get currentUser => _googleSignIn?.currentUser;

  /// Che giấu một phần client ID để bảo mật log
  String _maskClientId(String clientId) {
    if (clientId.length <= 20) return '${clientId.substring(0, 8)}***';
    return '${clientId.substring(0, 12)}***${clientId.substring(clientId.length - 8)}';
  }

  /// Kiểm tra xem service đã được khởi tạo chưa
  bool get isInitialized => _googleSignIn != null;
}
