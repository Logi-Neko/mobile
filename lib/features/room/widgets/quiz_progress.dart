import 'package:flutter/material.dart';

class QuizProgress extends StatelessWidget {
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;

  const QuizProgress({
    Key? key,
    required this.progress,
    this.progressColor = Colors.white,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}