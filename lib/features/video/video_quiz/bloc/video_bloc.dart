import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/video/result/dto/result.dart';
import '../repository/video_repo.dart';
import '../dto/video.dart';

class AnsweredQuestion extends Equatable {
  final int videoId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final String submittedAnswer;

  const AnsweredQuestion({
    required this.videoId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.submittedAnswer,
  });

  @override
  List<Object?> get props => [videoId, selectedAnswerIndex, isCorrect, submittedAnswer];
}

// Events
abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVideosByLessonId extends VideoEvent {
  final int lessonId;
  LoadVideosByLessonId(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class NextVideo extends VideoEvent {}
class PreviousVideo extends VideoEvent {}

class GoToVideo extends VideoEvent {
  final int index;
  GoToVideo(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetToFirstVideo extends VideoEvent {}

class AnswerQuestion extends VideoEvent {
  final int selectedAnswerIndex;
  AnswerQuestion(this.selectedAnswerIndex);

  @override
  List<Object?> get props => [selectedAnswerIndex];
}

// States
abstract class VideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}
class VideoLoading extends VideoState {}

class VideosLoaded extends VideoState {
  final List<VideoData> videos;
  final int currentIndex;
  final VideoData currentVideo;
  final Map<String, int> progress;
  final Map<int, AnsweredQuestion> answeredQuestions;
  final bool isAllAnswered;

  VideosLoaded({
    required this.videos,
    required this.currentIndex,
    required this.currentVideo,
    required this.progress,
    this.answeredQuestions = const {},
    this.isAllAnswered = false,
  });

  VideosLoaded copyWith({
    List<VideoData>? videos,
    int? currentIndex,
    VideoData? currentVideo,
    Map<String, int>? progress,
    Map<int, AnsweredQuestion>? answeredQuestions,
    bool? isAllAnswered,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      currentVideo: currentVideo ?? this.currentVideo,
      progress: progress ?? this.progress,
      answeredQuestions: answeredQuestions ?? this.answeredQuestions,
      isAllAnswered: isAllAnswered ?? this.isAllAnswered,
    );
  }

  Map<int, String> get submittedAnswers {
    return answeredQuestions.map((key, value) => MapEntry(key, value.submittedAnswer));
  }

  bool get hasAnsweredCurrent => answeredQuestions.containsKey(currentVideo.id);

  AnsweredQuestion? get currentAnswer => answeredQuestions[currentVideo.id];

  @override
  List<Object?> get props => [videos, currentIndex, currentVideo, progress, answeredQuestions, isAllAnswered];
}

class QuizCompleted extends VideoState {
  final List<VideoData> videos;
  final Map<int, String> submittedAnswers;
  final QuizResultData? resultData;

  QuizCompleted({
    required this.videos,
    required this.submittedAnswers,
    this.resultData,
  });

  Map<String, dynamic> get completionStats {
    int correctAnswers = 0;
    int totalQuestions = videos.length;

    for (int i = 0; i < videos.length; i++) {
      final video = videos[i];
      final submittedAnswer = submittedAnswers[video.id];
      if (submittedAnswer != null) {
        final correctAnswer = ['A', 'B', 'C', 'D'][video.videoQuestion.correctAnswerIndex];
        if (submittedAnswer == correctAnswer) {
          correctAnswers++;
        }
      }
    }

    double percentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
      'passed': percentage >= 60,
      'completedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [videos, submittedAnswers, resultData];
}

class VideoError extends VideoState {
  final String message;
  final String? errorCode;

  VideoError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// Bloc
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;
  bool _isNavigating = false;

  VideoBloc(this._videoRepository) : super(VideoInitial()) {
    on<LoadVideosByLessonId>(_onLoadVideosByLessonId);
    on<NextVideo>(_onNextVideo);
    on<PreviousVideo>(_onPreviousVideo);
    on<GoToVideo>(_onGoToVideo);
    on<ResetToFirstVideo>(_onResetToFirstVideo);
    on<AnswerQuestion>(_onAnswerQuestion);
  }

  void setNavigating(bool isNavigating) {
    _isNavigating = isNavigating;
  }

  Future<void> _onLoadVideosByLessonId(LoadVideosByLessonId event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final videos = await _videoRepository.getVideosByLessonId(event.lessonId);
      if (videos.isNotEmpty) {
        final currentVideo = videos.first;
        final progress = _calculateProgress(0, videos.length);

        emit(VideosLoaded(
          videos: videos,
          currentIndex: 0,
          currentVideo: currentVideo,
          progress: progress,
          answeredQuestions: {},
        ));
      } else {
        emit(VideoError('Không tìm thấy video cho bài học này'));
      }
    } on NotFoundException catch (e) {
      emit(VideoError('Không tìm thấy video cho bài học này', errorCode: e.errorCode));
    } on NetworkException catch (e) {
      emit(VideoError('Không có kết nối mạng', errorCode: e.errorCode));
    } on UnauthorizedException catch (e) {
      emit(VideoError('Phiên đăng nhập đã hết hạn', errorCode: e.errorCode));
    } on AppException catch (e) {
      final errorMessage = ExceptionHelper.getLocalizedErrorMessage(e);
      emit(VideoError(errorMessage, errorCode: e.errorCode));
    } catch (e) {
      emit(VideoError('Có lỗi không xác định xảy ra khi tải video'));
    }
  }

  void _onNextVideo(NextVideo event, Emitter<VideoState> emit) {
    final currentState = state;

    if (currentState is VideosLoaded) {
      final nextIndex = currentState.currentIndex + 1;

      if (nextIndex < currentState.videos.length) {
        if (_isNavigating) return;

        final nextVideo = currentState.videos[nextIndex];
        final progress = _calculateProgress(nextIndex, currentState.videos.length);
        final isAllAnswered = _checkAllAnswered(currentState.videos, currentState.answeredQuestions);

        emit(currentState.copyWith(
          currentIndex: nextIndex,
          currentVideo: nextVideo,
          progress: progress,
          isAllAnswered: isAllAnswered,
        ));
      } else {
        // Complete quiz
        final submittedAnswers = currentState.answeredQuestions.map((key, value) => MapEntry(key, value.submittedAnswer));
        emit(QuizCompleted(
          videos: currentState.videos,
          submittedAnswers: submittedAnswers,
        ));
      }
    }
  }

  void _onPreviousVideo(PreviousVideo event, Emitter<VideoState> emit) {
    if (_isNavigating) return;

    final currentState = state;
    if (currentState is VideosLoaded && currentState.currentIndex > 0) {
      final previousIndex = currentState.currentIndex - 1;
      final previousVideo = currentState.videos[previousIndex];
      final progress = _calculateProgress(previousIndex, currentState.videos.length);
      final isAllAnswered = _checkAllAnswered(currentState.videos, currentState.answeredQuestions);

      emit(currentState.copyWith(
        currentIndex: previousIndex,
        currentVideo: previousVideo,
        progress: progress,
        isAllAnswered: isAllAnswered,
      ));
    }
  }

  void _onGoToVideo(GoToVideo event, Emitter<VideoState> emit) {
    if (_isNavigating) return;

    final currentState = state;
    if (currentState is VideosLoaded) {
      if (event.index >= 0 && event.index < currentState.videos.length) {
        final targetVideo = currentState.videos[event.index];
        final progress = _calculateProgress(event.index, currentState.videos.length);
        final isAllAnswered = _checkAllAnswered(currentState.videos, currentState.answeredQuestions);

        emit(currentState.copyWith(
          currentIndex: event.index,
          currentVideo: targetVideo,
          progress: progress,
          isAllAnswered: isAllAnswered,
        ));
      }
    }
  }

  void _onResetToFirstVideo(ResetToFirstVideo event, Emitter<VideoState> emit) {
    if (_isNavigating) return;

    final currentState = state;
    if (currentState is VideosLoaded && currentState.videos.isNotEmpty) {
      final firstVideo = currentState.videos.first;
      final progress = _calculateProgress(0, currentState.videos.length);

      emit(VideosLoaded(
        videos: currentState.videos,
        currentIndex: 0,
        currentVideo: firstVideo,
        progress: progress,
        answeredQuestions: {},
      ));
    } else if (currentState is QuizCompleted) {
      final firstVideo = currentState.videos.first;
      final progress = _calculateProgress(0, currentState.videos.length);

      emit(VideosLoaded(
        videos: currentState.videos,
        currentIndex: 0,
        currentVideo: firstVideo,
        progress: progress,
        answeredQuestions: {},
      ));
    }
  }

  Future<void> _onAnswerQuestion(AnswerQuestion event, Emitter<VideoState> emit) async {
    if (_isNavigating) return;

    final currentState = state;
    if (currentState is VideosLoaded) {
      final isCorrect = event.selectedAnswerIndex == currentState.currentVideo.videoQuestion.correctAnswerIndex;
      final selectedAnswerLetter = ['A', 'B', 'C', 'D'][event.selectedAnswerIndex];

      try {
        await _videoRepository.submitVideoAnswer(
          currentState.currentVideo.id,
          selectedAnswerLetter,
        );
      } catch (e) {
        print('Failed to submit answer: $e');
      }

      final updatedAnsweredQuestions = Map<int, AnsweredQuestion>.from(currentState.answeredQuestions);
      updatedAnsweredQuestions[currentState.currentVideo.id] = AnsweredQuestion(
        videoId: currentState.currentVideo.id,
        selectedAnswerIndex: event.selectedAnswerIndex,
        isCorrect: isCorrect,
        submittedAnswer: selectedAnswerLetter,
      );

      final isAllAnswered = _checkAllAnswered(currentState.videos, updatedAnsweredQuestions);

      emit(currentState.copyWith(
        answeredQuestions: updatedAnsweredQuestions,
        isAllAnswered: isAllAnswered,
      ));

      // Show completion dialog if all answered
      if (isAllAnswered) {
        // This will be handled by the UI listener
      }
    }
  }

  bool _checkAllAnswered(List<VideoData> videos, Map<int, AnsweredQuestion> answeredQuestions) {
    return videos.every((video) => answeredQuestions.containsKey(video.id));
  }

  Map<String, int> _calculateProgress(int currentIndex, int totalVideos) {
    return {
      'current': currentIndex + 1,
      'total': totalVideos,
    };
  }

  bool canGoNext() {
    final currentState = state;
    if (currentState is VideosLoaded) {
      return currentState.currentIndex < currentState.videos.length - 1;
    }
    return false;
  }

  bool canGoPrevious() {
    final currentState = state;
    if (currentState is VideosLoaded) {
      return currentState.currentIndex > 0;
    }
    return false;
  }
}