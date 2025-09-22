// lib/core/storage/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/logger.dart';
import '../../features/auth/dto/login_response.dart';
import '../../features/auth/dto/signup_response.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _avatarUrlKey = 'avatar_url';

  static TokenStorage? _instance;
  static TokenStorage get instance => _instance ??= TokenStorage._();

  TokenStorage._();

  // Khởi tạo secure storage với các options bảo mật
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  /// Lưu access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: token);
      logger.d('✅ Access token saved securely');
    } catch (e) {
      logger.e('❌ Failed to save access token: $e');
      throw Exception('Failed to save access token');
    }
  }

  /// Lưu refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
      logger.d('✅ Refresh token saved securely');
    } catch (e) {
      logger.e('❌ Failed to save refresh token: $e');
      throw Exception('Failed to save refresh token');
    }
  }

  /// Lưu cả 2 tokens cùng lúc
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      logger.d('✅ Both tokens saved securely');
    } catch (e) {
      logger.e('❌ Failed to save tokens: $e');
      throw Exception('Failed to save tokens');
    }
  }

  /// Lấy access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: _accessTokenKey);
      logger.d('📱 Access token retrieved: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      logger.e('❌ Failed to get access token: $e');
      return null;
    }
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: _refreshTokenKey);
      logger.d('📱 Refresh token retrieved: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      logger.e('❌ Failed to get refresh token: $e');
      return null;
    }
  }

  /// Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final isLoggedIn = accessToken != null && refreshToken != null;
      logger.d('🔐 User logged in: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      logger.e('❌ Failed to check login status: $e');
      return false;
    }
  }

  /// Lưu thông tin từ TokenResponse (chỉ có tokens)
  Future<void> saveTokenResponse(TokenResponse tokenResponse) async {
    try {
      await saveTokens(tokenResponse.accessToken, tokenResponse.refreshToken);
      logger.d('✅ Token response saved securely');
    } catch (e) {
      logger.e('❌ Failed to save token response: $e');
      throw Exception('Failed to save token response');
    }
  }

  /// Lưu thông tin user từ SignupResponse (từ getUserInfo API)
  Future<void> saveUserInfoFromResponse(SignupResponse userResponse) async {
    try {
      final futures = <Future<void>>[
        _secureStorage.write(key: _userIdKey, value: userResponse.id.toString()),
        _secureStorage.write(key: _usernameKey, value: userResponse.username),
        _secureStorage.write(key: _emailKey, value: userResponse.email),
        _secureStorage.write(key: _fullNameKey, value: userResponse.fullName),
      ];

      await Future.wait(futures);
      logger.d('✅ User info saved securely from API response: ${userResponse.username}');
    } catch (e) {
      logger.e('❌ Failed to save user info from response: $e');
      throw Exception('Failed to save user info from response');
    }
  }

  /// Lưu thông tin user từ parameters riêng lẻ (backward compatibility)
  Future<void> saveUserInfo({
    required String userId,
    required String username,
    String? email,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final futures = <Future<void>>[
        _secureStorage.write(key: _userIdKey, value: userId),
        _secureStorage.write(key: _usernameKey, value: username),
      ];

      if (email != null) {
        futures.add(_secureStorage.write(key: _emailKey, value: email));
      }
      if (fullName != null) {
        futures.add(_secureStorage.write(key: _fullNameKey, value: fullName));
      }
      if (avatarUrl != null) {
        futures.add(_secureStorage.write(key: _avatarUrlKey, value: avatarUrl));
      }

      await Future.wait(futures);
      logger.d('✅ User info saved securely: $username');
    } catch (e) {
      logger.e('❌ Failed to save user info: $e');
      throw Exception('Failed to save user info');
    }
  }

  /// Lấy user ID
  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _userIdKey);
    } catch (e) {
      logger.e('❌ Failed to get user ID: $e');
      return null;
    }
  }

  /// Lấy username
  Future<String?> getUsername() async {
    try {
      return await _secureStorage.read(key: _usernameKey);
    } catch (e) {
      logger.e('❌ Failed to get username: $e');
      return null;
    }
  }

  /// Lấy email
  Future<String?> getEmail() async {
    try {
      return await _secureStorage.read(key: _emailKey);
    } catch (e) {
      logger.e('❌ Failed to get email: $e');
      return null;
    }
  }

  /// Lấy full name
  Future<String?> getFullName() async {
    try {
      return await _secureStorage.read(key: _fullNameKey);
    } catch (e) {
      logger.e('❌ Failed to get full name: $e');
      return null;
    }
  }

  /// Lấy avatar URL
  Future<String?> getAvatarUrl() async {
    try {
      return await _secureStorage.read(key: _avatarUrlKey);
    } catch (e) {
      logger.e('❌ Failed to get avatar URL: $e');
      return null;
    }
  }

  /// Xóa access token
  Future<void> clearAccessToken() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      logger.d('🗑️ Access token cleared');
    } catch (e) {
      logger.e('❌ Failed to clear access token: $e');
    }
  }

  /// Xóa refresh token
  Future<void> clearRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
      logger.d('🗑️ Refresh token cleared');
    } catch (e) {
      logger.e('❌ Failed to clear refresh token: $e');
    }
  }

  /// Xóa tất cả tokens và thông tin user (logout)
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _userIdKey),
        _secureStorage.delete(key: _usernameKey),
        _secureStorage.delete(key: _emailKey),
        _secureStorage.delete(key: _fullNameKey),
        _secureStorage.delete(key: _avatarUrlKey),
      ]);
      logger.d('🗑️ All user data cleared securely');
    } catch (e) {
      logger.e('❌ Failed to clear all data: $e');
      throw Exception('Failed to clear user data');
    }
  }

  /// Lưu thông tin đăng nhập hoàn chỉnh (tokens + user info)
  Future<void> saveCompleteLoginData({
    required TokenResponse tokenResponse,
    required String userId,
    required String username,
    String? email,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      await Future.wait([
        saveTokenResponse(tokenResponse),
        saveUserInfo(
          userId: userId,
          username: username,
          email: email,
          fullName: fullName,
          avatarUrl: avatarUrl,
        ),
      ]);
      logger.d('✅ Complete login data saved securely for user: $username');
    } catch (e) {
      logger.e('❌ Failed to save complete login data: $e');
      throw Exception('Failed to save complete login data');
    }
  }

  /// Lấy tất cả thông tin user và tokens
  Future<Map<String, String?>> getAllUserData() async {
    try {
      final data = await Future.wait([
        getAccessToken(),
        getRefreshToken(),
        getUserId(),
        getUsername(),
        getEmail(),
        getFullName(),
        getAvatarUrl(),
      ]);

      return {
        'accessToken': data[0],
        'refreshToken': data[1],
        'userId': data[2],
        'username': data[3],
        'email': data[4],
        'fullName': data[5],
        'avatarUrl': data[6],
      };
    } catch (e) {
      logger.e('❌ Failed to get all user data: $e');
      return {};
    }
  }

  /// Chỉ lưu tokens từ refresh (không thay đổi user info)
  Future<void> updateTokensOnly(String accessToken, String refreshToken) async {
    try {
      await saveTokens(accessToken, refreshToken);
      logger.d('✅ Tokens updated without changing user info');
    } catch (e) {
      logger.e('❌ Failed to update tokens: $e');
      throw Exception('Failed to update tokens');
    }
  }

  /// Kiểm tra có user info hay chưa (để biết có cần gọi userinfo API không)
  Future<bool> hasUserInfo() async {
    try {
      final userId = await getUserId();
      final username = await getUsername();
      return userId != null && username != null;
    } catch (e) {
      logger.e('❌ Failed to check user info: $e');
      return false;
    }
  }
}
