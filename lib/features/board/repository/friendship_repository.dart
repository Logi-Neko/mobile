import 'package:logi_neko/core/common/ApiResponse.dart';
import '../api/friendship_api.dart';
import '../dto/friendship_dto.dart';

class FriendshipRepository {
  /// Gửi lời mời kết bạn
  Future<ApiResponse<String>> sendFriendRequest(int toAccountId) async {
    try {
      return await FriendshipApi.sendFriendRequest(toAccountId);
    } catch (e) {
      rethrow;
    }
  }

  /// Chấp nhận lời mời kết bạn
  Future<ApiResponse<String>> acceptFriendRequest(int friendRequestId) async {
    try {
      return await FriendshipApi.acceptFriendRequest(friendRequestId);
    } catch (e) {
      rethrow;
    }
  }

  /// Từ chối lời mời kết bạn
  Future<ApiResponse<String>> declineFriendRequest(int friendRequestId) async {
    try {
      return await FriendshipApi.declineFriendRequest(friendRequestId);
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa bạn bè
  Future<ApiResponse<String>> removeFriend(int friendRequestId) async {
    try {
      return await FriendshipApi.removeFriend(friendRequestId);
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách bạn bè
  Future<ApiResponse<List<FriendDto>>> getFriendsList() async {
    try {
      return await FriendshipApi.getFriendsList();
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách lời mời kết bạn đang chờ
  Future<ApiResponse<List<FriendDto>>> getPendingRequests() async {
    try {
      return await FriendshipApi.getPendingRequests();
    } catch (e) {
      rethrow;
    }
  }
}