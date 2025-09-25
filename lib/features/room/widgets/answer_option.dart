import 'package:flutter/material.dart';
import '../../../shared/color/app_color.dart';

class AnswerOption extends StatelessWidget {
  final String option;
  final String letter;
  final bool isSelected;
  final bool isAnswered;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AnswerOption({
    Key? key,
    required this.option,
    required this.letter,
    required this.isSelected,
    required this.isAnswered,
    required this.onTap,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black87;
    Color borderColor = Colors.grey.shade300;

    if (isSelected && isAnswered) {
      backgroundColor = AppColors.primaryPurple;
      textColor = Colors.white;
      borderColor = AppColors.primaryPurple;
    } else if (isSelected) {
      borderColor = AppColors.primaryPurple;
    }

    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected && isAnswered ? Colors.white : AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isSelected && isAnswered ? AppColors.primaryPurple : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}