import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/friendship_dto.dart';

class FriendshipApi {
  static const String _friendshipEndpoint = '/api/friendship';

  /// Gửi lời mời kết bạn
  /// POST /api/friendship/send-request/{toAccountId}
  static Future<ApiResponse<String>> sendFriendRequest(int toAccountId) async {
    try {
      return await ApiService.post<String>(
        '$_friendshipEndpoint/send-request/$toAccountId',
        fromJson: (json) => json.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Chấp nhận lời mời kết bạn
  /// POST /api/friendship/accept/{friendRequestId}
  static Future<ApiResponse<String>> acceptFriendRequest(int friendRequestId) async {
    try {
      return await ApiService.post<String>(
        '$_friendshipEndpoint/accept/$friendRequestId',
        fromJson: (json) => json.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }


  /// Từ chối lời mời kết bạn
  /// POST /api/friendship/decline/{friendRequestId}
  static Future<ApiResponse<String>> declineFriendRequest(int friendRequestId) async {
    try {
      return await ApiService.post<String>(
        '$_friendshipEndpoint/decline/$friendRequestId',
        fromJson: (json) => json.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Xóa bạn bè
  /// DELETE /api/friendship/remove/{friendRequestId}
  static Future<ApiResponse<String>> removeFriend(int friendRequestId) async {
    try {
      return await ApiService.delete<String>(
        '$_friendshipEndpoint/remove/$friendRequestId',
        fromJson: (json) => json.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách bạn bè
  /// GET /api/friendship/friends
  static Future<ApiResponse<List<FriendDto>>> getFriendsList() async {
    try {
      return await ApiService.getList<FriendDto>(
        '$_friendshipEndpoint/friends',
        fromJson: (json) => FriendDto.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy danh sách lời mời kết bạn đang chờ
  /// GET /api/friendship/pending-requests
  static Future<ApiResponse<List<FriendDto>>> getPendingRequests() async {
    try {
      return await ApiService.getList<FriendDto>(
        '$_friendshipEndpoint/pending-requests',
        fromJson: (json) => FriendDto.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}