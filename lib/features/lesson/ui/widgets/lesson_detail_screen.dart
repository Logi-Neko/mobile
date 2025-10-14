import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../../dto/lesson.dart';
import '../../repository/lesson_repo.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final bool userIsPremium;
  final Future<bool> Function()? onStartLearning;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.userIsPremium,
    this.onStartLearning,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _backgroundController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Animation<double>? _backgroundAnimation;

  late Lesson _currentLesson;
  bool _isLoadingLesson = false;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize current lesson
    _currentLesson = widget.lesson;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
    _backgroundController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _reloadLessonData() async {
    if (_isLoadingLesson) return;

    setState(() {
      _isLoadingLesson = true;
    });
    try {
      final lessonRepo = LessonRepositoryImpl();
      final updatedLesson = await lessonRepo.getLessonById(_currentLesson.id);

      if (mounted) {
        setState(() {
          _currentLesson = updatedLesson;
          _isLoadingLesson = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLesson = false;
        });
      }
    }
  }

  Future<void> _handleStartLearning() async {
    HapticFeedback.mediumImpact();

    if (widget.onStartLearning != null) {
      final shouldReload = await widget.onStartLearning!();

      if (shouldReload && mounted) {
        await _reloadLessonData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation!,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: Stack(
                          children: [
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: _buildMainCard(),
                              ),
                            ),
                            // ✅ Loading overlay khi đang reload
                            if (_isLoadingLesson)
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _animateBack(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLesson.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (_currentLesson.isPremium)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD93D), Color(0xFFFFA726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD93D).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.diamond, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text(
              _currentLesson.description,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _buildProgressSection(),
            const SizedBox(height: 12),
            _buildStatsSection(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _canAccessLesson() ? _handleStartLearning : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient:
                    _canAccessLesson()
                        ? (_currentLesson.isCompleted
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF06D6A0),
                        Color(0xFF38ef7d),
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xFF667eea),
                        Color(0xFF764ba2),
                      ],
                    ))
                        : LinearGradient(
                      colors: [Colors.grey[400]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow:
                    _canAccessLesson()
                        ? [
                      BoxShadow(
                        color: (_currentLesson.isCompleted
                            ? const Color(0xFF06D6A0)
                            : const Color(0xFF667eea))
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _canAccessLesson()
                            ? (_currentLesson.isCompleted
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded)
                            : Icons.lock_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (!_canAccessLesson()) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF667eea),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Cần nâng cấp Premium để truy cập",
                        style: const TextStyle(
                          color: Color(0xFF667eea),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard(
                icon: Icons.play_circle_filled,
                label: "Videos",
                value: "${_currentLesson.totalVideo}",
                color: const Color(0xFF667eea),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.star_rounded,
                label: "Đánh giá",
                value: "${_currentLesson.star}/5",
                color: const Color(0xFFFFD93D),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.schedule_rounded,
                label: "Thời gian",
                value: _currentLesson.formattedDuration,
                color: const Color(0xFF06D6A0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tiến độ học tập",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                    _currentLesson.isCompleted
                        ? [const Color(0xFF06D6A0), const Color(0xFF38ef7d)]
                        : [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _currentLesson.progressText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _currentLesson.progressPercentage / 100,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _currentLesson.isCompleted
                      ? const Color(0xFF06D6A0)
                      : const Color(0xFF667eea),
                ),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canAccessLesson() {
    return _currentLesson.canAccess &&
        (!_currentLesson.isPremium || widget.userIsPremium);
  }

  String _getButtonText() {
    if (!_canAccessLesson()) return "Nâng cấp Premium";
    if (_currentLesson.isCompleted) return "Học lại";
    return "Bắt đầu học";
  }

  void _animateBack(BuildContext context) {
    HapticFeedback.lightImpact();
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}