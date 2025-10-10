import 'package:equatable/equatable.dart';

abstract class FriendshipEvent extends Equatable {
  const FriendshipEvent();

  @override
  List<Object?> get props => [];
}

/// Gửi lời mời kết bạn
class SendFriendRequestEvent extends FriendshipEvent {
  final int toAccountId;

  const SendFriendRequestEvent(this.toAccountId);

  @override
  List<Object?> get props => [toAccountId];
}

/// Chấp nhận lời mời kết bạn
class AcceptFriendRequestEvent extends FriendshipEvent {
  final int friendRequestId;

  const AcceptFriendRequestEvent(this.friendRequestId);

  @override
  List<Object?> get props => [friendRequestId];
}

/// Từ chối lời mời kết bạn
class DeclineFriendRequestEvent extends FriendshipEvent {
  final int friendRequestId;

  const DeclineFriendRequestEvent(this.friendRequestId);

  @override
  List<Object?> get props => [friendRequestId];
}

/// Xóa bạn bè
class RemoveFriendEvent extends FriendshipEvent {
  final int friendRequestId;

  const RemoveFriendEvent(this.friendRequestId);

  @override
  List<Object?> get props => [friendRequestId];
}

/// Lấy danh sách bạn bè
class GetFriendsListEvent extends FriendshipEvent {
  const GetFriendsListEvent();
}

/// Lấy danh sách lời mời kết bạn đang chờ
class GetPendingRequestsEvent extends FriendshipEvent {
  const GetPendingRequestsEvent();
}