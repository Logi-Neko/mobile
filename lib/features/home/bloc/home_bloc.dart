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

  const UserInfoLoaded({required this.user});

  @override
  List<Object?> get props => [user];
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
    on<UpdateUserAge>(_onUpdateUserAge);
    on<ClearError>(_onClearError);
    on<ClearCurrentUser>(_onClearCurrentUser);
  }

  // ============ GETTERS ============
  User? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';

  // ============ HANDLERS ============

  Future<void> _onGetUserInfo(
      GetUserInfo event,
      Emitter<HomeState> emit,
      ) async {
    if (_hasLoaded && _currentUser != null) {
      logger.i('HomeBloc: Dữ liệu đã load, không load lại');
      emit(UserInfoLoaded(user: _currentUser!));
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
      emit(UserInfoLoaded(user: user));
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
        emit(UserInfoLoaded(user: updatedUser));
      } else {
        logger.e('HomeBloc: Cập nhật thất bại - ${response.message}');
        emit(UserInfoLoaded(user: _currentUser!));
        emit(HomeError(response.message ?? 'Cập nhật thất bại'));
      }
    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng khi cập nhật - ${e.message}');
      emit(UserInfoLoaded(user: _currentUser!));
      emit(const HomeError('Không có kết nối mạng'));
    } catch (e) {
      logger.e('HomeBloc: Lỗi cập nhật - $e');
      emit(UserInfoLoaded(user: _currentUser!));
      emit(const HomeError('Có lỗi xảy ra khi cập nhật'));
    }
  }

  Future<void> _onClearError(
      ClearError event,
      Emitter<HomeState> emit,
      ) async {
    if (_currentUser != null) {
      emit(UserInfoLoaded(user: _currentUser!));
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

  @override
  Future<void> close() {
    logger.i('HomeBloc: Closing...');
    return super.close();
  }
}