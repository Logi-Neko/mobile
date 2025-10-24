// Model cho Subscription với đầy đủ fields từ API response
class Subscription {
  final int id;
  final int accountId;
  final String accountEmail;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String subscriptionStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int daysRemaining;

  Subscription({
    required this.id,
    required this.accountId,
    required this.accountEmail,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.subscriptionStatus,
    this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.daysRemaining,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      accountId: json['accountId'] ?? 0,
      accountEmail: json['accountEmail'] ?? '',
      type: json['type'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subscriptionStatus: json['subscriptionStatus'] ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
      daysRemaining: json['daysRemaining'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountEmail': accountEmail,
      'type': type,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'price': price,
      'subscriptionStatus': subscriptionStatus,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isActive': isActive,
      'daysRemaining': daysRemaining,
    };
  }
}

// DTO cho việc tạo subscription
class CreateSubscriptionDto {
  final int accountId;
  final String type; // "MONTHLY" hoặc "YEARLY"
  final String startDate; // "2025-10-24"
  final String endDate; // "2025-10-24"
  final double price;
  final String subscriptionStatus; // "ACTIVE"

  CreateSubscriptionDto({
    required this.accountId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.subscriptionStatus = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'price': price,
      'subscriptionStatus': subscriptionStatus,
    };
  }

  // Helper factory để tạo từ DateTime
  factory CreateSubscriptionDto.fromDates({
    required int accountId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required double price,
    String subscriptionStatus = 'ACTIVE',
  }) {
    return CreateSubscriptionDto(
      accountId: accountId,
      type: type,
      startDate: _formatDate(startDate),
      endDate: _formatDate(endDate),
      price: price,
      subscriptionStatus: subscriptionStatus,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// DTO cho payment
class CreatePaymentDto {
  final int orderCode;
  final int amount;
  final String description;

  CreatePaymentDto({
    required this.orderCode,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderCode': orderCode,
      'amount': amount,
      'description': description,
    };
  }
}

// Response từ payment API
class PaymentResponse {
  final String? checkoutUrl;
  final String? qrCode;
  final Map<String, dynamic>? additionalData;

  PaymentResponse({
    this.checkoutUrl,
    this.qrCode,
    this.additionalData,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      checkoutUrl: json['checkoutUrl'],
      qrCode: json['qrCode'],
      additionalData: json,
    );
  }
}