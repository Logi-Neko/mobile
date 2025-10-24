

import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/features/subcription/api/api.dart';
import 'package:logi_neko/features/subcription/dto/subscription.dart';

class SubscriptionRepository {
  Future<ApiResponse<Subscription>> createSubscription(
      CreateSubscriptionDto dto,
      ) async {
    try {
      final response = await SubscriptionApi.createSubscription(dto);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaymentResponse>> createPayment(
      CreatePaymentDto dto,
      ) async {
    try {
      final response = await SubscriptionApi.createPayment(dto);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Subscription>>> getUserSubscriptions(
      int accountId,
      ) async {
    try {
      final response = await SubscriptionApi.getSubscriptions(
        accountId: accountId,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasActiveSubscription(int accountId) async {
    try {
      final response = await getUserSubscriptions(accountId);

      if (response.isSuccess && response.data != null) {
        return response.data!.any((sub) =>
        sub.isActive && sub.daysRemaining > 0
        );
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Subscription?> getCurrentActiveSubscription(int accountId) async {
    try {
      final response = await getUserSubscriptions(accountId);

      if (response.isSuccess && response.data != null) {
        final activeSubs = response.data!.where((sub) =>
        sub.isActive && sub.daysRemaining > 0
        ).toList();

        if (activeSubs.isNotEmpty) {
          // Sắp xếp theo endDate giảm dần, lấy cái gần nhất
          activeSubs.sort((a, b) => b.endDate.compareTo(a.endDate));
          return activeSubs.first;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}