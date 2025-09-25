import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

class QuizHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final VoidCallback? onBackPressed;

  const QuizHeader({
    Key? key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBackPressed ?? () => context.router.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
        ),
        Text(
          'Câu ${currentQuestionIndex + 1}/$totalQuestions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }
}