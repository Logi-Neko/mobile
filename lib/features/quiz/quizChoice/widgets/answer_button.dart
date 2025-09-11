import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onPressed;

  const AnswerButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (showResult && isSelected) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
      } else {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      }
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: showResult ? null : onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: showResult && isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (showResult && isSelected && isCorrect)
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            else if (showResult && isSelected && !isCorrect)
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showResult && isSelected) ...[
                SizedBox(width: 4),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}