enum CharacterRarity {
  common,
  rare,
  epic,
  legendary,
}

class CharacterDto {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int starRequired;
  final CharacterRarity rarity;
  final bool isPremium;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CharacterDto({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.starRequired,
    required this.rarity,
    required this.isPremium,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      starRequired: json['starRequired'] as int,
      rarity: CharacterRarity.values.firstWhere(
        (e) => e.name.toLowerCase() == json['rarity'].toString().toLowerCase(),
        orElse: () => CharacterRarity.common,
      ),
      isPremium: json['isPremium'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'starRequired': starRequired,
      'rarity': rarity.name,
      'isPremium': isPremium,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CharacterDto(id: $id, name: $name, rarity: $rarity, starRequired: $starRequired)';
  }
}