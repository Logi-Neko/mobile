import 'package:flutter/material.dart';

class ResultScore extends StatelessWidget {
  final int score;
  final int total;

  const ResultScore({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
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
              colors: [
                Colors.orange[400]!,
                Colors.orange[600]!,
              ],
            ),
          ),
          child: const Icon(
            Icons.emoji_events,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "$score/$total",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          "Điểm số tuyệt vời!",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
                (index) => Icon(
              index < (score / total * 5).round()
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
