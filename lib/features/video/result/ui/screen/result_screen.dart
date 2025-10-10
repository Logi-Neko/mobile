import 'package:flutter/material.dart';
import 'package:logi_neko/features/video/video_quiz/dto/video.dart';
import '../widgets/result_header.dart';
import '../widgets/result_score.dart';
import '../widgets/result_buttons.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final int? lessonId;
  final String? lessonName;
  final Map<int, String>? submittedAnswers;
  final List<VideoData>? videos;
  final double? percentage;
  final bool? passed;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.total,
    this.lessonId,
    this.lessonName,
    this.submittedAnswers,
    this.videos,
    this.percentage,
    this.passed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final validScore = score.clamp(0, total);
    final validTotal = total > 0 ? total : 1;

    return Scaffold(
      body: Column(
        children: [
          // Header cố định
          ResultHeader(),

          // Nội dung full màn hình
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[50],
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(height: 5),

                            // Score section
                            ResultScore(
                                score: validScore,
                                total: validTotal
                            ),

                            const SizedBox(height: 5),

                            // Buttons section
                            ResultButtons(
                              onRetry: () => _onRetry(context),
                              onHome: () => _onHome(context),
                            ),

                            // Tip container với responsive design
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
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
                                        fontSize: _getResponsiveFontSize(context),
                                        color: Colors.grey[700],
                                        height: 1.3,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tính font size responsive
  double _getResponsiveFontSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 350) {
      return 12.0;
    } else if (screenWidth < 400) {
      return 13.0;
    } else {
      return 14.0;
    }
  }

  void _onRetry(BuildContext context) {
    Navigator.of(context).pop('retry');
  }

  void _onHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}