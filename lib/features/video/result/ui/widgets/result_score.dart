import 'package:flutter/material.dart';

class ResultScore extends StatelessWidget {
  final int score;
  final int total;

  const ResultScore({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final safeTotal = total > 0 ? total : 1;
    final safeScore = score.clamp(0, safeTotal);
    final percentage = safeScore / safeTotal;
    final starCount = (percentage * 5).round().clamp(0, 5);

    IconData resultIcon;
    List<Color> gradientColors;
    String motivationText;

    if (safeScore == 0) {
      resultIcon = Icons.sentiment_dissatisfied;
      gradientColors = [Colors.grey[400]!, Colors.grey[600]!];
      motivationText = "Cố gắng lần sau nhé!";
    } else if (percentage < 0.5) {
      resultIcon = Icons.sentiment_neutral;
      gradientColors = [Colors.orange[300]!, Colors.orange[500]!];
      motivationText = "Cần cải thiện thêm!";
    } else if (percentage < 0.8) {
      resultIcon = Icons.sentiment_satisfied;
      gradientColors = [Colors.orange[400]!, Colors.orange[600]!];
      motivationText = "Kết quả tốt!";
    } else {
      resultIcon = Icons.emoji_events;
      gradientColors = [Colors.amber[400]!, Colors.amber[600]!];
      motivationText = "Điểm số tuyệt vời!";
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Icon(
            resultIcon,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "$safeScore/$safeTotal",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          motivationText,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
                (index) => Icon(
              index < starCount ? Icons.star : Icons.star_border,
              color: Colors.amber[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}