import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../dto/question.dart';

// Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuizEvent extends RoomEvent {}

class AnswerQuestionEvent extends RoomEvent {
  final String selectedAnswer;
  final int questionIndex;

  const AnswerQuestionEvent({
    required this.selectedAnswer,
    required this.questionIndex,
  });

  @override
  List<Object?> get props => [selectedAnswer, questionIndex];
}

class NextQuestionEvent extends RoomEvent {}

class FinishQuizEvent extends RoomEvent {}

// States
abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class QuizInProgressState extends RoomState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<int, String> answers;
  final bool isAnswered;
  final String? selectedAnswer;

  const QuizInProgressState({
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    this.isAnswered = false,
    this.selectedAnswer,
  });

  @override
  List<Object?> get props => [
    questions,
    currentQuestionIndex,
    answers,
    isAnswered,
    selectedAnswer,
  ];

  QuizInProgressState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<int, String>? answers,
    bool? isAnswered,
    String? selectedAnswer,
  }) {
    return QuizInProgressState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isAnswered: isAnswered ?? this.isAnswered,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
    );
  }
}

class QuizCompletedState extends RoomState {
  final List<Question> questions;
  final Map<int, String> answers;
  final int score;

  const QuizCompletedState({
    required this.questions,
    required this.answers,
    required this.score,
  });

  @override
  List<Object?> get props => [questions, answers, score];
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class RoomBloc extends Bloc<RoomEvent, RoomState> {
  RoomBloc() : super(RoomInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<NextQuestionEvent>(_onNextQuestion);
    on<FinishQuizEvent>(_onFinishQuiz);
  }

  void _onLoadQuiz(LoadQuizEvent event, Emitter<RoomState> emit) async {
    try {
      emit(RoomLoading());
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock questions for testing
      final questions = [
        Question(
          id: 1,
          question: "2 + 2 = ?",
          options: ["3", "4", "5", "6"],
          correctAnswer: "4",
        ),
        Question(
          id: 2,
          question: "Thủ đô của Việt Nam là gì?",
          options: ["Hồ Chí Minh", "Hà Nội", "Đà Nẵng", "Cần Thơ"],
          correctAnswer: "Hà Nội",
        ),
        Question(
          id: 3,
          question: "10 x 5 = ?",
          options: ["45", "50", "55", "60"],
          correctAnswer: "50",
        ),
      ];

      if (questions.isEmpty) {
        emit(const RoomError("Không có câu hỏi nào để hiển thị"));
        return;
      }

      emit(QuizInProgressState(
        questions: questions,
        currentQuestionIndex: 0,
        answers: {},
      ));
    } catch (e) {
      emit(RoomError("Lỗi khi tải câu hỏi: ${e.toString()}"));
    }
  }

  void _onAnswerQuestion(AnswerQuestionEvent event, Emitter<RoomState> emit) {
    try {
      final currentState = state;
      if (currentState is QuizInProgressState) {
        // Validate question index
        if (event.questionIndex < 0 || event.questionIndex >= currentState.questions.length) {
          emit(const RoomError("Chỉ số câu hỏi không hợp lệ"));
          return;
        }

        // Validate answer option
        final question = currentState.questions[event.questionIndex];
        if (!question.options.contains(event.selectedAnswer)) {
          emit(const RoomError("Lựa chọn câu trả lời không hợp lệ"));
          return;
        }

        final updatedAnswers = Map<int, String>.from(currentState.answers);
        updatedAnswers[event.questionIndex] = event.selectedAnswer;

        emit(currentState.copyWith(
          answers: updatedAnswers,
          isAnswered: true,
          selectedAnswer: event.selectedAnswer,
        ));
      }
    } catch (e) {
      emit(RoomError("Lỗi khi lưu câu trả lời: ${e.toString()}"));
    }
  }

  void _onNextQuestion(NextQuestionEvent event, Emitter<RoomState> emit) {
    try {
      final currentState = state;
      if (currentState is QuizInProgressState) {
        final nextIndex = currentState.currentQuestionIndex + 1;
        
        if (nextIndex < currentState.questions.length) {
          emit(currentState.copyWith(
            currentQuestionIndex: nextIndex,
            isAnswered: false,
            selectedAnswer: null,
          ));
        } else {
          // Quiz completed
          add(FinishQuizEvent());
        }
      }
    } catch (e) {
      emit(RoomError("Lỗi khi chuyển câu hỏi: ${e.toString()}"));
    }
  }

  void _onFinishQuiz(FinishQuizEvent event, Emitter<RoomState> emit) {
    try {
      final currentState = state;
      if (currentState is QuizInProgressState) {
        int score = 0;
        for (int i = 0; i < currentState.questions.length; i++) {
          final userAnswer = currentState.answers[i];
          final correctAnswer = currentState.questions[i].correctAnswer;
          if (userAnswer == correctAnswer) {
            score++;
          }
        }

        emit(QuizCompletedState(
          questions: currentState.questions,
          answers: currentState.answers,
          score: score,
        ));
      }
    } catch (e) {
      emit(RoomError("Lỗi khi hoàn thành bài quiz: ${e.toString()}"));
    }
  }
}