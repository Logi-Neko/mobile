import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/friendship_dto.dart';

class FriendshipApi {
  static const String _friendshipEndpoint = '/api/friendship';

  // Cache đơn giản
  static List<FriendDto>? _friendsCache;
  static DateTime? _friendsCacheTime;
  static List<FriendDto>? _pendingCache;
  static DateTime? _pendingCacheTime;

  /// Gửi lời mời kết bạn
  static Future<ApiResponse<String>> sendFriendRequest(int toAccountId) async {
    final response = await ApiService.post<String>(
      '$_friendshipEndpoint/send-request/$toAccountId',
      fromJson: (json) => json.toString(),
    );

    // Clear cache sau khi gửi
    _friendsCache = null;
    _pendingCache = null;

    return response;
  }

  /// Chấp nhận lời mời kết bạn
  static Future<ApiResponse<String>> acceptFriendRequest(int friendRequestId) async {
    final response = await ApiService.post<String>(
      '$_friendshipEndpoint/accept/$friendRequestId',
      fromJson: (json) => json.toString(),
    );

    // Clear cache sau khi chấp nhận
    _friendsCache = null;
    _pendingCache = null;

    return response;
  }

  /// Từ chối lời mời kết bạn
  static Future<ApiResponse<String>> declineFriendRequest(int friendRequestId) async {
    final response = await ApiService.post<String>(
      '$_friendshipEndpoint/decline/$friendRequestId',
      fromJson: (json) => json.toString(),
    );

    // Clear cache sau khi từ chối
    _pendingCache = null;

    return response;
  }

  /// Xóa bạn bè
  static Future<ApiResponse<String>> removeFriend(int friendRequestId) async {
    final response = await ApiService.delete<String>(
      '$_friendshipEndpoint/remove/$friendRequestId',
      fromJson: (json) => json.toString(),
    );

    // Clear cache sau khi xóa
    _friendsCache = null;

    return response;
  }

  /// Lấy danh sách bạn bè - CÓ CACHE
  static Future<ApiResponse<List<FriendDto>>> getFriendsList() async {
    // Dùng cache nếu còn mới (dưới 100 giây)
    if (_friendsCache != null && _friendsCacheTime != null) {
      final age = DateTime.now().difference(_friendsCacheTime!).inMinutes;
      if (age < 100) {
        return ApiResponse<List<FriendDto>>(
          status: 200,
          message: 'Success',
          data: _friendsCache,
        );
      }
    }

    // Gọi API
    final response = await ApiService.getList<FriendDto>(
      '$_friendshipEndpoint/friends',
      fromJson: (json) => FriendDto.fromJson(json),
    );

    // Lưu cache
    if (response.isSuccess && response.hasData) {
      _friendsCache = response.data;
      _friendsCacheTime = DateTime.now();
    }

    return response;
  }

  /// Lấy danh sách lời mời đang chờ - CÓ CACHE
  static Future<ApiResponse<List<FriendDto>>> getPendingRequests() async {
    // Dùng cache nếu còn mới (dưới 100 giây)
    if (_pendingCache != null && _pendingCacheTime != null) {
      final age = DateTime.now().difference(_pendingCacheTime!).inMinutes;
      if (age < 100) {
        return ApiResponse<List<FriendDto>>(
          status: 200,
          message: 'Success',
          data: _pendingCache,
        );
      }
    }

    // Gọi API
    final response = await ApiService.getList<FriendDto>(
      '$_friendshipEndpoint/pending-requests',
      fromJson: (json) => FriendDto.fromJson(json),
    );

    // Lưu cache
    if (response.isSuccess && response.hasData) {
      _pendingCache = response.data;
      _pendingCacheTime = DateTime.now();
    }

    return response;
  }
}
