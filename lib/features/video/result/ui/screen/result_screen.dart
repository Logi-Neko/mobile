import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'package:logi_neko/features/home/ui/screen/home_screen.dart';
import 'package:logi_neko/features/video/video_quiz/dto/video.dart';
import '../widgets/result_header.dart';
import '../widgets/result_score.dart';
import '../widgets/result_buttons.dart';

class ResultScreen extends StatefulWidget {
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
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final validScore = widget.score.clamp(0, widget.total);
    final validTotal = widget.total > 0 ? widget.total : 1;

    return WillPopScope(
      onWillPop: () async {
        if (_isNavigating) return false;
        _isNavigating = true;
        Navigator.of(context).pop('completed');
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            ResultHeader(),

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

                              ResultScore(
                                  score: validScore,
                                  total: validTotal
                              ),

                              const SizedBox(height: 5),

                              ResultButtons(
                                onRetry: () => _onRetry(context),
                                onHome: () => _onHome(context),
                              ),

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
      ),
    );
  }

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
    if (_isNavigating) return;
    _isNavigating = true;

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pop('retry');
      }
    });
  }

  void _onHome(BuildContext context) {
    context.router.push(const HomeRoute());
  }
}