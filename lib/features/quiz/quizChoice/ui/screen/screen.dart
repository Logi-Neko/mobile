import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/answer_button.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/equation_display.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/progress_indicator.dart';
import '../../repository/quiz_repo.dart';
import '../../bloc/quiz.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class QuizChoiceScreen extends StatefulWidget {
  final int lessonId;
  final String? lessonName;

  const QuizChoiceScreen({
    Key? key,
    required this.lessonId,
    this.lessonName,
  }) : super(key: key);

  @override
  _QuizChoiceScreenState createState() => _QuizChoiceScreenState();
}

class _QuizChoiceScreenState extends State<QuizChoiceScreen> {
  int selectedAnswer = -1;
  bool showResult = false;
  bool isLoading = true;
  String? errorMessage;

  final QuizRepository _quizRepository = QuizRepository();
  VideoData? currentVideo;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadQuizData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _quizRepository.getVideosByLessonId(widget.lessonId);
      _updateCurrentVideo();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Không thể tải dữ liệu: ${e.toString()}';
      });
    }
  }

  void _updateCurrentVideo() {
    setState(() {
      currentVideo = _quizRepository.getCurrentVideo();
      selectedAnswer = -1;
      showResult = false;
    });
  }

  void onAnswerSelected(int index) {
    if (currentVideo == null) return;

    setState(() {
      selectedAnswer = index;
      showResult = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          selectedAnswer = -1;
          showResult = false;
        });
      }
    });
  }

  void _goToNextVideo() {
    if (_quizRepository.nextVideo()) {
      _updateCurrentVideo();
    } else {
      // Đã hết video
      _showCompletionDialog();
    }
  }

  void _goToPreviousVideo() {
    if (_quizRepository.previousVideo()) {
      _updateCurrentVideo();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hoàn thành!'),
          content: Text('Bạn đã hoàn thành tất cả các câu hỏi.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Quay về màn hình trước
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang tải dữ liệu...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                errorMessage ?? 'Có lỗi xảy ra',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuizData,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (errorMessage != null) {
      return _buildErrorWidget();
    }

    if (currentVideo == null) {
      return _buildErrorWidget();
    }

    final progress = _quizRepository.getProgress();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text("Quay lại",
                          style: TextStyle(color: Colors.black)),
                    ),

                    Text(
                      widget.lessonName ?? "Bài học",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: EquationDisplay(
                          videoData: currentVideo!,
                        ),
                      ),

                      SizedBox(width: 20),

                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              currentVideo!.videoQuestion.question.isNotEmpty
                                  ? currentVideo!.videoQuestion.question
                                  : 'Hãy chọn đáp án đúng? 🤔',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 20),

                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: currentVideo!.videoQuestion.options.length,
                                itemBuilder: (context, index) {
                                  final options = currentVideo!.videoQuestion.options;
                                  if (index >= options.length || options[index].isEmpty) {
                                    return SizedBox.shrink();
                                  }

                                  return AnswerButton(
                                    text: options[index],
                                    isSelected: selectedAnswer == index,
                                    isCorrect: index == currentVideo!.videoQuestion.correctAnswerIndex,
                                    showResult: showResult,
                                    onPressed: () => onAnswerSelected(index),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                GameProgressIndicator(
                  current: progress['current']!,
                  total: progress['total']!,
                  onPrevious: _quizRepository.hasPreviousVideo() ? _goToPreviousVideo : null,
                  onNext: _quizRepository.hasNextVideo() ? _goToNextVideo : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}