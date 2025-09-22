class Course {
  final int id;
  final String name;
  final String description;
  final String thumbnailUrl;
  final String? thumbnailPublicId;
  final int totalLesson;
  final bool isPremium;
  final bool isActive;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    this.thumbnailPublicId,
    required this.totalLesson,
    required this.isPremium,
    required this.isActive,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      thumbnailPublicId: json['thumbnailPublicId'],
      totalLesson: json['totalLesson'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? true,
      price: (json['price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'thumbnailPublicId': thumbnailPublicId,
      'totalLesson': totalLesson,
      'isPremium': isPremium,
      'isActive': isActive,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
