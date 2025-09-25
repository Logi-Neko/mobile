import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/config/logger.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/repository/home_repo.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetUserInfo extends HomeEvent {}

class RefreshUserInfo extends HomeEvent {}

class UpdateUserInfo extends HomeEvent {
  final Map<String, dynamic> userData;

  UpdateUserInfo(this.userData);

  @override
  List<Object?> get props => [userData];
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

  HomeBloc(this._homeRepository) : super(HomeInitial()) {
    on<GetUserInfo>(_onGetUserInfo);
    on<RefreshUserInfo>(_onRefreshUserInfo);
    on<ClearError>(_onClearError);
  }

  // Getter để lấy user hiện tại
  User? get currentUser => _currentUser;
  bool get hasUser => _currentUser != null;
  String get userName => _currentUser?.fullName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';

  Future<void> _onGetUserInfo(GetUserInfo event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      logger.i('HomeBloc: Đang tải thông tin user...');

      final user = await _homeRepository.getUserInfo();
      _currentUser = user;

      logger.i('HomeBloc: Tải thông tin user thành công');
      emit(UserInfoLoaded(user));

    } on NotFoundException catch (e) {
      logger.e('HomeBloc: Không tìm thấy thông tin user - ${e.message}');
      emit(HomeError('Không tìm thấy thông tin người dùng', errorCode: e.errorCode));

    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng - ${e.message}');
      emit(HomeError('Không có kết nối mạng', errorCode: e.errorCode));

    } on UnauthorizedException catch (e) {
      logger.e('HomeBloc: Lỗi xác thực - ${e.message}');
      emit(HomeError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));

    } catch (e) {
      logger.e('HomeBloc: Lỗi không xác định - $e');
      emit(HomeError('Có lỗi không xác định xảy ra khi tải thông tin người dùng'));
    }
  }

  Future<void> _onRefreshUserInfo(RefreshUserInfo event, Emitter<HomeState> emit) async {
    if (_currentUser == null) {
      emit(HomeLoading());
    }

    try {
      logger.i('HomeBloc: Đang refresh thông tin user...');

      final user = await _homeRepository.getUserInfo();
      _currentUser = user;

      logger.i('HomeBloc: Refresh thông tin user thành công');
      emit(UserInfoLoaded(user));

    } on NotFoundException catch (e) {
      logger.e('HomeBloc: Không tìm thấy thông tin user khi refresh - ${e.message}');
      emit(HomeError('Không tìm thấy thông tin người dùng', errorCode: e.errorCode));

    } on NetworkException catch (e) {
      logger.e('HomeBloc: Lỗi mạng khi refresh - ${e.message}');
      emit(HomeError('Không có kết nối mạng', errorCode: e.errorCode));

    } on UnauthorizedException catch (e) {
      logger.e('HomeBloc: Lỗi xác thực khi refresh - ${e.message}');
      emit(HomeError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));

    } on AppException catch (e) {
      logger.e('HomeBloc: Lỗi app khi refresh - ${e.message}');
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(HomeError(errorMessage, errorCode: e.errorCode));

    } catch (e) {
      logger.e('HomeBloc: Lỗi không xác định khi refresh - $e');
      emit(HomeError('Có lỗi không xác định xảy ra khi làm mới thông tin'));
    }
  }

  void _onClearError(ClearError event, Emitter<HomeState> emit) {
    if (_currentUser != null) {
      emit(UserInfoLoaded(_currentUser!));
    } else {
      emit(HomeInitial());
    }
  }

  String _getLocalizedErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'Không có kết nối mạng';
      case UnauthorizedException:
        return 'Phiên đăng nhập đã hết hạn';
      case NotFoundException:
        return 'Không tìm thấy dữ liệu';
      case BackendException:
        return 'Lỗi từ máy chủ';
      default:
        return exception.message ?? 'Có lỗi xảy ra';
    }
  }

  @override
  Future<void> close() {
    logger.i('HomeBloc: Closing...');
    return super.close();
  }
}