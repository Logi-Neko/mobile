import 'package:equatable/equatable.dart';
import '../dto/friendship_dto.dart';

abstract class FriendshipState extends Equatable {
  const FriendshipState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class FriendshipInitial extends FriendshipState {
  const FriendshipInitial();
}

/// Trạng thái đang tải
class FriendshipLoading extends FriendshipState {
  const FriendshipLoading();
}

/// Trạng thái thành công khi gửi/chấp nhận/từ chối/xóa bạn bè
class FriendshipActionSuccess extends FriendshipState {
  final String message;

  const FriendshipActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Trạng thái thành công khi lấy danh sách bạn bè
class FriendsListLoaded extends FriendshipState {
  final List<FriendDto> friends;

  const FriendsListLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

/// Trạng thái thành công khi lấy danh sách lời mời đang chờ
class PendingRequestsLoaded extends FriendshipState {
  final List<FriendDto> pendingRequests;

  const PendingRequestsLoaded(this.pendingRequests);

  @override
  List<Object?> get props => [pendingRequests];
}

/// Trạng thái lỗi
class FriendshipError extends FriendshipState {
  final String error;

  const FriendshipError(this.error);

  @override
  List<Object?> get props => [error];
}