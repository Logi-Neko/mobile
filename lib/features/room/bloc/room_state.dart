import 'package:equatable/equatable.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';
import 'package:logi_neko/features/room/dto/leaderboard_entry.dart';

abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

// Initial state, waiting to connect
class RoomInitial extends RoomState {}

// Loading state
class RoomLoading extends RoomState {}

// Waiting for the host to reveal the next question
class WaitingForQuestion extends RoomState {}

// A question is currently displayed with a countdown
class QuestionInProgress extends RoomState {
  final QuestionRevealedEvent questionEvent;
  final int countdown;
  final String? selectedAnswer;

  const QuestionInProgress({
    required this.questionEvent,
    required this.countdown,
    this.selectedAnswer,
  });

  @override
  List<Object?> get props => [questionEvent, countdown, selectedAnswer ?? ''];
}

// Showing the leaderboard between questions
class ShowLeaderboard extends RoomState {
  final LeaderboardUpdatedEvent leaderboardEvent;
  final int countdown;

  const ShowLeaderboard({
    required this.leaderboardEvent,
    required this.countdown,
  });

  @override
  List<Object?> get props => [leaderboardEvent, countdown];
}

// The quiz has finished
class QuizFinished extends RoomState {}

// An error occurred
class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}
