import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/color/app_color.dart';
import '../../api/character_account_api.dart';
import '../../api/account_character_dto.dart';
import '../../api/character_dto.dart';
import '../../bloc/character_account_bloc.dart';
import '../../repository/character_account_repository.dart';

@RoutePage()
class MyCharacterScreen extends StatelessWidget {
  const MyCharacterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyCharacterView();
  }
}

class MyCharacterView extends StatefulWidget {
  const MyCharacterView({super.key});

  @override
  State<MyCharacterView> createState() => _MyCharacterViewState();
}

class _MyCharacterViewState extends State<MyCharacterView> {
  List<AccountCharacterDto>? _allCharacters;
  List<AccountCharacterDto>? _filteredCharacters;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _loadMyCharacters();
  }

  Future<void> _loadMyCharacters() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await CharacterAccountApi.getAllAccountCharacters();

      if (response.isSuccess && response.hasData) {
        setState(() {
          _allCharacters = response.data!;
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.message ?? 'Không thể tải bộ sưu tập nhân vật';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Có lỗi xảy ra: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_allCharacters == null) return;

    if (_showFavoritesOnly) {
      _filteredCharacters =
          _allCharacters!.where((character) => character.isFavorite).toList();
    } else {
      _filteredCharacters = List.from(_allCharacters!);
    }
  }

  Future<void> _toggleFilter() async {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
      _applyFilter();
    });
  }

  void _refreshCharacterInList(AccountCharacterDto updatedCharacter) {
    if (_allCharacters == null) return;

    setState(() {
      // Update the character in the main list
      final index = _allCharacters!.indexWhere(
        (c) => c.character.id == updatedCharacter.character.id,
      );
      if (index != -1) {
        _allCharacters![index] = updatedCharacter;
      }

      // Reapply filter to update the displayed list
      _applyFilter();
    });
  }

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
                _buildHeader(context),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showFavoritesOnly ? _toggleFilter : null,
            icon: const Icon(Icons.collections, size: 18),
            label: const Text('Tất cả'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  !_showFavoritesOnly
                      ? const Color(0xFF9C27B0)
                      : Colors.grey[300],
              foregroundColor:
                  !_showFavoritesOnly ? Colors.white : Colors.grey[600],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: !_showFavoritesOnly ? 2 : 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: !_showFavoritesOnly ? _toggleFilter : null,
            icon: const Icon(Icons.favorite, size: 18),
            label: const Text('Yêu thích'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _showFavoritesOnly
                      ? const Color(0xFFFF9800)
                      : Colors.grey[300],
              foregroundColor:
                  _showFavoritesOnly ? Colors.white : Colors.grey[600],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: _showFavoritesOnly ? 2 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.router.push(
              const HomeRoute(),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF002171),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              'Bộ Sưu Tập Nhân Vật',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Character count
          if (_filteredCharacters != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.collections, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_filteredCharacters!.length}',
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

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_filteredCharacters == null || _filteredCharacters!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCharacterCollection();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải bộ sưu tập...',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadMyCharacters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9C27B0),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.collections_outlined,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chưa có nhân vật nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hãy mở khóa nhân vật đầu tiên của bạn!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.router.pushAndPopUntil(
                       CharacterRoute(),
                      predicate: (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9C27B0),
                  ),
                  child: const Text('Đi đến cửa hàng'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCollection() {
    // Group characters by rarity
    final commonCharacters =
        _filteredCharacters!
            .where((c) => c.character.rarity == CharacterRarity.common)
            .toList();
    final rareCharacters =
        _filteredCharacters!
            .where((c) => c.character.rarity == CharacterRarity.rare)
            .toList();
    final epicCharacters =
        _filteredCharacters!
            .where((c) => c.character.rarity == CharacterRarity.epic)
            .toList();
    final legendaryCharacters =
        _filteredCharacters!
            .where((c) => c.character.rarity == CharacterRarity.legendary)
            .toList();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFF8DC), // Cream background
        borderRadius: BorderRadius.circular(12),
      ),
      child: RefreshIndicator(
        onRefresh: _loadMyCharacters,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Collection stats
              _buildCollectionStats(),

              const SizedBox(height: 16),

              // Filter buttons
              _buildFilterButtons(),

              const SizedBox(height: 20),

              // Character sections by rarity
              if (legendaryCharacters.isNotEmpty) ...[
                _buildRaritySection(
                  'Huyền Thoại',
                  legendaryCharacters,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 20),
              ],

              if (epicCharacters.isNotEmpty) ...[
                _buildRaritySection(
                  'Sử Thi',
                  epicCharacters,
                  const Color(0xFF9C27B0),
                ),
                const SizedBox(height: 20),
              ],

              if (rareCharacters.isNotEmpty) ...[
                _buildRaritySection(
                  'Hiếm',
                  rareCharacters,
                  const Color(0xFF2196F3),
                ),
                const SizedBox(height: 20),
              ],

              if (commonCharacters.isNotEmpty) ...[
                _buildRaritySection(
                  'Thường',
                  commonCharacters,
                  const Color(0xFF4CAF50),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionStats() {
    final totalCharacters = _allCharacters?.length ?? 0;
    final favoriteCharacters =
        _allCharacters?.where((c) => c.isFavorite).length ?? 0;
    final displayedCharacters = _filteredCharacters?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.1),
            const Color(0xFF7B1FA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalCharacters',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const Text(
                  'Tổng nhân vật',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 35,
            color: const Color(0xFF9C27B0).withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$favoriteCharacters',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
                const Text(
                  'Yêu thích',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 35,
            color: const Color(0xFF9C27B0).withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$displayedCharacters',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const Text(
                  'Hiển thị',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaritySection(
    String title,
    List<AccountCharacterDto> characters,
    Color themeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
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
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${characters.length}',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Character grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final accountCharacter = characters[index];
            return _buildCharacterCard(accountCharacter, themeColor);
          },
        ),
      ],
    );
  }

  Widget _buildCharacterCard(
    AccountCharacterDto accountCharacter,
    Color themeColor,
  ) {
    final character = accountCharacter.character;

    return GestureDetector(
      onTap: () => _showCharacterDetail(accountCharacter),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.2),
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
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          character.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: themeColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: themeColor,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Character name
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Favorite indicator
            if (accountCharacter.isFavorite)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCharacterDetail(AccountCharacterDto accountCharacter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _CharacterDetailModal(
            accountCharacter: accountCharacter,
            onFavoriteChanged: _refreshCharacterInList,
          ),
    );
  }
}

class _CharacterDetailModal extends StatefulWidget {
  final AccountCharacterDto accountCharacter;
  final Function(AccountCharacterDto) onFavoriteChanged;

  const _CharacterDetailModal({
    required this.accountCharacter,
    required this.onFavoriteChanged,
  });

  @override
  State<_CharacterDetailModal> createState() => _CharacterDetailModalState();
}

class _CharacterDetailModalState extends State<_CharacterDetailModal> {
  late AccountCharacterDto accountCharacter;
  bool _isUpdatingFavorite = false;
  bool _isChoosingCharacter = false;

  @override
  void initState() {
    super.initState();
    accountCharacter = widget.accountCharacter;
  }

  Future<void> _toggleFavorite() async {
    if (_isUpdatingFavorite) return;

    setState(() {
      _isUpdatingFavorite = true;
    });

    try {
      final response = await CharacterAccountApi.setFavoriteCharacter(
        accountCharacter.character.id,
        !accountCharacter.isFavorite,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          accountCharacter = response.data!;
        });

        // Notify parent to refresh the list
        widget.onFavoriteChanged(accountCharacter);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accountCharacter.isFavorite
                    ? 'Đã thêm vào yêu thích'
                    : 'Đã bỏ khỏi yêu thích',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi cập nhật trạng thái yêu thích'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingFavorite = false;
        });
      }
    }
  }

  Future<void> _chooseCharacter() async {
    if (_isChoosingCharacter) return;

    setState(() {
      _isChoosingCharacter = true;
    });

    try {
      final response = await CharacterAccountApi.chooseCharacter(
        accountCharacter.id,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã chọn ${accountCharacter.character.name} làm nhân vật chính',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Close the modal
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi chọn nhân vật chính'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChoosingCharacter = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final character = accountCharacter.character;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Character image
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Choose character button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _isChoosingCharacter ? null : _chooseCharacter,
                      icon:
                          _isChoosingCharacter
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(Icons.star, color: Colors.white),
                      label: Text(
                        _isChoosingCharacter
                            ? 'Đang chọn...'
                            : 'Chọn làm nhân vật chính',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Character name with favorite icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C27B0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (accountCharacter.isFavorite) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite, color: Colors.red, size: 20),
                      ],
                    ],
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

                  const SizedBox(height: 20),

                  // Favorite toggle button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _isUpdatingFavorite ? null : _toggleFavorite,
                      icon:
                          _isUpdatingFavorite
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Icon(
                                accountCharacter.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                      label: Text(
                        _isUpdatingFavorite
                            ? 'Đang cập nhật...'
                            : (accountCharacter.isFavorite
                                ? 'Bỏ yêu thích'
                                : 'Thêm yêu thích'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            accountCharacter.isFavorite
                                ? Colors.red
                                : Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Character info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Độ hiếm',
                          _getRarityText(character.rarity),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Sao yêu cầu',
                          '${character.starRequired}',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Mở khóa lúc',
                          _formatDate(accountCharacter.unlockedAt),
                        ),
                        if (character.isPremium) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Loại', 'Premium'),
                        ],
                      ],
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
            color: Color(0xFF9C27B0),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
