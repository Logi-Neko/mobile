import 'package:flutter/material.dart';
import '../../dto/course.dart';

class CourseGridWidget extends StatelessWidget {
  final List<Course> courses;
  final bool isLoading;
  final String? error;
  final String? errorCode;
  final VoidCallback? onRetry;
  final Function(Course)? onCourseSelected;
  final String emptyMessage;
  final int crossAxisCount;

  const CourseGridWidget({
    super.key,
    required this.courses,
    this.isLoading = false,
    this.error,
    this.errorCode,
    this.onRetry,
    this.onCourseSelected,
    this.emptyMessage = "Chưa có khóa học nào",
    this.crossAxisCount = 4,
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
              "Đang tải khóa học...",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return _buildEnhancedErrorWidget();
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, color: Colors.white, size: 60),
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
              "Hãy quay lại sau để xem các khóa học mới",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 213,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return CourseCard(
                  course: courses[index],
                  onTap: onCourseSelected != null
                      ? () => onCourseSelected!(courses[index])
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedErrorWidget() {
    IconData errorIcon = Icons.error_outline;
    String errorTitle = "Có lỗi xảy ra";
    Color errorColor = Colors.white;
    String retryButtonText = "Thử lại";

    // Customize based on error code
    if (errorCode != null) {
      switch (errorCode!) {
        case 'NETWORK_ERROR':
          errorIcon = Icons.wifi_off;
          errorTitle = "Không có kết nối";
          retryButtonText = "Kiểm tra kết nối";
          break;
        case 'TIMEOUT_ERROR':
          errorIcon = Icons.access_time;
          errorTitle = "Kết nối quá chậm";
          retryButtonText = "Thử lại";
          break;
        case 'UNAUTHORIZED':
          errorIcon = Icons.lock_outlined;
          errorTitle = "Phiên đã hết hạn";
          retryButtonText = "Đăng nhập lại";
          break;
        case 'NOT_FOUND':
          errorIcon = Icons.search_off;
          errorTitle = "Không tìm thấy";
          retryButtonText = "Làm mới";
          break;
        case 'SERVER_ERROR':
          errorIcon = Icons.cloud_off;
          errorTitle = "Lỗi máy chủ";
          retryButtonText = "Thử lại sau";
          break;
        default:
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorIcon, color: errorColor, size: 60),
          const SizedBox(height: 16),
          Text(
            errorTitle,
            style: TextStyle(
              color: errorColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                errorCode == 'NETWORK_ERROR' ? Icons.refresh : Icons.refresh,
                size: 18,
              ),
              label: Text(retryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
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
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      course.thumbnailUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 30, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  if (course.isPremium) _buildPremiumBadge(),
                  if (!course.isActive) _buildInactiveBadge(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${course.totalLesson} bài học",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text(
              "Premium",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveBadge() {
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
                "Chưa mở",
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
}