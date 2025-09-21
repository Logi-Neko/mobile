class Lesson {
  final int id;
  final String name;
  final String description;
  final int order;
  final String image;
  final String media;
  final String mediaType;
  final String? thumbnailUrl;
  final int duration;
  final int totalVideo;
  final int star;
  final bool isPremium;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.image,
    required this.media,
    required this.mediaType,
    this.thumbnailUrl,
    required this.duration,
    required this.totalVideo,
    required this.star,
    required this.isPremium,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      image: json['image'] ?? '',
      media: json['media'] ?? '',
      mediaType: json['mediaType'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'] ?? 0,
      totalVideo: json['totalVideo'] ?? 0,
      star: json['star'] ?? 0,
      isPremium: json['isPremium'] ?? false,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'order': order,
      'image': image,
      'media': media,
      'mediaType': mediaType,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'totalVideo': totalVideo,
      'star': star,
      'isPremium': isPremium,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedDuration {
    if (duration < 60) {
      return '${duration}s';
    } else if (duration < 3600) {
      final minutes = duration ~/ 60;
      return '${minutes}p';
    } else {
      final hours = duration ~/ 3600;
      final minutes = (duration % 3600) ~/ 60;
      return '${hours}h ${minutes}p';
    }
  }

  bool get canAccess => isActive && (!isPremium || true); // TODO: Check user premium status
}