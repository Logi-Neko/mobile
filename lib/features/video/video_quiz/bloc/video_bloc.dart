// Enhanced video_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/video/result/dto/result.dart';
import '../repository/video_repo.dart';
import '../dto/video.dart';

// Thêm class để track answered questions
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

// Events remain the same...
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

class LoadVideoById extends VideoEvent {
  final int id;
  LoadVideoById(this.id);

  @override
  List<Object?> get props => [id];
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

// Enhanced states
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

  @override
  List<Object?> get props => [videos, currentIndex, currentVideo, progress, answeredQuestions, isAllAnswered];
}

class VideoDetailLoaded extends VideoState {
  final VideoData video;
  VideoDetailLoaded(this.video);

  @override
  List<Object?> get props => [video];
}

class QuestionAnswered extends VideoState {
  final VideoData currentVideo;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final List<VideoData> videos;
  final int currentIndex;
  final Map<String, int> progress;
  final Map<int, AnsweredQuestion> answeredQuestions;
  final bool isAllAnswered;

  QuestionAnswered({
    required this.currentVideo,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.videos,
    required this.currentIndex,
    required this.progress,
    required this.answeredQuestions,
    this.isAllAnswered = false,
  });

  Map<int, String> get submittedAnswers {
    return answeredQuestions.map((key, value) => MapEntry(key, value.submittedAnswer));
  }

  @override
  List<Object?> get props => [currentVideo, selectedAnswerIndex, isCorrect, videos, currentIndex, progress, answeredQuestions, isAllAnswered];
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

  // Calculate local results
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

// Enhanced VideoBloc
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;

  VideoBloc(this._videoRepository) : super(VideoInitial()) {
    on<LoadVideosByLessonId>(_onLoadVideosByLessonId);
    on<LoadVideoById>(_onLoadVideoById);
    on<NextVideo>(_onNextVideo);
    on<PreviousVideo>(_onPreviousVideo);
    on<GoToVideo>(_onGoToVideo);
    on<ResetToFirstVideo>(_onResetToFirstVideo);
    on<AnswerQuestion>(_onAnswerQuestion);
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
        emit(VideoError('No videos found for this lesson'));
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

  Future<void> _onLoadVideoById(LoadVideoById event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final video = await _videoRepository.getVideoById(event.id);
      emit(VideoDetailLoaded(video));
    } on NotFoundException catch (e) {
      emit(VideoError('Không tìm thấy video này', errorCode: e.errorCode));
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

    if (currentState is VideosLoaded || currentState is QuestionAnswered) {
      List<VideoData> videos;
      int currentIndex;
      Map<int, AnsweredQuestion> answeredQuestions;

      if (currentState is VideosLoaded) {
        videos = currentState.videos;
        currentIndex = currentState.currentIndex;
        answeredQuestions = currentState.answeredQuestions;
      } else {
        final answeredState = currentState as QuestionAnswered;
        videos = answeredState.videos;
        currentIndex = answeredState.currentIndex;
        answeredQuestions = answeredState.answeredQuestions;
      }

      final nextIndex = currentIndex + 1;

      if (nextIndex < videos.length) {
        final nextVideo = videos[nextIndex];
        final progress = _calculateProgress(nextIndex, videos.length);
        final isAllAnswered = _checkAllAnswered(videos, answeredQuestions);

        // Check if next question was already answered
        final answeredQuestion = answeredQuestions[nextVideo.id];
        if (answeredQuestion != null) {
          emit(QuestionAnswered(
            currentVideo: nextVideo,
            selectedAnswerIndex: answeredQuestion.selectedAnswerIndex,
            isCorrect: answeredQuestion.isCorrect,
            videos: videos,
            currentIndex: nextIndex,
            progress: progress,
            answeredQuestions: answeredQuestions,
            isAllAnswered: isAllAnswered,
          ));
        } else {
          emit(VideosLoaded(
            videos: videos,
            currentIndex: nextIndex,
            currentVideo: nextVideo,
            progress: progress,
            answeredQuestions: answeredQuestions,
            isAllAnswered: isAllAnswered,
          ));
        }
      } else {
        // Quiz completed
        final submittedAnswers = answeredQuestions.map((key, value) => MapEntry(key, value.submittedAnswer));
        emit(QuizCompleted(
          videos: videos,
          submittedAnswers: submittedAnswers,
        ));
      }
    }
  }

  void _onPreviousVideo(PreviousVideo event, Emitter<VideoState> emit) {
    final currentState = state;

    if (currentState is VideosLoaded || currentState is QuestionAnswered) {
      List<VideoData> videos;
      int currentIndex;
      Map<int, AnsweredQuestion> answeredQuestions;

      if (currentState is VideosLoaded) {
        videos = currentState.videos;
        currentIndex = currentState.currentIndex;
        answeredQuestions = currentState.answeredQuestions;
      } else {
        final answeredState = currentState as QuestionAnswered;
        videos = answeredState.videos;
        currentIndex = answeredState.currentIndex;
        answeredQuestions = answeredState.answeredQuestions;
      }

      if (currentIndex > 0) {
        final previousIndex = currentIndex - 1;
        final previousVideo = videos[previousIndex];
        final progress = _calculateProgress(previousIndex, videos.length);
        final isAllAnswered = _checkAllAnswered(videos, answeredQuestions);

        // Check if previous question was already answered
        final answeredQuestion = answeredQuestions[previousVideo.id];
        if (answeredQuestion != null) {
          emit(QuestionAnswered(
            currentVideo: previousVideo,
            selectedAnswerIndex: answeredQuestion.selectedAnswerIndex,
            isCorrect: answeredQuestion.isCorrect,
            videos: videos,
            currentIndex: previousIndex,
            progress: progress,
            answeredQuestions: answeredQuestions,
            isAllAnswered: isAllAnswered,
          ));
        } else {
          emit(VideosLoaded(
            videos: videos,
            currentIndex: previousIndex,
            currentVideo: previousVideo,
            progress: progress,
            answeredQuestions: answeredQuestions,
            isAllAnswered: isAllAnswered,
          ));
        }
      }
    }
  }

  void _onGoToVideo(GoToVideo event, Emitter<VideoState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      if (event.index >= 0 && event.index < currentState.videos.length) {
        final targetVideo = currentState.videos[event.index];
        final progress = _calculateProgress(event.index, currentState.videos.length);

        emit(currentState.copyWith(
          currentIndex: event.index,
          currentVideo: targetVideo,
          progress: progress,
        ));
      }
    }
  }

  void _onResetToFirstVideo(ResetToFirstVideo event, Emitter<VideoState> emit) {
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

      // Update answered questions
      final updatedAnsweredQuestions = Map<int, AnsweredQuestion>.from(currentState.answeredQuestions);
      updatedAnsweredQuestions[currentState.currentVideo.id] = AnsweredQuestion(
        videoId: currentState.currentVideo.id,
        selectedAnswerIndex: event.selectedAnswerIndex,
        isCorrect: isCorrect,
        submittedAnswer: selectedAnswerLetter,
      );

      final isAllAnswered = _checkAllAnswered(currentState.videos, updatedAnsweredQuestions);

      emit(QuestionAnswered(
        currentVideo: currentState.currentVideo,
        selectedAnswerIndex: event.selectedAnswerIndex,
        isCorrect: isCorrect,
        videos: currentState.videos,
        currentIndex: currentState.currentIndex,
        progress: currentState.progress,
        answeredQuestions: updatedAnsweredQuestions,
        isAllAnswered: isAllAnswered,
      ));
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
    } else if (currentState is QuestionAnswered) {
      return currentState.currentIndex < currentState.videos.length - 1;
    }
    return false;
  }

  bool canGoPrevious() {
    final currentState = state;
    if (currentState is VideosLoaded) {
      return currentState.currentIndex > 0;
    } else if (currentState is QuestionAnswered) {
      return currentState.currentIndex > 0;
    }
    return false;
  }
}