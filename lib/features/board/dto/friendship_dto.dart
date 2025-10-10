import '../../../features/home/dto/show_user.dart';

enum StatusFriendShip {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  blocked('BLOCKED'),
  unfriended('UNFRIENDED');

  const StatusFriendShip(this.value);
  final String value;

  static StatusFriendShip fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return StatusFriendShip.pending;
      case 'ACCEPTED':
        return StatusFriendShip.accepted;
      case 'REJECTED':
        return StatusFriendShip.rejected;
      case 'BLOCKED':
        return StatusFriendShip.blocked;
      case 'UNFRIENDED':
        return StatusFriendShip.unfriended;
      default:
        throw ArgumentError('Unknown StatusFriendShip: $value');
    }
  }

  @override
  String toString() => value;
}

class FriendDto {
  final int id;
  final int accountId;
  final AccountShowResponse friendAccount;
  final StatusFriendShip status;
  final DateTime createdAt;

  const FriendDto({
    required this.id,
    required this.accountId,
    required this.friendAccount,
    required this.status,
    required this.createdAt,
  });

  factory FriendDto.fromJson(Map<String, dynamic> json) {
    return FriendDto(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      friendAccount: AccountShowResponse.fromJson(json['friendAccount'] as Map<String, dynamic>),
      status: StatusFriendShip.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'friendAccount': friendAccount.toJson(),
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FriendDto copyWith({
    int? id,
    int? accountId,
    AccountShowResponse? friendAccount,
    StatusFriendShip? status,
    DateTime? createdAt,
  }) {
    return FriendDto(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      friendAccount: friendAccount ?? this.friendAccount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendDto &&
        other.id == id &&
        other.accountId == accountId &&
        other.friendAccount == friendAccount &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        friendAccount.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'FriendDto(id: $id, accountId: $accountId, friendAccount: $friendAccount, status: $status, createdAt: $createdAt)';
  }
}