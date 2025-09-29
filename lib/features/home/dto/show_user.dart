class AccountShowResponse {
  final int id;
  final String fullName;
  final bool? premium;
  final int totalStar;
  final String? avatarUrl;

  const AccountShowResponse({
    required this.id,
    required this.fullName,
    this.premium,
    required this.totalStar,
    this.avatarUrl,
  });

  factory AccountShowResponse.fromJson(Map<String, dynamic> json) {
    return AccountShowResponse(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      premium: json['premium'] as bool?,
      totalStar: json['totalStar'] as int,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'premium': premium,
      'totalStar': totalStar,
      'avatarUrl': avatarUrl,
    };
  }

  AccountShowResponse copyWith({
    int? id,
    String? fullName,
    bool? premium,
    int? totalStar,
    String? avatarUrl,
  }) {
    return AccountShowResponse(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      premium: premium ?? this.premium,
      totalStar: totalStar ?? this.totalStar,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountShowResponse &&
        other.id == id &&
        other.fullName == fullName &&
        other.premium == premium &&
        other.totalStar == totalStar &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        premium.hashCode ^
        totalStar.hashCode ^
        avatarUrl.hashCode;
  }

  @override
  String toString() {
    return 'AccountShowResponse(id: $id, fullName: $fullName, premium: $premium, totalStar: $totalStar, avatarUrl: $avatarUrl)';
  }
}