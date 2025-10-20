import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/config/logger.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/repository/home_repo.dart';
import 'package:logi_neko/features/home/dto/update_age_request.dart';
import 'package:logi_neko/features/home/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============ EVENTS ============
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class GetUserInfo extends HomeEvent {
  const GetUserInfo();
}

// New event for force refresh
class RefreshUserInfo extends HomeEvent {
  final bool silent; // If true, doesn't show loading state

  const RefreshUserInfo({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

class UpdateUserAge extends HomeEvent {
  final String dateOfBirth;

  const UpdateUserAge({required this.dateOfBirth});

  @override
  List<Object?> get props => [dateOfBirth];
}

class ClearError extends HomeEvent {
  const ClearError();
}

class ClearCurrentUser extends HomeEvent {
  const ClearCurrentUser();
}

// New event for updating stars
class UpdateUserStars extends HomeEvent {
  final int starChange; // Positive or negative change

  const UpdateUserStars({required this.starChange});

  @override
  List<Object?> get props => [starChange];
}

// ============ STATES ============
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class UserInfoLoaded extends HomeState {
  final User user;
  final DateTime? timestamp; // Add timestamp to force rebuild

  const UserInfoLoaded({
    required this.user,
    this.timestamp,
  });

  @override
  List<Object?> get props => [user, timestamp];
}

class UserInfoUpdating extends HomeState {
  final User currentUser;

  const UserInfoUpdating({required this.currentUser});

  @override
  List<Object?> get props => [currentUser];
}

class UserCleared extends HomeState {
  const UserCleared();
}

class HomeError extends HomeState {
  final String message;
  final String? errorCode;

  const HomeError(
      this.message, {
        this.errorCode,
      });

  @override
  List<Object?> get props => [message, errorCode];
}

// ============ BLOC ============
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  User? _currentUser;
  bool _hasLoaded = false;

  HomeBloc(this._homeRepository) : super(const HomeInitial()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<RefreshUserInfo>(_onRefreshUserInfo);
    on<UpdateUserAge>(_onUpdateUserAge);
    on<UpdateUserStars>(_onUpdateUserStars);
    on<ClearError>(_onClearError);
    on<ClearCurrentUser>(_onClearCurrentUser);
  }

  // ============ GETTERS ============
  User? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  int get userStars => _currentUser?.totalStar ?? 0;

  // ============ PUBLIC METHODS ============

  /// Force reload user info from server
  void refreshUser({bool silent = false}) {
    add(RefreshUserInfo(silent: silent));
  }

  /// Update star count locally and refresh from server
  void updateStars(int change) {
    add(UpdateUserStars(starChange: change));
  }

  // ============ HANDLERS ============

  Future<void> _onGetUserInfo(
      GetUserInfo event,
      Emitter<HomeState> emit,
      ) async {
    if (_hasLoaded && _currentUser != null) {
      logger.i('HomeBloc: Dữ liệu đã load, không load lại');
      emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
      return;
    }

    emit(const HomeLoading());

    try {
      logger.i('HomeBloc: Đang tải thông tin user...');

      final user = await _homeRepository.getUserInfo();
      _currentUser = user;
      _hasLoaded = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user.id);
      logger.i('HomeBloc: Saved userId: ${user.id}');

      logger.i('HomeBloc: Tải thông tin user thành công');
      emit(UserInfoLoaded(user: user, timestamp: DateTime.now()));
    } on NotFoundException catch (e) {
      logger.e('HomeBloc: Không tìm thấy user - ${e.message}');
      emit(HomeError('Không tìm thấy thông tin người dùng',
          errorCode: e.errorCode));
    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng - ${e.message}');
      emit(HomeError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      logger.e('HomeBloc: Lỗi xác thực - ${e.message}');
      emit(HomeError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } catch (e) {
      logger.e('HomeBloc: Lỗi không xác định - $e');
      emit(const HomeError('Có lỗi xảy ra khi tải thông tin'));
    }
  }

  Future<void> _onRefreshUserInfo(
      RefreshUserInfo event,
      Emitter<HomeState> emit,
      ) async {
    // If silent refresh, don't show loading
    if (!event.silent && _currentUser != null) {
      emit(UserInfoUpdating(currentUser: _currentUser!));
    } else if (!event.silent) {
      emit(const HomeLoading());
    }

    try {
      logger.i('HomeBloc: Refreshing user info...');

      final user = await _homeRepository.getUserInfo();
      _currentUser = user;
      _hasLoaded = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user.id);

      logger.i('HomeBloc: User info refreshed successfully');
      emit(UserInfoLoaded(user: user, timestamp: DateTime.now()));
    } on NetworkException catch (e) {
      logger.e('HomeBloc: Network error during refresh - ${e.message}');

      // If we have cached user, show it with error message
      if (_currentUser != null) {
        emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
        // Optionally emit error state briefly
        await Future.delayed(Duration(milliseconds: 100));
        emit(HomeError('Không thể cập nhật thông tin', errorCode: e.errorCode));
        await Future.delayed(Duration(seconds: 2));
        emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
      } else {
        emit(HomeError('Không có kết nối mạng', errorCode: e.errorCode));
      }
    } catch (e) {
      logger.e('HomeBloc: Error during refresh - $e');

      if (_currentUser != null) {
        emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
      } else {
        emit(const HomeError('Có lỗi xảy ra khi cập nhật'));
      }
    }
  }

  Future<void> _onUpdateUserAge(
      UpdateUserAge event,
      Emitter<HomeState> emit,
      ) async {
    if (_currentUser == null) {
      emit(const HomeError('Không có user hiện tại',
          errorCode: 'NO_CURRENT_USER'));
      return;
    }

    emit(UserInfoUpdating(currentUser: _currentUser!));

    try {
      logger.i('HomeBloc: Đang cập nhật ngày sinh...');

      final request = UpdateAgeRequest(dateOfBirth: event.dateOfBirth);
      final response = await UserApi.updateUserAge(request);

      if (response.isSuccess && response.hasData) {
        // Refresh lại user info từ server để lấy dữ liệu mới nhất
        final updatedUser = await _homeRepository.getUserInfo();
        _currentUser = updatedUser;
        logger.i('HomeBloc: Cập nhật ngày sinh thành công');
        emit(UserInfoLoaded(user: updatedUser, timestamp: DateTime.now()));
      } else {
        logger.e('HomeBloc: Cập nhật thất bại - ${response.message}');
        emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
        emit(HomeError(response.message ?? 'Cập nhật thất bại'));
      }
    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng khi cập nhật - ${e.message}');
      emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
      emit(const HomeError('Không có kết nối mạng'));
    } catch (e) {
      logger.e('HomeBloc: Lỗi cập nhật - $e');
      emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
      emit(const HomeError('Có lỗi xảy ra khi cập nhật'));
    }
  }

  Future<void> _onUpdateUserStars(
      UpdateUserStars event,
      Emitter<HomeState> emit,
      ) async {
    if (_currentUser == null) return;

    // Optimistically update local state
    final optimisticUser = _currentUser!.copyWith(
      totalStar: _currentUser!.totalStar + event.starChange,
    );
    _currentUser = optimisticUser;
    emit(UserInfoLoaded(user: optimisticUser, timestamp: DateTime.now()));

    // Then refresh from server to get actual value
    try {
      logger.i('HomeBloc: Refreshing user stars from server...');
      final updatedUser = await _homeRepository.getUserInfo();
      _currentUser = updatedUser;
      emit(UserInfoLoaded(user: updatedUser, timestamp: DateTime.now()));
    } catch (e) {
      logger.e('HomeBloc: Failed to refresh stars - $e');
      // Keep optimistic update if refresh fails
    }
  }

  Future<void> _onClearError(
      ClearError event,
      Emitter<HomeState> emit,
      ) async {
    if (_currentUser != null) {
      emit(UserInfoLoaded(user: _currentUser!, timestamp: DateTime.now()));
    } else {
      emit(const HomeInitial());
    }
  }

  Future<void> _onClearCurrentUser(
      ClearCurrentUser event,
      Emitter<HomeState> emit,
      ) async {
    logger.i('HomeBloc: Clearing current user on logout');
    _currentUser = null;
    _hasLoaded = false;
    emit(const UserCleared());
  }

  // ============ UTILITY METHODS ============

  void reset() {
    logger.i('HomeBloc: Resetting bloc');
    _currentUser = null;
    _hasLoaded = false;
    emit(const HomeInitial());
  }

  /// Check if user data needs refresh (e.g., older than 5 minutes)
  bool shouldRefresh() {
    if (!_hasLoaded || _currentUser == null) return true;

    return false;
  }

  @override
  Future<void> close() {
    logger.i('HomeBloc: Closing...');
    return super.close();
  }
}