import 'package:equatable/equatable.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

// Event to start the quiz and connect to WebSocket
class StartQuizEvent extends RoomEvent {
  final int contestId;
  final int participantId;

  const StartQuizEvent({required this.contestId, required this.participantId});

  @override
  List<Object?> get props => [contestId, participantId];
}

// Internal event when a WebSocket message is received
class GameEventReceived extends RoomEvent {
  final GameEvent gameEvent;
  const GameEventReceived(this.gameEvent);

  @override
  List<Object?> get props => [gameEvent];
}

// Fallback event to load questions when WebSocket doesn't work
class LoadQuestionsFallback extends RoomEvent {
  const LoadQuestionsFallback();
}

// Event when user selects an answer
class AnswerSelectedEvent extends RoomEvent {
  final String answer;
  const AnswerSelectedEvent(this.answer);

  @override
  List<Object?> get props => [answer];
}

// Internal event for the 30s question timer
class QuestionTimerTicked extends RoomEvent {}

// Internal event for the 5s leaderboard timer
class LeaderboardTimerTicked extends RoomEvent {}

// Event to disconnect from WebSocket
class DisconnectEvent extends RoomEvent {}

// Internal event for the correct answer display timer
class CorrectAnswerTimerTicked extends RoomEvent {}

// Event to show leaderboard and move to next question
class ShowLeaderboardEvent extends RoomEvent {}
