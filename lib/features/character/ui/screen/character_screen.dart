import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import '../../../../core/router/app_router.dart';
import '../../bloc/character_bloc.dart';
import '../../repository/character_repository.dart';
import '../../api/character_dto.dart';
import '../../api/character_account_api.dart';
import '../../api/account_character_dto.dart';
import 'package:logi_neko/shared/color/app_color.dart';

@RoutePage()
class CharacterScreen extends StatelessWidget {
  final User? user;

  const CharacterScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CharacterBloc(CharacterRepositoryImpl())
                ..add(LoadAllCharactersLocked()),
      child: CharacterView(user: user),
    );
  }
}

class CharacterView extends StatelessWidget {
  final User? user;

  const CharacterView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                // Compact Header
                _buildCompactHeader(context),

                // Shop Content
                Expanded(
                  child: BlocBuilder<CharacterBloc, CharacterState>(
                    builder: (context, state) {
                      print(
                        'CharacterScreen BlocBuilder state: ${state.runtimeType}',
                      );
                      if (state is CharacterLoading) {
                        return _buildLoadingState();
                      } else if (state is CharactersLockedLoaded) {
                        return _buildShopLayout(context, state.characters);
                      } else if (state is CharacterError) {
                        return _buildErrorState(context, state.message);
                      } else if (state is CharacterInitial) {
                        // Show loading when in initial state
                        return _buildLoadingState();
                      } else if (state is CharacterDetailLoaded) {
                        // If somehow we get detail loaded state, trigger reload
                        print(
                          'Unexpected CharacterDetailLoaded state, triggering reload',
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<CharacterBloc>().add(
                            LoadAllCharactersLocked(),
                          );
                        });
                        return _buildLoadingState();
                      } else if (state is CharactersByRarityLoaded) {
                        // If somehow we get rarity loaded state, trigger reload
                        print(
                          'Unexpected CharactersByRarityLoaded state, triggering reload',
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<CharacterBloc>().add(
                            LoadAllCharactersLocked(),
                          );
                        });
                        return _buildLoadingState();
                      }
                      // Fallback: show loading and trigger reload
                      print(
                        'Unknown state: ${state.runtimeType}, triggering reload',
                      );
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<CharacterBloc>().add(
                          LoadAllCharactersLocked(),
                        );
                      });
                      return _buildLoadingState();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    final userStars = user?.starDisplay ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.router.push(
              const HomeRoute(),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF002171),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              'Cửa Hàng Nhân Vật',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Coins display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF002171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$userStars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopLayout(BuildContext context, List<CharacterDto> characters) {
    if (characters.isEmpty) {
      return _buildEmptyState();
    }

    // Group characters by rarity for shelf organization
    final commonCharacters =
        characters.where((c) => c.rarity == CharacterRarity.common).toList();
    final rareCharacters =
        characters.where((c) => c.rarity == CharacterRarity.rare).toList();
    final epicCharacters =
        characters.where((c) => c.rarity == CharacterRarity.epic).toList();
    final legendaryCharacters =
        characters.where((c) => c.rarity == CharacterRarity.legendary).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC), // Cream background like in the image
        borderRadius: BorderRadius.circular(12),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<CharacterBloc>().add(LoadAllCharactersLocked());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Free Coins Task Banner (similar to the image)
              _buildTaskBanner(),

              const SizedBox(height: 20),

              // Character Shelves
              if (commonCharacters.isNotEmpty) ...[
                _buildShelfSection(
                  context,
                  'Nhân Vật Thường',
                  commonCharacters,
                  const Color(0xFF4CAF50), // Green for common
                  30, // Stars required
                ),
                const SizedBox(height: 20),
              ],

              if (rareCharacters.isNotEmpty) ...[
                _buildShelfSection(
                  context,
                  'Nhân Vật Hiếm',
                  rareCharacters,
                  const Color(0xFF2196F3), // Blue for rare
                  50, // Stars required
                ),
                const SizedBox(height: 20),
              ],

              if (epicCharacters.isNotEmpty) ...[
                _buildShelfSection(
                  context,
                  'Nhân Vật Sử Thi',
                  epicCharacters,
                  const Color(0xFF9C27B0), // Purple for epic
                  80, // Stars required
                ),
                const SizedBox(height: 20),
              ],

              if (legendaryCharacters.isNotEmpty) ...[
                _buildShelfSection(
                  context,
                  'Nhân Vật Huyền Thoại',
                  legendaryCharacters,
                  const Color(0xFFFF9800), // Orange for legendary
                  120, // Stars required
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFB347), const Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Characters illustration
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 12),

          // Text content
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhiệm Vụ Nhận Sao',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hoàn thành bài học để nhận sao',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildShelfSection(
    BuildContext context,
    String title,
    List<CharacterDto> characters,
    Color themeColor,
    int starsRequired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with stars requirement
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$starsRequired',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal shelf with characters
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildShelfCharacterCard(
                  context,
                  character,
                  themeColor,
                  starsRequired,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShelfCharacterCard(
    BuildContext context,
    CharacterDto character,
    Color themeColor,
    int starsRequired,
  ) {
    // Simulate user's current stars (this should come from user data)
    const int userStars = 120;
    final bool isUnlocked = userStars >= starsRequired;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          _showCharacterDetail(context, character);
        } else {
          _showLockedCharacterDialog(context, starsRequired);
        }
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Character content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Character image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isUnlocked ? null : Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            isUnlocked
                                ? Image.network(
                                  character.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: themeColor.withValues(alpha: 0.2),
                                      child: Icon(
                                        Icons.person,
                                        color: themeColor,
                                        size: 30,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.lock,
                                    color: Colors.grey[600],
                                    size: 30,
                                  ),
                                ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Character name
                  Text(
                    character.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Stars required
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: isUnlocked ? Colors.amber : Colors.grey,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        character.starRequired.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isUnlocked ? themeColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Premium badge
            if (character.isPremium && isUnlocked)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải cửa hàng...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Oops! Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                context.read<CharacterBloc>().add(LoadAllCharactersLocked());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),

            SizedBox(height: 24),

            Text(
              'Cửa hàng đang cập nhật',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Hãy quay lại sau để khám phá những nhân vật mới!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCharacterDetail(BuildContext context, CharacterDto character) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: _CharacterDetailModal(character: character),
        );
      },
    );
  }

  void _showLockedCharacterDialog(BuildContext context, int starsRequired) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock, color: Colors.orange),
                SizedBox(width: 8),
                Text('Nhân vật bị khóa'),
              ],
            ),
            content: Text(
              'Bạn cần $starsRequired sao để mở khóa nhân vật này.\nHãy hoàn thành các bài học để nhận thêm sao!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to lessons or tasks
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Làm bài'),
              ),
            ],
          ),
    );
  }
}

class _CharacterDetailModal extends StatelessWidget {
  final CharacterDto character;

  const _CharacterDetailModal({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Character image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        character.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Character name
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    character.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Character info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Độ hiếm',
                          _getRarityText(character.rarity),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Sao cần thiết',
                          '${character.starRequired}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Loại',
                          character.isPremium ? 'Premium' : 'Miễn phí',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Unlock button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _unlockCharacter(context, character),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Mở khóa nhân vật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  String _getRarityText(CharacterRarity rarity) {
    switch (rarity) {
      case CharacterRarity.common:
        return 'Thường';
      case CharacterRarity.rare:
        return 'Hiếm';
      case CharacterRarity.epic:
        return 'Sử thi';
      case CharacterRarity.legendary:
        return 'Huyền thoại';
    }
  }

  void _unlockCharacter(BuildContext context, CharacterDto character) async {
    try {
      print('Starting unlock process for character: ${character.name}');
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create AccountCharacterCreateDto for unlock API
      final createDto = AccountCharacterCreateDto(characterId: character.id);

      // Call unlock API using CharacterAccountApi
      print('Calling unlock API for character ID: ${character.id}');
      await CharacterAccountApi.createAccountCharacter(createDto);
      print('Unlock API call successful');

      // Close loading dialog if mounted
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Close character info modal if mounted
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message if mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã mở khóa nhân vật ${character.name} thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh character list if mounted
      if (context.mounted) {
        print('Triggering LoadAllCharactersLocked after successful unlock');
        context.read<CharacterBloc>().add(LoadAllCharactersLocked());
      }
    } catch (e) {
      print('Error during unlock process: $e');
      // Close loading dialog if mounted
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message if mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
