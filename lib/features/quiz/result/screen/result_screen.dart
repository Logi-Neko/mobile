import 'package:flutter/material.dart';
import '../widgets/result_header.dart';
import '../widgets/result_score.dart';
import '../widgets/result_buttons.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ResultHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 10),
                  ResultScore(score: score, total: total),
                  const SizedBox(height: 10),
                  ResultButtons(),
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Hãy tiếp tục luyện tập để trở thành bậc thầy về logic!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}