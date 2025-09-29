import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/video/video_quiz//ui/widgets/answer_button.dart';
import 'package:logi_neko/features/video/video_quiz/ui/widgets/equation_display.dart';
import 'package:logi_neko/features/video/video_quiz/ui/widgets/progress_indicator.dart';
import 'package:logi_neko/features/video/result/ui/screen/result_screen.dart';
import '../../repository/video_repo.dart';
import '../../bloc/video_bloc.dart';
import '../../dto/video.dart';
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
                _showErrorSnackBar(context, state);
              } else if (state is QuizCompleted) {
                _navigateToResultScreen(state);
              } else if (state is QuestionAnswered && state.isAllAnswered) {
                // Tự động chuyển qua result khi trả lời xong hết
                _showCompletionOptions(context, state);
              }
            },
            builder: (context, state) {
              if (state is VideoLoading) {
                return _buildLoadingWidget();
              }

              if (state is VideoError) {
                return _buildErrorWidget(state);
              }

              if (state is VideosLoaded) {
                return _buildQuizContent(
                  state.currentVideo,
                  state.progress,
                  false,
                  -1,
                  isAllAnswered: state.isAllAnswered,
                );
              }

              if (state is QuestionAnswered) {
                return _buildQuizContent(
                  state.currentVideo,
                  state.progress,
                  true,
                  state.selectedAnswerIndex,
                  isCorrect: state.isCorrect,
                  isAllAnswered: state.isAllAnswered,
                );
              }

              return _buildErrorWidget(VideoError('Không có dữ liệu'));
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

  Widget _buildErrorWidget(VideoError state) {
    IconData errorIcon = Icons.error_outline;
    String errorTitle = "Có lỗi xảy ra";
    String retryButtonText = "Thử lại";

    if (state.errorCode != null) {
      switch (state.errorCode!) {
        case 'NETWORK_ERROR':
          errorIcon = Icons.wifi_off;
          errorTitle = "Không có kết nối";
          break;
        case 'TIMEOUT_ERROR':
          errorIcon = Icons.access_time;
          errorTitle = "Kết nối quá chậm";
          break;
        case 'UNAUTHORIZED':
          errorIcon = Icons.lock_outlined;
          errorTitle = "Phiên đã hết hạn";
          retryButtonText = "Đăng nhập lại";
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(errorIcon, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            errorTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
            },
            child: Text(retryButtonText),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, VideoError state) {
    Color backgroundColor = Colors.red;
    IconData icon = Icons.error;
    String? actionLabel;
    VoidCallback? action;

    if (state.errorCode != null) {
      switch (state.errorCode!) {
        case 'NETWORK_ERROR':
          backgroundColor = Colors.orange;
          icon = Icons.wifi_off;
          actionLabel = 'Thử lại';
          action = () => context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
          break;
        case 'UNAUTHORIZED':
          backgroundColor = Colors.purple;
          icon = Icons.lock;
          actionLabel = 'Đăng nhập';
          break;
        case 'TIMEOUT_ERROR':
          backgroundColor = Colors.amber;
          icon = Icons.access_time;
          actionLabel = 'Thử lại';
          action = () => context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
          break;
        default:
          actionLabel = 'Thử lại';
          action = () => context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: actionLabel != null && action != null
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: action,
        )
            : null,
      ),
    );
  }

  // Dialog hiển thị khi hoàn thành tất cả câu hỏi
  void _showCompletionOptions(BuildContext context, QuestionAnswered state) {
    // Capture bloc instance trước khi tạo dialog
    final videoBloc = context.read<VideoBloc>();

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.celebration, color: Colors.amber[600], size: 28),
                  SizedBox(width: 8),
                  Text('Hoàn thành!'),
                ],
              ),
              content: Text(
                'Bạn đã trả lời hết tất cả câu hỏi!\nBạn có muốn xem kết quả ngay bây giờ?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Xem lại'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Sử dụng bloc instance đã capture
                    videoBloc.add(NextVideo()); // This will trigger QuizCompleted
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Xem kết quả'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  Widget _buildQuizContent(
      VideoData currentVideo,
      Map<String, int> progress,
      bool showResult,
      int selectedAnswer, {
        bool isCorrect = false,
        bool isAllAnswered = false,
      }) {
    return Padding(
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

              Row(
                children: [
                  // Nút "Xem kết quả" khi đã hoàn thành
                  if (isAllAnswered) ...[
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          // Sử dụng context hiện tại để tránh lỗi Provider
                          context.read<VideoBloc>().add(NextVideo());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assessment, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Kết quả',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
            ],
          ),

          SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: EquationDisplay(
                    videoData: currentVideo,
                  ),
                ),

                SizedBox(width: 20),

                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        currentVideo.videoQuestion.question.isNotEmpty
                            ? currentVideo.videoQuestion.question
                            : 'Hãy chọn đáp án đúng?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

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

          GameProgressIndicator(
            current: progress['current']!,
            total: progress['total']!,
            onPrevious: context.read<VideoBloc>().canGoPrevious()
                ? () => context.read<VideoBloc>().add(PreviousVideo())
                : null,
            onNext: context.read<VideoBloc>().canGoNext() || isAllAnswered
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
              ? () {}  // Disabled after answer is selected
              : () => _onAnswerSelected(index),
        );
      },
    );
  }

  void _onAnswerSelected(int index) {
    // Chỉ submit answer và hiển thị kết quả
    context.read<VideoBloc>().add(AnswerQuestion(index));
  }

  void _navigateToResultScreen(QuizCompleted state) async {
    final stats = state.completionStats;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final result = await Navigator.pushReplacement(
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

    // Handle retry if result = true
    if (result == true && mounted) {
      // Reset quiz to first video
      context.read<VideoBloc>().add(ResetToFirstVideo());
    }
  }
}