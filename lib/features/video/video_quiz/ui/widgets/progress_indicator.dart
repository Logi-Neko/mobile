import 'package:flutter/material.dart';

class GameProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const GameProgressIndicator({
    Key? key,
    required this.current,
    required this.total,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          GestureDetector(
            onTap: onPrevious,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: onPrevious != null
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.arrow_back,
                color: onPrevious != null
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
                size: 28,
              ),
            ),
          ),

          SizedBox(width: 20),

          // Progress Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current/$total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LinearProgressIndicator(
                    value: current / total,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 20),

          // Next Button
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: onNext != null
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: onNext != null
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}