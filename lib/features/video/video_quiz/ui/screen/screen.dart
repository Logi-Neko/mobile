import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/core/text_to_speech/tts.dart';
import 'package:logi_neko/features/video/result/ui/screen/result_screen.dart';
import '../../repository/video_repo.dart';
import '../../bloc/video_bloc.dart';
import '../../dto/video.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../widgets/media_display.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_indicator.dart';

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
  bool _isNavigating = false;

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
      if (mounted) {
        setState(() {
          _ttsInitialized = false;
          _autoReadEnabled = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isNavigating = true;
    try {
      context.read<VideoBloc>().setNavigating(true);
    } catch (e) {
      print('DEBUG: BLoC already disposed');
    }
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

  Future<void> _cleanupBeforeNavigation() async {
    if (_isNavigating) return;
    _isNavigating = true;
    _isReadingQuestion = false;
    await _ttsService.forceStop();
    await Future.delayed(Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _cleanupBeforeNavigation();
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
              listener: (context, state) async {
                if (_isNavigating && state is! QuizCompleted) {
                  return;
                }

                if (state is VideoError) {
                  if (!_isNavigating) {
                    _showErrorSnackBar(context, state);
                  }
                } else if (state is QuizCompleted) {
                  if (_isNavigating) return;
                  _isNavigating = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _navigateToResultScreen(state);
                    }
                  });
                } else if (state is VideosLoaded) {
                  // Play sound for correct/incorrect answer
                  if (state.hasAnsweredCurrent) {
                    final videoId = state.currentVideo.id;
                    if (_ttsInitialized && _autoReadEnabled && !_soundPlayedForVideos.contains(videoId)) {
                      _soundPlayedForVideos.add(videoId);
                      _ttsService.forceStop();

                      Future.delayed(Duration(milliseconds: 300), () {
                        if (mounted && _autoReadEnabled && !_isNavigating) {
                          if (state.currentAnswer!.isCorrect) {
                            _ttsService.playSuccessSound();
                          } else {
                            _ttsService.playErrorSound();
                          }
                        }
                      });
                    }
                  }

                  // Show completion dialog if all answered
                  if (state.isAllAnswered && !state.hasAnsweredCurrent) {
                    _showCompletionOptions(context, state);
                  }
                }
              },
              builder: (context, state) {
                if (_isNavigating && state is! VideoLoading && state is! VideoError && state is! QuizCompleted) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang xử lý...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (state is VideoLoading) {
                  return _buildLoadingWidget();
                }

                if (state is VideoError) {
                  return _buildErrorWidget(state);
                }

                if (state is VideosLoaded) {
                  return _buildMainContent(state);
                }

                if (state is QuizCompleted) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải kết quả...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(VideosLoaded state) {
    return Column(
      children: [
        // Header
        _buildHeader(state),

        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Media display
                Expanded(
                  flex: 5,
                  child: MediaDisplay(
                    videoData: state.currentVideo,
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  flex: 5,
                  child: _buildQuestionSection(state),
                ),
              ],
            ),
          ),
        ),

        // Bottom progress bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GameProgressIndicator(
            current: state.progress['current']!,
            total: state.progress['total']!,
            onPrevious: context.read<VideoBloc>().canGoPrevious()
                ? () {
              if (!_isNavigating) {
                _ttsService.forceStop();
                _isReadingQuestion = false;
                context.read<VideoBloc>().add(PreviousVideo());
              }
            }
                : null,
            onNext: context.read<VideoBloc>().canGoNext() || state.isAllAnswered
                ? () {
              if (!_isNavigating) {
                _ttsService.forceStop();
                _isReadingQuestion = false;
                context.read<VideoBloc>().add(NextVideo());
              }
            }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(VideosLoaded state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          _buildBackButton(),

          SizedBox(width: 20),

          Expanded(
            child: Text(
              state.currentVideo.title ?? "Bài học",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(width: 20),

          // TTS controls
          _buildTTSControls(state),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            if (_isNavigating) return;
            await _ttsService.forceStop();
            _isReadingQuestion = false;
            await Future.delayed(Duration(milliseconds: 100));
            if (mounted) {
              Navigator.pop(context, 'completed');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2E3A87),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Quay lại",
                  style: TextStyle(
                    color: Color(0xFF2E3A87),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTTSControls(VideosLoaded state) {
    return Row(
      children: [
        if (_ttsInitialized) ...[
          IconButton(
            onPressed: () {
              if (!_isNavigating) {
                _ttsService.forceStop();
                _isReadingQuestion = false;
                setState(() {
                  _autoReadEnabled = !_autoReadEnabled;
                });
                if (!_autoReadEnabled) {
                  _soundPlayedForVideos.clear();
                }
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
                size: 24,
              ),
            ),
          ),
          if (_autoReadEnabled)
            IconButton(
              onPressed: () async {
                if (_isNavigating) return;
                if (_ttsService.isSpeaking) {
                  await _ttsService.forceStop();
                  _isReadingQuestion = false;
                } else if (!_isReadingQuestion) {
                  _readQuestion(state.currentVideo);
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
                  size: 24,
                ),
              ),
            ),
        ],
        if (state.isAllAnswered) ...[
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isNavigating
                ? null
                : () {
              if (_isNavigating) return;
              context.read<VideoBloc>().add(NextVideo());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              disabledBackgroundColor: Colors.grey,
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
        ],
      ],
    );
  }

  Widget _buildQuestionSection(VideosLoaded state) {
    final hasAnswered = state.hasAnsweredCurrent;
    final currentAnswer = state.currentAnswer;

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          // Question header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  state.currentVideo.videoQuestion.question.isNotEmpty
                      ? state.currentVideo.videoQuestion.question
                      : 'Hãy chọn đáp án đúng?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (hasAnswered) ...[
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: currentAnswer!.isCorrect ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentAnswer.isCorrect ? Icons.check_circle : Icons.info,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Đã trả lời',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 20),

          // Answer options
          Expanded(
            child: _buildAnswerOptions(state),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(VideosLoaded state) {
    final options = state.currentVideo.videoQuestion.validOptions;
    final hasAnswered = state.hasAnsweredCurrent;
    final currentAnswer = state.currentAnswer;

    if (options.isEmpty) {
      return Center(
        child: Text(
          'Không có câu hỏi cho video này',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
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
          isSelected: hasAnswered && currentAnswer!.selectedAnswerIndex == index,
          isCorrect: index == state.currentVideo.videoQuestion.correctAnswerIndex,
          showResult: hasAnswered,
          onPressed: hasAnswered
              ? () => _readOption(options[index], index)
              : () => _onAnswerSelected(index),
        );
      },
    );
  }

  Future<void> _readQuestion(VideoData video) async {
    if (!_ttsInitialized || !_autoReadEnabled || _isNavigating) return;
    if (_isReadingQuestion || _ttsService.isSpeaking) return;

    _isReadingQuestion = true;
    await _ttsService.forceStop();
    await Future.delayed(Duration(milliseconds: 200));

    if (!mounted || _isNavigating) {
      _isReadingQuestion = false;
      return;
    }

    final question = video.videoQuestion.question;
    final options = video.videoQuestion.validOptions;

    if (question.isNotEmpty && options.isNotEmpty) {
      await _ttsService.speakVietnameseQuestion(question, options);
    }
    _isReadingQuestion = false;
  }

  Future<void> _readOption(String option, int index) async {
    if (_ttsInitialized && _autoReadEnabled && !_isNavigating) {
      await _ttsService.speakOption(option, index);
    }
  }

  void _onAnswerSelected(int index) {
    if (!_isNavigating) {
      _ttsService.forceStop();
      _isReadingQuestion = false;
      context.read<VideoBloc>().add(AnswerQuestion(index));
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
              if (!_isNavigating) {
                context.read<VideoBloc>().add(LoadVideosByLessonId(widget.lessonId));
              }
            },
            child: Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, VideoError state) {
    if (_isNavigating) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showCompletionOptions(BuildContext context, VideosLoaded state) {
    if (_isNavigating) return;

    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted || _isNavigating) return;

      if (_ttsInitialized && _autoReadEnabled) {
        _ttsService.speakCompletion(
          state.answeredQuestions.values.where((q) => q.isCorrect).length,
          state.videos.length,
        );
      }

      if (!mounted || _isNavigating) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
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
                    if (_isNavigating) return;
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Xem lại'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_isNavigating) return;
                    Navigator.of(dialogContext).pop();
                    await Future.delayed(Duration(milliseconds: 100));
                    if (!mounted) return;
                    context.read<VideoBloc>().add(NextVideo());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Xem kết quả'),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Future<void> _navigateToResultScreen(QuizCompleted state) async {
    await _cleanupBeforeNavigation();
    if (!mounted) return;

    final stats = state.completionStats;

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await Future.delayed(Duration(milliseconds: 100));
    if (!mounted) return;

    final result = await Navigator.push(
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

    _isNavigating = false;

    if (!mounted) return;

    if (result == 'retry') {
      context.read<VideoBloc>().add(ResetToFirstVideo());
    } else if (result == 'home' || result == null) {
      Navigator.of(context).pop('completed');
    }
  }
}