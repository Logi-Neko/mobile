import 'character_dto.dart';

/// DTO cho việc tạo nhân vật tài khoản
class AccountCharacterCreateDto {
  final int characterId;

  const AccountCharacterCreateDto({
    required this.characterId,
  });

  Map<String, dynamic> toJson() {
    return {
      'characterId': characterId,
    };
  }

  @override
  String toString() {
    return 'AccountCharacterCreateDto(characterId: $characterId)';
  }
}

/// DTO cho nhân vật tài khoản
class AccountCharacterDto {
  final int id;
  final int accountId;
  final CharacterDto character;
  final DateTime unlockedAt;
  final bool isFavorite;

  const AccountCharacterDto({
    required this.id,
    required this.accountId,
    required this.character,
    required this.unlockedAt,
    required this.isFavorite,
  });

  factory AccountCharacterDto.fromJson(Map<String, dynamic> json) {
    return AccountCharacterDto(
      id: json['id'] as int,
      accountId: json['accountId'] as int,
      character: CharacterDto.fromJson(json['character'] as Map<String, dynamic>),
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      isFavorite: json['isFavorite'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'character': character.toJson(),
      'unlockedAt': unlockedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return 'AccountCharacterDto(id: $id, accountId: $accountId, character: ${character.name}, isFavorite: $isFavorite)';
  }
}