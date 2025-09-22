import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/logger.dart';
import '../../../core/storage/token_storage.dart';
import '../dto/signup_request.dart';
import '../dto/login_response.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<AuthRefreshTokenSubmitted>(_onRefreshTokenSubmitted);
    on<AuthLogoutSubmitted>(_onLogoutSubmitted);
    on<AuthResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      AuthRegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthRegisterSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(request: event.request);
      logger.i("✅ Register response in bloc: $response");
      emit(AuthRegisterSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Register error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLoginSubmitted(
      AuthLoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthLoginSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(event.loginData);
      logger.i("✅ Login response in bloc: $response");

      // Tự động lưu token khi login thành công
      if (response.data != null) {
        await _tokenStorage.saveTokenResponse(response.data!);
        logger.i("🔐 Tokens saved successfully");
      }

      emit(AuthLoginSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Login error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onForgotPasswordSubmitted(
      AuthForgotPasswordSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthForgotPasswordSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.forgotPassword(event.username);
      logger.i("✅ Forgot password response in bloc: $response");
      emit(AuthForgotPasswordSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Forgot password error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRefreshTokenSubmitted(
      AuthRefreshTokenSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthRefreshTokenSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.refreshToken(event.refreshToken);
      logger.i("✅ Refresh token response in bloc: $response");
      emit(AuthRefreshTokenSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Refresh token error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutSubmitted(
      AuthLogoutSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthLogoutSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.logout(event.refreshToken);
      logger.i("✅ Logout response in bloc: $response");
      emit(AuthLogoutSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Logout error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onResetPasswordSubmitted(
      AuthResetPasswordSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthResetPasswordSubmitted received");
    emit(AuthLoading());
    try {
      final response = await _authRepository.resetPassword(
        event.oldPassword,
        event.newPassword,
      );
      logger.i("✅ Reset password response in bloc: $response");
      emit(AuthResetPasswordSuccess(response.data!));
    } catch (e, s) {
      logger.i("❌ Reset password error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthRegisterSubmitted extends AuthEvent {
  final SignUpRequest request;
  const AuthRegisterSubmitted({required this.request});

  @override
  List<Object> get props => [request];
}

class AuthLoginSubmitted extends AuthEvent {
  final Map<String, dynamic> loginData;
  const AuthLoginSubmitted({required this.loginData});

  @override
  List<Object> get props => [loginData];
}

class AuthForgotPasswordSubmitted extends AuthEvent {
  final String username;
  const AuthForgotPasswordSubmitted({required this.username});

  @override
  List<Object> get props => [username];
}

class AuthRefreshTokenSubmitted extends AuthEvent {
  final String refreshToken;
  const AuthRefreshTokenSubmitted({required this.refreshToken});

  @override
  List<Object> get props => [refreshToken];
}

class AuthLogoutSubmitted extends AuthEvent {
  final String refreshToken;
  const AuthLogoutSubmitted({required this.refreshToken});

  @override
  List<Object> get props => [refreshToken];
}

class AuthResetPasswordSubmitted extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  const AuthResetPasswordSubmitted({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  final dynamic response;
  const AuthRegisterSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class AuthLoginSuccess extends AuthState {
  final TokenResponse tokenResponse;
  const AuthLoginSuccess(this.tokenResponse);

  @override
  List<Object> get props => [tokenResponse];
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;
  const AuthForgotPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthRefreshTokenSuccess extends AuthState {
  final TokenResponse tokenResponse;
  const AuthRefreshTokenSuccess(this.tokenResponse);

  @override
  List<Object> get props => [tokenResponse];
}

class AuthLogoutSuccess extends AuthState {
  final String message;
  const AuthLogoutSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthResetPasswordSuccess extends AuthState {
  final String message;
  const AuthResetPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);

  @override
  List<Object> get props => [error];

  get message => null;
}