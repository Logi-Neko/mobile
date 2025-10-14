import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/text_to_speech/tts.dart';
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

class _QuizChoiceViewState extends State<QuizChoiceView> with WidgetsBindingObserver {
  final TTSService _ttsService = TTSService();
  bool _autoReadEnabled = true;
  bool _ttsInitialized = false;
  bool _isReadingQuestion = false;
  Set<int> _soundPlayedForVideos = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initializeTTS();
    _ttsService.addListener(_onTTSStateChanged);
  }

  void _onTTSStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _ttsService.forceStop();
    }
  }

  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
      final isSupported = await _ttsService.isVietnameseSupported();
      if (mounted) {
        setState(() {
          _ttsInitialized = isSupported;
          _autoReadEnabled = isSupported;
        });
      }
    } catch (e) {
      print('Error initializing TTS: $e');
      if (mounted) {
        setState(() {
          _ttsInitialized = false;
          _autoReadEnabled = false;
        });
      }
    }
  }

  @override
  void deactivate() {
    _ttsService.forceStop();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ttsService.removeListener(_onTTSStateChanged);
    _isReadingQuestion = false;
    _soundPlayedForVideos.clear();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _ttsService.forceStop();
    super.dispose();
  }

  Future<void> _stopTTSAndWait() async {
    await _ttsService.forceStop();
    await Future.delayed(Duration(milliseconds: 150));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _stopTTSAndWait();
        Navigator.of(context).pop('back');
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: BlocConsumer<VideoBloc, VideoState>(
              listener: (context, state) {
                print('=== BlocListener State: ${state.runtimeType} ===');

                if (state is VideoError) {
                  _showErrorSnackBar(context, state);
                } else if (state is QuizCompleted) {
                  _ttsService.forceStop();
                  _navigateToResultScreen(state);
                } else if (state is QuestionAnswered && state.isAllAnswered) {
                  _showCompletionOptions(context, state);
                } else if (state is QuestionAnswered) {
                  final videoId = state.currentVideo.id;
                  print('TTS: QuestionAnswered - videoId: $videoId');
                  print('TTS: _soundPlayedForVideos: $_soundPlayedForVideos');
                  print('TTS: _autoReadEnabled: $_autoReadEnabled, _ttsInitialized: $_ttsInitialized');

                  if (_ttsInitialized && _autoReadEnabled && !_soundPlayedForVideos.contains(videoId)) {
                    _soundPlayedForVideos.add(videoId);
                    _ttsService.forceStop();

                    print('TTS: ✅ Playing sound for video $videoId (first time)');

                    Future.delayed(Duration(milliseconds: 300), () {
                      if (mounted && _autoReadEnabled) {
                        if (state.isCorrect) {
                          _ttsService.playSuccessSound();
                        } else {
                          _ttsService.playErrorSound();
                        }
                      }
                    });
                  } else {
                    print('TTS: ❌ Skipping sound for video $videoId');
                    _ttsService.forceStop();
                  }
                } else if (state is VideosLoaded) {
                  print('TTS: VideosLoaded - not playing anything');
                  _ttsService.forceStop();
                } else {
                  _ttsService.forceStop();
                }
              },
              builder: (context, state) {
                if (state is VideoLoading) {
                  return _buildLoadingWidget();
                }

                if (state is VideoError) {
                  return _buildErrorWidget(state);
                }

                if (state is VideoWatchMode) {
                  return _buildWatchModeContent(state);
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
      ),
    );
  }

  Future<void> _readQuestion(VideoData video) async {
    if (!_ttsInitialized || !_autoReadEnabled) return;

    if (_isReadingQuestion || _ttsService.isSpeaking) {
      print('Already reading question, skipping...');
      return;
    }

    _isReadingQuestion = true;

    await _ttsService.forceStop();
    await Future.delayed(Duration(milliseconds: 200));

    final question = video.videoQuestion.question;
    final options = video.videoQuestion.validOptions;

    if (question.isNotEmpty && options.isNotEmpty) {
      print('TTS: Starting to read question');
      await _ttsService.speakVietnameseQuestion(question, options);
    }

    _isReadingQuestion = false;
  }

  Widget _buildWatchModeContent(VideoWatchMode state) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black),
                    ),
                    minimumSize: Size(0, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () async {
                    await _stopTTSAndWait();
                    Navigator.pop(context, 'completed');
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                  label: const Text("Quay lại", style: TextStyle(color: Colors.black, fontSize: 14)),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: Text(
                    widget.lessonName ?? "Bài học",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 12),
                _buildQuestionButton(state),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: EquationDisplay(videoData: state.currentVideo),
          ),
        )
      ],
    );
  }

  Widget _buildQuestionButton(VideoWatchMode state) {
    final hasQuestion = state.currentVideo.videoQuestion.question.isNotEmpty;
    final hasAnswered = state.answeredQuestions.containsKey(state.currentVideo.id);

    if (hasQuestion) {
      return ElevatedButton(
        onPressed: () {
          context.read<VideoBloc>().add(ShowQuestion());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: hasAnswered ? Colors.orange : Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
          minimumSize: Size(0, 36),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasAnswered ? Icons.edit : Icons.quiz, size: 16),
            SizedBox(width: 6),
            Text(
              hasAnswered ? 'Xem câu hỏi' : 'Trả lời câu hỏi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 14),
            SizedBox(width: 4),
            Text(
              'Chỉ xem',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...', style: TextStyle(color: Colors.white, fontSize: 16)),
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
          Text(errorTitle, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14)),
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
            ? SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: action)
            : null,
      ),
    );
  }

  void _showCompletionOptions(BuildContext context, QuestionAnswered state) {
    final videoBloc = context.read<VideoBloc>();

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted && _ttsInitialized) {
        _ttsService.speakCompletion(
            state.answeredQuestions.values.where((q) => q.isCorrect).length,
            state.videos.length);
      }

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
                    videoBloc.add(NextVideo());
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
    final hasAnswered = showResult;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Header with controls
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
                onPressed: () {
                  _ttsService.forceStop();
                  _isReadingQuestion = false;
                  context.read<VideoBloc>().add(HideQuestion());
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                label: const Text("Xem video", style: TextStyle(color: Colors.black)),
              ),
              Expanded(
                child: Text(
                  widget.lessonName ?? "Bài học",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  if (_ttsInitialized) ...[
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          _ttsService.forceStop();
                          _isReadingQuestion = false;
                          setState(() {
                            _autoReadEnabled = !_autoReadEnabled;
                          });

                          if (!_autoReadEnabled) {
                            _soundPlayedForVideos.clear();
                            print('TTS: Cleared sound history');
                          }
                        },
                        icon: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _autoReadEnabled
                                ? Colors.green.withOpacity(0.8)
                                : Colors.grey.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _autoReadEnabled ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    if (_autoReadEnabled)
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () async {
                            if (_ttsService.isSpeaking) {
                              await _ttsService.forceStop();
                              _isReadingQuestion = false;
                            } else if (!_isReadingQuestion) {
                              _readQuestion(currentVideo);
                            }
                          },
                          icon: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _ttsService.isSpeaking
                                  ? Colors.red.withOpacity(0.8)
                                  : Colors.blue.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _ttsService.isSpeaking ? Icons.stop : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                  if (isAllAnswered) ...[
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<VideoBloc>().add(NextVideo());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assessment, size: 16),
                            SizedBox(width: 4),
                            Text('Kết quả', style: TextStyle(fontSize: 12)),
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
                    onPressed: () async {
                      await _stopTTSAndWait();
                      Navigator.pop(context, 'completed');
                    },
                  ),
                ],
              ),
            ],
          ),

          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                currentVideo.videoQuestion.question.isNotEmpty
                                    ? currentVideo.videoQuestion.question
                                    : 'Hãy chọn đáp án đúng?',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (hasAnswered) ...[
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isCorrect ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.info,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Đã trả lời',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // Answer options
                  Expanded(
                    child: _buildAnswerOptions(currentVideo, showResult, selectedAnswer, isCorrect),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // Progress indicator
          GameProgressIndicator(
            current: progress['current']!,
            total: progress['total']!,
            onPrevious: context.read<VideoBloc>().canGoPrevious()
                ? () {
              _ttsService.forceStop();
              _isReadingQuestion = false;
              context.read<VideoBloc>().add(PreviousVideo());
            }
                : null,
            onNext: context.read<VideoBloc>().canGoNext() || isAllAnswered
                ? () {
              _ttsService.forceStop();
              _isReadingQuestion = false;
              context.read<VideoBloc>().add(NextVideo());
            }
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
        child: Text('Không có câu hỏi cho video này', style: TextStyle(color: Colors.white70, fontSize: 14)),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      padding: EdgeInsets.symmetric(horizontal: 80),
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
              ? () => _readOption(options[index], index)
              : () => _onAnswerSelected(index),
        );
      },
    );
  }

  Future<void> _readOption(String option, int index) async {
    if (_ttsInitialized && _autoReadEnabled) {
      await _ttsService.speakOption(option, index);
    }
  }

  void _onAnswerSelected(int index) {
    _ttsService.forceStop();
    _isReadingQuestion = false;
    context.read<VideoBloc>().add(AnswerQuestion(index));
  }

  void _navigateToResultScreen(QuizCompleted state) async {
    final stats = state.completionStats;

    await _stopTTSAndWait();

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

    if (result == 'retry' && mounted) {
      context.read<VideoBloc>().add(ResetToFirstVideo());
    } else if (result == 'home' || result == null) {
      if (mounted) {
        Navigator.of(context).pop('completed');
      }
    }
  }
}