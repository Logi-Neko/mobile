import 'package:flutter/material.dart';

class LessonHeaderWidget extends StatelessWidget {
  final String courseName;
  final String courseDescription;
  final int totalLessons;
  final int completedLessons;
  final VoidCallback onBack;

  const LessonHeaderWidget({
    super.key,
    required this.courseName,
    required this.courseDescription,
    required this.totalLessons,
    required this.completedLessons,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with back button and menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                label: const Text(
                  "Quay lại",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
              Text(
                courseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_outline,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.more_vert,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildStatChip(
                icon: Icons.play_circle_outline,
                label: "Bài học",
                value: "$totalLessons",
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.check_circle,
                label: "Hoàn thành",
                value: "$completedLessons",
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.trending_up,
                label: "Tiến độ",
                value: "${(progress * 100).toInt()}%",
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}