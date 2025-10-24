import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/subcription/dto/subscription.dart';
import 'package:logi_neko/features/subcription/repository/subscription_repo.dart';
import 'package:equatable/equatable.dart';

// ==================== EVENTS ====================

abstract class SubscriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSubscriptionEvent extends SubscriptionEvent {
  final int accountId;
  final String type;
  final double price;

  CreateSubscriptionEvent({
    required this.accountId,
    required this.type,
    required this.price,
  });

  @override
  List<Object?> get props => [accountId, type, price];
}

class CreatePaymentEvent extends SubscriptionEvent {
  final int subscriptionId;
  final int amount;
  final String description;

  CreatePaymentEvent({
    required this.subscriptionId,
    required this.amount,
    required this.description,
  });

  @override
  List<Object?> get props => [subscriptionId, amount, description];
}

/// Event load subscription hiện tại của user
class LoadUserSubscriptionEvent extends SubscriptionEvent {
  final int accountId;

  LoadUserSubscriptionEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event reset về trạng thái ban đầu
class ResetSubscriptionEvent extends SubscriptionEvent {}

// ==================== STATES ====================

abstract class SubscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// State khởi tạo
class SubscriptionInitial extends SubscriptionState {}

/// State đang loading
class SubscriptionLoading extends SubscriptionState {}

/// State đã tạo subscription thành công
class SubscriptionCreated extends SubscriptionState {
  final Subscription subscription;

  SubscriptionCreated(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

/// State đã tạo payment link thành công
class PaymentLinkCreated extends SubscriptionState {
  final PaymentResponse paymentResponse;
  final Subscription subscription;

  PaymentLinkCreated({
    required this.paymentResponse,
    required this.subscription,
  });

  @override
  List<Object?> get props => [paymentResponse, subscription];
}

/// State đã load subscription hiện tại
class UserSubscriptionLoaded extends SubscriptionState {
  final Subscription? subscription;
  final bool hasActiveSubscription;

  UserSubscriptionLoaded({
    this.subscription,
    required this.hasActiveSubscription,
  });

  @override
  List<Object?> get props => [subscription, hasActiveSubscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;
  Subscription? _currentSubscription;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<CreateSubscriptionEvent>(_onCreateSubscription);
    on<LoadUserSubscriptionEvent>(_onLoadUserSubscription);
    on<ResetSubscriptionEvent>(_onReset);
  }

  Future<void> _onCreateSubscription(
      CreateSubscriptionEvent event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(SubscriptionLoading());

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);

      final endDate = event.type == 'year'
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year, now.month + 1, now.day);

      final dto = CreateSubscriptionDto.fromDates(
        accountId: event.accountId,
        type: event.type,
        startDate: startDate,
        endDate: endDate,
        price: event.price,
        subscriptionStatus: 'ACTIVE',
      );

      final response = await repository.createSubscription(dto);

      if (response.isSuccess && response.data != null) {
        _currentSubscription = response.data!;
        emit(SubscriptionCreated(response.data!));

        await Future.delayed(const Duration(milliseconds: 300));

        await _onCreatePayment(emit, response.data!, event.price);

      } else {
        emit(SubscriptionError(
          response.message ?? 'Không thể tạo đăng ký',
        ));
      }
    } catch (e) {
      print('❌ Subscription error: $e');
      emit(SubscriptionError('Lỗi tạo subscription: ${e.toString()}'));
    }
  }

  Future<void> _onCreatePayment(
      Emitter<SubscriptionState> emit,
      Subscription subscription,
      double price,
      ) async {
    try {
      final dto = CreatePaymentDto(
        orderCode: subscription.id,
        amount: price.toInt(),
        description: 'Thanh toán...',
      );

      final response = await repository.createPayment(dto);

      if (response.isSuccess && response.data != null) {
        emit(PaymentLinkCreated(
          paymentResponse: response.data!,
          subscription: subscription,
        ));
      } else {
        emit(SubscriptionError('...'));
      }
    } catch (e) {
      emit(SubscriptionError('...'));
    }
  }

  Future<void> _onLoadUserSubscription(
      LoadUserSubscriptionEvent event,
      Emitter<SubscriptionState> emit,
      ) async {
    emit(SubscriptionLoading());

    try {
      final subscription = await repository.getCurrentActiveSubscription(
        event.accountId,
      );

      final hasActive = await repository.hasActiveSubscription(
        event.accountId,
      );

      emit(UserSubscriptionLoaded(
        subscription: subscription,
        hasActiveSubscription: hasActive,
      ));
    } catch (e) {
      emit(SubscriptionError('Lỗi tải subscription: ${e.toString()}'));
    }
  }

  Future<void> _onReset(
      ResetSubscriptionEvent event,
      Emitter<SubscriptionState> emit,
      ) async {
    _currentSubscription = null;
    emit(SubscriptionInitial());
  }
}