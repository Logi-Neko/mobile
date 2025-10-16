import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/config/logger.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/repository/home_repo.dart';
import 'package:logi_neko/features/home/dto/update_age_request.dart';
import 'package:logi_neko/features/home/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetUserInfo extends HomeEvent {}

class UpdateUserAge extends HomeEvent {
  final String dateOfBirth;

  UpdateUserAge(this.dateOfBirth);

  @override
  List<Object?> get props => [dateOfBirth];
}

class ClearError extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class UserInfoLoaded extends HomeState {
  final User user;

  UserInfoLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserInfoUpdating extends HomeState {
  final User currentUser;

  UserInfoUpdating(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}

class HomeError extends HomeState {
  final String message;
  final String? errorCode;

  HomeError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;
  User? _currentUser;
  bool _hasLoaded = false; // Flag để track đã load chưa

  HomeBloc(this._homeRepository) : super(HomeInitial()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<UpdateUserAge>(_onUpdateUserAge);
    on<ClearError>(_onClearError);
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';

  Future<void> _onGetUserInfo(GetUserInfo event, Emitter<HomeState> emit) async {
    if (_hasLoaded && _currentUser != null) {
      logger.i('HomeBloc: Dữ liệu đã load, không load lại');
      emit(UserInfoLoaded(_currentUser!));
      return;
    }

    emit(HomeLoading());

    try {
      logger.i('HomeBloc: Đang tải thông tin user...');

      final user = await _homeRepository.getUserInfo();
      _currentUser = user;
      _hasLoaded = true; // Đánh dấu đã load

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', user.id);
      logger.i('HomeBloc: Saved userId: ${user.id}');

      logger.i('HomeBloc: Tải thông tin user thành công');
      emit(UserInfoLoaded(user));

    } on NotFoundException catch (e) {
      logger.e('HomeBloc: Không tìm thấy user - ${e.message}');
      emit(HomeError('Không tìm thấy thông tin người dùng', errorCode: e.errorCode));

    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng - ${e.message}');
      emit(HomeError('Không có kết nối mạng', errorCode: e.errorCode));

    } on UnauthorizedException catch (e) {
      logger.e('HomeBloc: Lỗi xác thực - ${e.message}');
      emit(HomeError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));

    } catch (e) {
      logger.e('HomeBloc: Lỗi không xác định - $e');
      emit(HomeError('Có lỗi xảy ra khi tải thông tin'));
    }
  }

  Future<void> _onUpdateUserAge(UpdateUserAge event, Emitter<HomeState> emit) async {
    if (_currentUser == null) return;

    emit(UserInfoUpdating(_currentUser!));

    try {
      logger.i('HomeBloc: Đang cập nhật ngày sinh...');

      final request = UpdateAgeRequest(dateOfBirth: event.dateOfBirth);
      final response = await UserApi.updateUserAge(request);

      if (response.isSuccess && response.hasData) {
        _currentUser = response.data!;
        logger.i('HomeBloc: Cập nhật ngày sinh thành công');
        emit(UserInfoLoaded(_currentUser!));
      } else {
        logger.e('HomeBloc: Cập nhật thất bại - ${response.message}');
        emit(HomeError(response.message ?? 'Cập nhật thất bại'));
      }

    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng khi cập nhật - ${e.message}');
      emit(HomeError('Không có kết nối mạng'));
      emit(UserInfoLoaded(_currentUser!));

    } catch (e) {
      logger.e('HomeBloc: Lỗi cập nhật - $e');
      emit(HomeError('Có lỗi xảy ra khi cập nhật'));
      emit(UserInfoLoaded(_currentUser!));
    }
  }

  void _onClearError(ClearError event, Emitter<HomeState> emit) {
    if (_currentUser != null) {
      emit(UserInfoLoaded(_currentUser!));
    } else {
      emit(HomeInitial());
    }
  }

  // Reset khi logout
  void reset() {
    _currentUser = null;
    _hasLoaded = false;
    emit(HomeInitial());
  }

  @override
  Future<void> close() {
    logger.i('HomeBloc: Closing...');
    return super.close();
  }
}