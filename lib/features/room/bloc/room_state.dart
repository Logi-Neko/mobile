import 'package:equatable/equatable.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';

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
  final int initialTime; // Initial time for this question
  final bool isSubmitted; // Whether answer has been submitted

  const QuestionInProgress({
    required this.questionEvent,
    required this.countdown,
    this.selectedAnswer,
    required this.initialTime,
    this.isSubmitted = false,
  });

  @override
  List<Object?> get props => [questionEvent, countdown, selectedAnswer ?? '', initialTime, isSubmitted];
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

// Showing correct answer after question ends
class ShowCorrectAnswer extends RoomState {
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int countdown;
  final String? question;  // Thêm dòng này
  final List<String>? options;  // Thêm dòng này

  const ShowCorrectAnswer({
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.countdown,
    this.question,  // Thêm dòng này
    this.options,   // Thêm dòng này
  });

  @override
  List<Object?> get props => [
    userAnswer,
    correctAnswer,
    isCorrect,
    countdown,
    question,   // Thêm dòng này
    options,    // Thêm dòng này
  ];
}

// The quiz has finished
class QuizFinished extends RoomState {
  final int contestId;
  final int totalScore;
  final int totalQuestions;
  final int correctAnswers;
  
  const QuizFinished({
    required this.contestId,
    required this.totalScore,
    required this.totalQuestions,
    required this.correctAnswers,
  });
  
  @override
  List<Object?> get props => [contestId, totalScore, totalQuestions, correctAnswers];
}

// An error occurred
class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}
