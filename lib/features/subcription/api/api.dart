

import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/subcription/dto/subscription.dart';

class SubscriptionApi {

  static Future<ApiResponse<Subscription>> createSubscription(
      CreateSubscriptionDto dto,
      ) async {
    return await ApiService.postObject<Subscription>(
      '/api/subscriptions',
      data: dto.toJson(),
      fromJson: (json) => Subscription.fromJson(json),
    );
  }

  static Future<ApiResponse<PaymentResponse>> createPayment(dto) async {
    try {
      return await ApiService.post<PaymentResponse>(
        '/api/payment',
        queryParameters: {
          'orderCode': dto.orderCode,
          'amount': dto.amount,
          'description': dto.description,
        },
        fromJson: (json) {
          if (json is String) {
            return PaymentResponse(checkoutUrl: json);
          }

          return PaymentResponse(checkoutUrl: null);
        },
      );
    } catch (e) {
      print('❌ Error creating payment: $e');
      rethrow;
    }
  }

  static Future<ApiResponse<Subscription>> getSubscriptionById(int id) async {
    return await ApiService.getObject<Subscription>(
      '/api/subscriptions/$id',
      fromJson: (json) => Subscription.fromJson(json),
    );
  }

  static Future<ApiResponse<List<Subscription>>> getSubscriptions({
    int? accountId,
  }) async {
    return await ApiService.getList<Subscription>(
      '/api/subscriptions',
      queryParameters: accountId != null ? {'accountId': accountId} : null,
      fromJson: (json) => Subscription.fromJson(json),
    );
  }

}