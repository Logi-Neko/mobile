import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/features/home/api/api.dart';
import 'package:logi_neko/features/home/dto/show_user.dart';
import '../api/friendship_api.dart';
import '../dto/friendship_dto.dart';

class LeaderboardApi {
  // Cache cho global leaderboard
  static List<AccountShowResponse>? _globalCache;
  static DateTime? _globalCacheTime;

  /// Lấy bảng xếp hạng toàn cầu - CÓ CACHE
  static Future<ApiResponse<List<AccountShowResponse>>> getGlobalLeaderboard() async {
    if (_globalCache != null && _globalCacheTime != null) {
      final age = DateTime.now().difference(_globalCacheTime!).inMinutes;
      if (age < 100) {
        return ApiResponse<List<AccountShowResponse>>(
          status: 200,
          message: 'Success',
          data: _globalCache,
        );
      }
    }

    // Gọi API
    final response = await HomeApi.getUserDashboard();

    // Lưu cache
    if (response.isSuccess && response.hasData) {
      _globalCache = response.data;
      _globalCacheTime = DateTime.now();
    }

    return response;
  }

  /// Lấy danh sách bạn bè (dùng FriendshipApi đã có cache)
  static Future<ApiResponse<List<FriendDto>>> getFriendsLeaderboard() async {
    return await FriendshipApi.getFriendsList();
  }

  /// Lấy danh sách lời mời đang chờ (dùng FriendshipApi đã có cache)
  static Future<ApiResponse<List<FriendDto>>> getPendingRequests() async {
    return await FriendshipApi.getPendingRequests();
  }

  /// Gửi lời mời kết bạn
  static Future<ApiResponse<String>> sendFriendRequest(int toAccountId) async {
    return await FriendshipApi.sendFriendRequest(toAccountId);
  }

  /// Chấp nhận lời mời kết bạn
  static Future<ApiResponse<String>> acceptFriendRequest(int friendRequestId) async {
    return await FriendshipApi.acceptFriendRequest(friendRequestId);
  }

  /// Từ chối lời mời kết bạn
  static Future<ApiResponse<String>> declineFriendRequest(int friendRequestId) async {
    return await FriendshipApi.declineFriendRequest(friendRequestId);
  }
}