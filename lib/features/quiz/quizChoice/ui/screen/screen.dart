// Updated screen.dart - key changes in the BlocConsumer listener
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/answer_button.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/equation_display.dart';
import 'package:logi_neko/features/quiz/quizChoice/ui/widgets/progress_indicator.dart';
import 'package:logi_neko/features/quiz/result/ui/screen/result_screen.dart';
import '../../repository/quiz_repo.dart';
import '../../bloc/quiz_bloc.dart';
import '../../dto/quiz.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class QuizChoiceScreen extends StatelessWidget {
  final int lessonId;
  final String? lessonName;

  const QuizChoiceScreen({
    Key? key,
    required this.lessonId,
    this.lessonName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc(VideoRepositoryImpl())..add(LoadVideosByLessonId(lessonId)),
      child: QuizChoiceView(
        lessonId: lessonId,
        lessonName: lessonName,
      ),
    );
  }
}

class QuizChoiceView extends StatefulWidget {
  final int lessonId;
  final String? lessonName;

  const QuizChoiceView({
    Key? key,
    required this.lessonId,
    this.lessonName,
  }) : super(key: key);

  @override
  _QuizChoiceViewState createState() => _QuizChoiceViewState();
}

class _QuizChoiceViewState extends State<QuizChoiceView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: BlocConsumer<VideoBloc, VideoState>(
            listener: (context, state) {
              if (state is VideoError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Thử lại',
                      onPressed: () {
                        context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
                      },
                    ),
                  ),
                );
              } else if (state is QuizCompleted) {
                // Navigate to result screen instead of showing dialog
                _navigateToResultScreen(state);
              }
            },
            builder: (context, state) {
              if (state is VideoLoading) {
                return _buildLoadingWidget();
              }

              if (state is VideoError) {
                return _buildErrorWidget(state.message);
              }

              if (state is VideosLoaded) {
                return _buildQuizContent(state.currentVideo, state.progress, false, -1);
              }

              if (state is QuestionAnswered) {
                return _buildQuizContent(
                  state.currentVideo,
                  state.progress,
                  true,
                  state.selectedAnswerIndex,
                  isCorrect: state.isCorrect,
                );
              }

              return _buildErrorWidget('Không có dữ liệu');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
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
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
            },
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent(
      VideoData currentVideo,
      Map<String, int> progress,
      bool showResult,
      int selectedAnswer, {
        bool isCorrect = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Header
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
                label: const Text("Quay lại", style: TextStyle(color: Colors.black)),
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

          // Main content
          Expanded(
            child: Row(
              children: [
                // Video/Equation display
                Expanded(
                  flex: 3,
                  child: EquationDisplay(
                    videoData: currentVideo,
                  ),
                ),

                SizedBox(width: 20),

                // Questions and answers
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        currentVideo.videoQuestion.question.isNotEmpty
                            ? currentVideo.videoQuestion.question
                            : 'Hãy chọn đáp án đúng? 🤔',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      // Answer options
                      Expanded(
                        child: _buildAnswerOptions(currentVideo, showResult, selectedAnswer, isCorrect),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Progress and navigation
          GameProgressIndicator(
            current: progress['current']!,
            total: progress['total']!,
            onPrevious: context.read<VideoBloc>().canGoPrevious()
                ? () => context.read<VideoBloc>().add(PreviousVideo())
                : null,
            onNext: context.read<VideoBloc>().canGoNext()
                ? () => context.read<VideoBloc>().add(NextVideo())
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(VideoData currentVideo, bool showResult, int selectedAnswer, bool isCorrect) {
    final options = currentVideo.videoQuestion.validOptions;

    if (options.isEmpty) {
      return Center(
        child: Text(
          'Không có câu hỏi cho video này',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        if (index >= options.length || options[index].isEmpty) {
          return SizedBox.shrink();
        }

        return AnswerButton(
          text: options[index],
          isSelected: selectedAnswer == index,
          isCorrect: index == currentVideo.videoQuestion.correctAnswerIndex,
          showResult: showResult,
          onPressed: showResult
              ? () {}
              : () => _onAnswerSelected(index),
        );
      },
    );
  }

  void _onAnswerSelected(int index) {
    context.read<VideoBloc>().add(AnswerQuestion(index));

    // Auto proceed to next question after showing result
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && context.read<VideoBloc>().canGoNext()) {
        context.read<VideoBloc>().add(NextVideo());
      } else if (mounted) {
        // This is the last question, trigger completion
        context.read<VideoBloc>().add(NextVideo());
      }
    });
  }

  void _navigateToResultScreen(QuizCompleted state) {
    final stats = state.completionStats;

    // Reset orientation to portrait for result screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: stats['correctAnswers'] as int,
          total: stats['totalQuestions'] as int,
          lessonId: widget.lessonId,
          lessonName: widget.lessonName,
          submittedAnswers: state.submittedAnswers,
          videos: state.videos,
          percentage: stats['percentage'] as double,
          passed: stats['passed'] as bool,
        ),
      ),
    );
  }
}