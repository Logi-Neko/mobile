import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/friendship_repository.dart';
import 'friendship_event.dart';
import 'friendship_state.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  final FriendshipRepository _friendshipRepository;

  FriendshipBloc(this._friendshipRepository) : super(const FriendshipInitial()) {
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<DeclineFriendRequestEvent>(_onDeclineFriendRequest);
    on<RemoveFriendEvent>(_onRemoveFriend);
    on<GetFriendsListEvent>(_onGetFriendsList);
    on<GetPendingRequestsEvent>(_onGetPendingRequests);
  }

  /// Xử lý gửi lời mời kết bạn
  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.sendFriendRequest(event.toAccountId);
      if (response.isSuccess) {
        emit(FriendshipActionSuccess(response.message ?? "Đã gửi lời mời kết bạn thành công"));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi gửi lời mời kết bạn"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }

  /// Xử lý chấp nhận lời mời kết bạn
  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.acceptFriendRequest(event.friendRequestId);
      if (response.isSuccess) {
        emit(FriendshipActionSuccess(response.message ?? "Đã chấp nhận lời mời kết bạn"));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi chấp nhận lời mời kết bạn"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }

  /// Xử lý từ chối lời mời kết bạn
  Future<void> _onDeclineFriendRequest(
    DeclineFriendRequestEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.declineFriendRequest(event.friendRequestId);
      if (response.isSuccess) {
        emit(FriendshipActionSuccess(response.message ?? "Đã từ chối lời mời kết bạn"));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi từ chối lời mời kết bạn"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }

  /// Xử lý xóa bạn bè
  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.removeFriend(event.friendRequestId);
      if (response.isSuccess) {
        emit(FriendshipActionSuccess(response.message ?? "Đã xóa bạn bè thành công"));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi xóa bạn bè"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }

  /// Xử lý lấy danh sách bạn bè
  Future<void> _onGetFriendsList(
    GetFriendsListEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.getFriendsList();
      if (response.isSuccess && response.data != null) {
        emit(FriendsListLoaded(response.data!));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi lấy danh sách bạn bè"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }

  /// Xử lý lấy danh sách lời mời đang chờ
  Future<void> _onGetPendingRequests(
    GetPendingRequestsEvent event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(const FriendshipLoading());
    try {
      final response = await _friendshipRepository.getPendingRequests();
      if (response.isSuccess && response.data != null) {
        emit(PendingRequestsLoaded(response.data!));
      } else {
        emit(FriendshipError(response.message ?? "Có lỗi xảy ra khi lấy danh sách lời mời đang chờ"));
      }
    } catch (e) {
      emit(FriendshipError("Có lỗi xảy ra: ${e.toString()}"));
    }
  }
}