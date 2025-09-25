class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? premiumUntil;
  final bool? premium;
  final int totalStar;
  final String? dateOfBirth;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.premiumUntil,
    this.premium,
    required this.totalStar,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      premiumUntil: json['premiumUntil'],
      premium: json['premium'],
      totalStar: json['totalStar'] ?? 0,
      dateOfBirth: json['dateOfBirth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'premiumUntil': premiumUntil,
      'premium': premium,
      'totalStar': totalStar,
      'dateOfBirth': dateOfBirth,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? premiumUntil,
    bool? premium,
    int? totalStar,
    String? dateOfBirth,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      premium: premium ?? this.premium,
      totalStar: totalStar ?? this.totalStar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  // Helper getters
  bool get isPremium => premium == true || (premiumUntil != null && DateTime.tryParse(premiumUntil!) != null && DateTime.parse(premiumUntil!).isAfter(DateTime.now()));

  int get age {
    if (dateOfBirth != null) {
      final birthDate = DateTime.tryParse(dateOfBirth!);
      if (birthDate != null) {
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return age;
      }
    }
    return 6; // Mặc định 6 tuổi
  }

  String get displayAge => '$age tuổi';

  String get starDisplay => totalStar > 999 ? '${(totalStar / 1000).toStringAsFixed(1)}K' : '$totalStar';

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, fullName: $fullName, totalStar: $totalStar, premium: $isPremium, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.fullName == fullName &&
        other.premiumUntil == premiumUntil &&
        other.premium == premium &&
        other.totalStar == totalStar &&
        other.dateOfBirth == dateOfBirth;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    username.hashCode ^
    email.hashCode ^
    fullName.hashCode ^
    premiumUntil.hashCode ^
    premium.hashCode ^
    totalStar.hashCode ^
    dateOfBirth.hashCode;
  }
}