import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/logger.dart';
import '../dto/signup_request.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      AuthRegisterSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    logger.i("🔥 AuthRegisterSubmitted received"); // log event
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(request: event.request);
      logger.i("✅ API response in bloc: $response"); // log response
      emit(AuthSuccess(response));
    } catch (e, s) {
      logger.i("❌ Error in bloc: $e\n$s");
      emit(AuthFailure(e.toString()));
    }
  }
}


class AuthRegisterSubmitted extends AuthEvent {
  // Chỉ chứa 1 thuộc tính
  final SignUpRequest request;

  const AuthRegisterSubmitted({required this.request});
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final Map<String, dynamic> response;
  const AuthSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
}