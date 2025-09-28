import 'package:flutter/material.dart';
import '../../dto/lesson.dart';

class LessonGridWidget extends StatelessWidget {
  final List<Lesson> lessons;
  final bool isLoading;
  final String? error;
  final String? errorCode;
  final VoidCallback? onRetry;
  final Function(Lesson)? onLessonSelected;
  final String emptyMessage;

  const LessonGridWidget({
    super.key,
    required this.lessons,
    this.isLoading = false,
    this.error,
    this.errorCode,
    this.onRetry,
    this.onLessonSelected,
    this.emptyMessage = "Chưa có bài học nào",
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Đang tải bài học...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildEnhancedErrorWidget();
    }

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy quay lại sau để xem các bài học mới",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.75;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 4;
          childAspectRatio = 0.8;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.85;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 1.2;
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                return LessonCard(
                  lesson: lessons[index],
                  onTap: onLessonSelected != null
                      ? () => onLessonSelected!(lessons[index])
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedErrorWidget() {
    IconData errorIcon = Icons.error_outline;
    String errorTitle = "Có lỗi xảy ra";
    String retryButtonText = "Thử lại";

    if (errorCode != null) {
      switch (errorCode!) {
        case 'NETWORK_ERROR':
          errorIcon = Icons.wifi_off;
          errorTitle = "Không có kết nối";
          break;
        case 'TIMEOUT_ERROR':
          errorIcon = Icons.access_time;
          errorTitle = "Kết nối quá chậm";
          break;
        case 'UNAUTHORIZED':
          errorIcon = Icons.lock_outlined;
          errorTitle = "Phiên đã hết hạn";
          retryButtonText = "Đăng nhập lại";
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorIcon, color: Colors.white, size: 60),
          const SizedBox(height: 16),
          Text(
            errorTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(retryButtonText),
            ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildThumbnail(),
            ),
            Expanded(
              flex: 1,
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: lesson.thumbnailUrl != null && lesson.thumbnailUrl!.isNotEmpty
                ? Image.network(
              lesson.thumbnailUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
                : _buildPlaceholder(),
          ),

          // Play overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

          // Order badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Bài ${lesson.order}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (lesson.isPremium) _buildPremiumBadge(),

          if (!lesson.canAccess) _buildLockOverlay(),

          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lesson.formattedDuration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            lesson.mediaType == 'video' ? Icons.play_circle_outline : Icons.article_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            lesson.mediaType == 'video' ? "Video" : "Bài học",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              lesson.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              if (lesson.totalVideo > 0)
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "${lesson.totalVideo}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),

              if (lesson.star > 0)
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "${lesson.star}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

              const Spacer(),

              _buildStatusIndicator(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white, size: 10),
            SizedBox(width: 2),
            Text(
              "Premium",
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: Colors.white, size: 30),
              SizedBox(height: 4),
              Text(
                "Premium",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (lesson.isCompleted) {
      return const Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.green,
      );
    } else if (lesson.hasProgress) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: lesson.progressPercentage / 100,
              strokeWidth: 2,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Text(
            "${lesson.star}",
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      );
    } else {
      return Icon(
        Icons.circle_outlined,
        size: 16,
        color: Colors.grey[400],
      );
    }
  }
}