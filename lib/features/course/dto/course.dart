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
  final double star;

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
    this.star = 0,
  });

  // Cache cho DateTime parsing
  static final Map<String, DateTime> _dateCache = {};

  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    if (_dateCache.containsKey(dateString)) {
      return _dateCache[dateString]!;
    }

    try {
      final parsed = DateTime.parse(dateString);
      _dateCache[dateString] = parsed;

      // Limit cache size
      if (_dateCache.length > 5000) {
        _dateCache.clear();
      }

      return parsed;
    } catch (e) {
      print('❌ DateTime parse error: $e for $dateString');
      return DateTime.now();
    }
  }

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
      price: _toDouble(json['price']),
      star: _toDouble(json['star']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      'star': star,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}