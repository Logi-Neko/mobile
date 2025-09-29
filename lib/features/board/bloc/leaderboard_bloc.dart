import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/features/home/dto/show_user.dart';
import '../api/leaderboard_api.dart';
import '../dto/friendship_dto.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LoadGlobalLeaderboard extends LeaderboardEvent {}

class LoadFriendsLeaderboard extends LeaderboardEvent {}

class LoadPendingRequests extends LeaderboardEvent {}

class SendFriendRequest extends LeaderboardEvent {
  final int toAccountId;

  const SendFriendRequest(this.toAccountId);

  @override
  List<Object> get props => [toAccountId];
}

class AcceptFriendRequest extends LeaderboardEvent {
  final int friendRequestId;

  const AcceptFriendRequest(this.friendRequestId);

  @override
  List<Object> get props => [friendRequestId];
}

class DeclineFriendRequest extends LeaderboardEvent {
  final int friendRequestId;

  const DeclineFriendRequest(this.friendRequestId);

  @override
  List<Object> get props => [friendRequestId];
}

// States
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardOperationLoading extends LeaderboardState {}

class GlobalLeaderboardLoaded extends LeaderboardState {
  final List<AccountShowResponse> leaderboard;

  const GlobalLeaderboardLoaded(this.leaderboard);

  @override
  List<Object> get props => [leaderboard];
}

class FriendsLeaderboardLoaded extends LeaderboardState {
  final List<FriendDto> friends;

  const FriendsLeaderboardLoaded(this.friends);

  @override
  List<Object> get props => [friends];
}

class PendingRequestsLoaded extends LeaderboardState {
  final List<FriendDto> pendingRequests;

  const PendingRequestsLoaded(this.pendingRequests);

  @override
  List<Object> get props => [pendingRequests];
}

class FriendRequestSent extends LeaderboardState {
  final String message;

  const FriendRequestSent(this.message);

  @override
  List<Object> get props => [message];
}

class FriendRequestAccepted extends LeaderboardState {
  final String message;

  const FriendRequestAccepted(this.message);

  @override
  List<Object> get props => [message];
}

class FriendRequestDeclined extends LeaderboardState {
  final String message;

  const FriendRequestDeclined(this.message);

  @override
  List<Object> get props => [message];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LoadGlobalLeaderboard>(_onLoadGlobalLeaderboard);
    on<LoadFriendsLeaderboard>(_onLoadFriendsLeaderboard);
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<DeclineFriendRequest>(_onDeclineFriendRequest);
  }

  Future<void> _onLoadGlobalLeaderboard(
    LoadGlobalLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final response = await LeaderboardApi.getGlobalLeaderboard();
      if (response.isSuccess && response.data != null) {
        emit(GlobalLeaderboardLoaded(response.data!));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể tải bảng xếp hạng'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi tải bảng xếp hạng: $e'));
    }
  }

  Future<void> _onLoadFriendsLeaderboard(
    LoadFriendsLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final response = await LeaderboardApi.getFriendsLeaderboard();
      if (response.isSuccess && response.data != null) {
        emit(FriendsLeaderboardLoaded(response.data!));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể tải danh sách bạn bè'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi tải danh sách bạn bè: $e'));
    }
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardOperationLoading());
    try {
      final response = await LeaderboardApi.getPendingRequests();
      if (response.isSuccess && response.data != null) {
        emit(PendingRequestsLoaded(response.data!));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể tải lời mời kết bạn'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi tải lời mời kết bạn: $e'));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardOperationLoading());
    try {
      final response = await LeaderboardApi.sendFriendRequest(event.toAccountId);
      if (response.isSuccess) {
        emit(FriendRequestSent(response.message ?? 'Đã gửi lời mời kết bạn'));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể gửi lời mời kết bạn'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi gửi lời mời kết bạn: $e'));
    }
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardOperationLoading());
    try {
      final response = await LeaderboardApi.acceptFriendRequest(event.friendRequestId);
      if (response.isSuccess) {
        emit(FriendRequestAccepted(response.message ?? 'Đã chấp nhận lời mời kết bạn'));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể chấp nhận lời mời kết bạn'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi chấp nhận lời mời kết bạn: $e'));
    }
  }

  Future<void> _onDeclineFriendRequest(
    DeclineFriendRequest event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardOperationLoading());
    try {
      final response = await LeaderboardApi.declineFriendRequest(event.friendRequestId);
      if (response.isSuccess) {
        emit(FriendRequestDeclined(response.message ?? 'Đã từ chối lời mời kết bạn'));
      } else {
        emit(LeaderboardError(response.message ?? 'Không thể từ chối lời mời kết bạn'));
      }
    } catch (e) {
      emit(LeaderboardError('Lỗi khi từ chối lời mời kết bạn: $e'));
    }
  }
}