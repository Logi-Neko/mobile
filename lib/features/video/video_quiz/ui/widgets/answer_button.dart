import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onPressed;
  final bool hasSpeaker;

  const AnswerButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onPressed,
    this.hasSpeaker = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    bool showSpeakerIcon = false;

    if (showResult && isSelected) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade800;
        showSpeakerIcon = true;
      } else {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
        showSpeakerIcon = true;
      }
    } else if (showResult && isCorrect && !isSelected) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      textColor = Colors.green.shade700;
      showSpeakerIcon = true;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.black87;
      showSpeakerIcon = hasSpeaker && !showResult;
    }

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: showResult && (isSelected || (isCorrect && !isSelected)) ? 2 : 1,
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
              )
            else if (showResult && isCorrect && !isSelected)
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
          ],
        ),
        child: Center(
          child: SingleChildScrollView(
            // THÊM SCROLL ĐỂ TRÁNH OVERFLOW
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // QUAN TRỌNG
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // QUAN TRỌNG
                  children: [
                    if (showSpeakerIcon && !showResult) ...[
                      Icon(
                        Icons.volume_up,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                      SizedBox(width: 4),
                    ],
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
                        maxLines: 2,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}