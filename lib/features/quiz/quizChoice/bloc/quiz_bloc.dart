import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/quiz_repo.dart';
import '../dto/quiz.dart';

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

  VideosLoaded({
    required this.videos,
    required this.currentIndex,
    required this.currentVideo,
    required this.progress,
  });

  @override
  List<Object?> get props => [videos, currentIndex, currentVideo, progress];
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

  QuestionAnswered({
    required this.currentVideo,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.videos,
    required this.currentIndex,
    required this.progress,
  });

  @override
  List<Object?> get props => [currentVideo, selectedAnswerIndex, isCorrect, videos, currentIndex, progress];
}

class QuizCompleted extends VideoState {
  final List<VideoData> videos;
  final Map<String, dynamic> completionStats;

  QuizCompleted({
    required this.videos,
    required this.completionStats,
  });

  @override
  List<Object?> get props => [videos, completionStats];
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================
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
        ));
      } else {
        emit(VideoError('No videos found for this lesson'));
      }
    } catch (e) {
      emit(VideoError('Failed to load videos: $e'));
    }
  }

  Future<void> _onLoadVideoById(LoadVideoById event, Emitter<VideoState> emit) async {
    emit(VideoLoading());
    try {
      final video = await _videoRepository.getVideoById(event.id);
      emit(VideoDetailLoaded(video));
    } catch (e) {
      emit(VideoError('Failed to load video: $e'));
    }
  }

  void _onNextVideo(NextVideo event, Emitter<VideoState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final nextIndex = currentState.currentIndex + 1;

      if (nextIndex < currentState.videos.length) {
        final nextVideo = currentState.videos[nextIndex];
        final progress = _calculateProgress(nextIndex, currentState.videos.length);

        emit(VideosLoaded(
          videos: currentState.videos,
          currentIndex: nextIndex,
          currentVideo: nextVideo,
          progress: progress,
        ));
      } else {
        // Quiz completed
        emit(QuizCompleted(
          videos: currentState.videos,
          completionStats: {
            'totalVideos': currentState.videos.length,
            'completedAt': DateTime.now().toIso8601String(),
          },
        ));
      }
    } else if (currentState is QuestionAnswered) {
      final nextIndex = currentState.currentIndex + 1;

      if (nextIndex < currentState.videos.length) {
        final nextVideo = currentState.videos[nextIndex];
        final progress = _calculateProgress(nextIndex, currentState.videos.length);

        emit(VideosLoaded(
          videos: currentState.videos,
          currentIndex: nextIndex,
          currentVideo: nextVideo,
          progress: progress,
        ));
      } else {
        // Quiz completed
        emit(QuizCompleted(
          videos: currentState.videos,
          completionStats: {
            'totalVideos': currentState.videos.length,
            'completedAt': DateTime.now().toIso8601String(),
          },
        ));
      }
    }
  }

  void _onPreviousVideo(PreviousVideo event, Emitter<VideoState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded && currentState.currentIndex > 0) {
      final previousIndex = currentState.currentIndex - 1;
      final previousVideo = currentState.videos[previousIndex];
      final progress = _calculateProgress(previousIndex, currentState.videos.length);

      emit(VideosLoaded(
        videos: currentState.videos,
        currentIndex: previousIndex,
        currentVideo: previousVideo,
        progress: progress,
      ));
    } else if (currentState is QuestionAnswered && currentState.currentIndex > 0) {
      final previousIndex = currentState.currentIndex - 1;
      final previousVideo = currentState.videos[previousIndex];
      final progress = _calculateProgress(previousIndex, currentState.videos.length);

      emit(VideosLoaded(
        videos: currentState.videos,
        currentIndex: previousIndex,
        currentVideo: previousVideo,
        progress: progress,
      ));
    }
  }

  void _onGoToVideo(GoToVideo event, Emitter<VideoState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      if (event.index >= 0 && event.index < currentState.videos.length) {
        final targetVideo = currentState.videos[event.index];
        final progress = _calculateProgress(event.index, currentState.videos.length);

        emit(VideosLoaded(
          videos: currentState.videos,
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
      ));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<VideoState> emit) {
    final currentState = state;
    if (currentState is VideosLoaded) {
      final isCorrect = event.selectedAnswerIndex == currentState.currentVideo.videoQuestion.correctAnswerIndex;

      emit(QuestionAnswered(
        currentVideo: currentState.currentVideo,
        selectedAnswerIndex: event.selectedAnswerIndex,
        isCorrect: isCorrect,
        videos: currentState.videos,
        currentIndex: currentState.currentIndex,
        progress: currentState.progress,
      ));
    }
  }

  Map<String, int> _calculateProgress(int currentIndex, int totalVideos) {
    return {
      'current': currentIndex + 1,
      'total': totalVideos,
    };
  }

  // Helper methods for UI
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