import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/room/api/contest_api.dart';
import 'package:logi_neko/features/room/bloc/room_event_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_state.dart';
import 'package:logi_neko/features/room/service/stomp_websocket_service.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';
import 'package:logi_neko/features/room/dto/contest.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final ContestService _apiService;
  final StompWebSocketService _stompService;
  StreamSubscription? _webSocketSubscription;
  Timer? _timer;

  late int _contestId;
  late int _participantId;
  String? _selectedAnswer;
  
  // Question management
  List<ContestQuestionResponse> _contestQuestions = [];
  List<QuestionResponse> _questions = [];
  int _currentQuestionIndex = 0;
  Timer? _questionRevealTimer;

  RoomBloc({
    ContestService? apiService,
    StompWebSocketService? stompService,
  })  : _apiService = apiService ?? ContestService(),
        _stompService = stompService ?? StompWebSocketService(),
        super(RoomInitial()) {
    on<StartQuizEvent>(_onStartQuiz);
    on<GameEventReceived>(_onGameEventReceived);
    on<AnswerSelectedEvent>(_onAnswerSelected);
    on<QuestionTimerTicked>(_onQuestionTimerTicked);
    on<LeaderboardTimerTicked>(_onLeaderboardTimerTicked);
    on<DisconnectEvent>(_onDisconnect);
    on<LoadQuestionsFallback>(_onLoadQuestionsFallback);
  }

  Future<void> _onStartQuiz(
      StartQuizEvent event, Emitter<RoomState> emit) async {
    try {
      emit(RoomLoading());
      
      _contestId = event.contestId;
      _participantId = event.participantId;
      
      // Connect to STOMP WebSocket
      _stompService.connect(_contestId);
      
      // Listen to STOMP events
      _webSocketSubscription = _stompService.events.listen(
        (gameEvent) {
          add(GameEventReceived(gameEvent));
        },
        onError: (error) {
          emit(RoomError('STOMP WebSocket connection error: $error'));
        },
      );
      
      emit(WaitingForQuestion());
      
      // Add fallback timer - if no contest.started event in 10 seconds, try to load questions anyway
      Timer(const Duration(seconds: 10), () {
        if (_questions.isEmpty) {
          print('⏰ [RoomBloc] No contest.started event received, trying to load questions anyway...');
          add(LoadQuestionsFallback());
        }
      });
    } catch (e) {
      emit(RoomError('Failed to start quiz: $e'));
    }
  }

  void _onGameEventReceived(
      GameEventReceived event, Emitter<RoomState> emit) {
    final gameEvent = event.gameEvent;
    print('🎯 [RoomBloc] Processing event: ${gameEvent.eventType}');
    
    switch (gameEvent.eventType) {
      case 'question.revealed':
        print('📝 [RoomBloc] Question revealed, starting timer');
        final questionEvent = gameEvent as QuestionRevealedEvent;
        _selectedAnswer = null;
        emit(QuestionInProgress(
          questionEvent: questionEvent,
          countdown: 30, // 30 seconds per question
          selectedAnswer: _selectedAnswer,
        ));
        _startQuestionTimer();
        break;
        
      case 'leaderboard.updated':
        print('🏆 [RoomBloc] Leaderboard updated, showing for 5 seconds');
        final leaderboardEvent = gameEvent as LeaderboardUpdatedEvent;
        emit(ShowLeaderboard(
          leaderboardEvent: leaderboardEvent,
          countdown: 5, // 5 seconds to show leaderboard
        ));
        _startLeaderboardTimer();
        break;
        
      case 'contest.started':
        print('🚀 [RoomBloc] Contest started! Loading contest questions...');
        // Contest has started, load all questions and start revealing them
        _loadAndRevealQuestions(emit);
        break;
        
      case 'contest.ended':
        print('🏁 [RoomBloc] Contest ended!');
        emit(QuizFinished());
        break;
        
      default:
        print('❓ [RoomBloc] Unknown event type: ${gameEvent.eventType}');
        // Handle other event types if needed
        break;
    }
  }

  void _onAnswerSelected(
      AnswerSelectedEvent event, Emitter<RoomState> emit) {
    _selectedAnswer = event.answer;
    
    final currentState = state;
    if (currentState is QuestionInProgress) {
      emit(QuestionInProgress(
        questionEvent: currentState.questionEvent,
        countdown: currentState.countdown,
        selectedAnswer: _selectedAnswer,
      ));
      
      // Submit answer to server
      _submitAnswer(currentState.questionEvent.contestQuestionId, event.answer);
    }
  }

  void _onQuestionTimerTicked(
      QuestionTimerTicked event, Emitter<RoomState> emit) {
    final currentState = state;
    if (currentState is QuestionInProgress) {
      final newCountdown = currentState.countdown - 1;
      if (newCountdown > 0) {
        emit(QuestionInProgress(
          questionEvent: currentState.questionEvent,
          countdown: newCountdown,
          selectedAnswer: currentState.selectedAnswer,
        ));
      } else {
        // Time's up, move to next question
        _timer?.cancel();
        _currentQuestionIndex++;
        
        if (_currentQuestionIndex < _contestQuestions.length) {
          // Show leaderboard for 3 seconds before next question
          _showLeaderboardAndNextQuestion(emit);
        } else {
          // All questions done
          emit(QuizFinished());
        }
      }
    }
  }

  void _showLeaderboardAndNextQuestion(Emitter<RoomState> emit) {
    // Create a simple leaderboard event (you can enhance this later)
    final leaderboardEvent = LeaderboardUpdatedEvent(
      eventType: 'leaderboard.updated',
      timestamp: DateTime.now(),
      leaderboard: [], // Empty for now, can be populated later
    );
    
    emit(ShowLeaderboard(
      leaderboardEvent: leaderboardEvent,
      countdown: 3, // 3 seconds to show leaderboard
    ));
    
    _startLeaderboardTimer();
  }

  void _onLeaderboardTimerTicked(
      LeaderboardTimerTicked event, Emitter<RoomState> emit) {
    final currentState = state;
    if (currentState is ShowLeaderboard) {
      final newCountdown = currentState.countdown - 1;
      if (newCountdown > 0) {
        emit(ShowLeaderboard(
          leaderboardEvent: currentState.leaderboardEvent,
          countdown: newCountdown,
        ));
      } else {
        // Leaderboard time's up, reveal next question
        _timer?.cancel();
        _revealNextQuestion(emit);
      }
    }
  }

  void _onDisconnect(DisconnectEvent event, Emitter<RoomState> emit) {
    _webSocketSubscription?.cancel();
    _stompService.disconnect();
    _timer?.cancel();
    emit(RoomInitial());
  }

  Future<void> _onLoadQuestionsFallback(LoadQuestionsFallback event, Emitter<RoomState> emit) async {
    print('🔄 [RoomBloc] Loading questions fallback triggered');
    await _loadAndRevealQuestions(emit);
  }

  void _startQuestionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(QuestionTimerTicked());
    });
  }

  void _startLeaderboardTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(LeaderboardTimerTicked());
    });
  }

  Future<void> _loadAndRevealQuestions(Emitter<RoomState> emit) async {
    try {
      print('📚 [RoomBloc] Loading contest questions for contest $_contestId');
      
      // Load contest questions to get the list
      _contestQuestions = await _apiService.getContestQuestions(_contestId);
      print('📚 [RoomBloc] Loaded ${_contestQuestions.length} contest questions');
      
      if (_contestQuestions.isEmpty) {
        throw Exception('No contest questions found');
      }
      
      // Reset question index
      _currentQuestionIndex = 0;
      
      // Start revealing questions one by one using API
      _startQuestionRevealSequence(emit);
      
    } catch (e) {
      print('❌ [RoomBloc] Failed to load questions: $e');
      emit(RoomError('Failed to load questions: $e'));
    }
  }

  void _startQuestionRevealSequence(Emitter<RoomState> emit) {
    if (_contestQuestions.isEmpty) {
      print('❌ [RoomBloc] No contest questions to reveal');
      emit(RoomError('No contest questions found'));
      return;
    }
    
    print('🎯 [RoomBloc] Starting question reveal sequence with ${_contestQuestions.length} questions');
    emit(WaitingForQuestion());
    
    // Start revealing first question after 2 seconds
    _questionRevealTimer = Timer(const Duration(seconds: 2), () {
      _revealNextQuestion(emit);
    });
  }

  Future<void> _revealNextQuestion(Emitter<RoomState> emit) async {
    if (_currentQuestionIndex >= _contestQuestions.length) {
      print('🏁 [RoomBloc] All questions revealed, ending contest');
      emit(QuizFinished());
      return;
    }
    
    final contestQuestion = _contestQuestions[_currentQuestionIndex];
    
    try {
      print('📝 [RoomBloc] Revealing question ${_currentQuestionIndex + 1}/${_contestQuestions.length}');
      print('📝 [RoomBloc] Contest question ID: ${contestQuestion.id}, Question ID: ${contestQuestion.questionId}');
      
      // Call revealQuestion API
      await _apiService.revealQuestion(contestQuestion.id);
      print('📝 [RoomBloc] Question revealed via API');
      
      // Get question details
      final question = await _apiService.getQuestionById(contestQuestion.questionId);
      print('📝 [RoomBloc] Loaded question details: ${question.questionText}');
      
      // Create QuestionRevealedEvent manually
      final questionEvent = QuestionRevealedEvent(
        eventType: 'question.revealed',
        timestamp: DateTime.now(),
        contestQuestionId: contestQuestion.id,
        question: question.questionText,
        options: question.options.map((opt) => opt.optionText).toList(),
      );
      
      _selectedAnswer = null;
      emit(QuestionInProgress(
        questionEvent: questionEvent,
        countdown: question.timeLimit, // Use question's time limit
        selectedAnswer: _selectedAnswer,
      ));
      
      _startQuestionTimer();
      
    } catch (e) {
      print('❌ [RoomBloc] Failed to reveal question: $e');
      emit(RoomError('Failed to reveal question: $e'));
    }
  }

  Future<void> _submitAnswer(int contestQuestionId, String answer) async {
    try {
      await _apiService.submitAnswer(
        contestId: _contestId,
        participantId: _participantId,
        contestQuestionId: contestQuestionId,
        answer: answer,
      );
    } catch (e) {
      // Handle error silently or emit error state
      print('Failed to submit answer: $e');
    }
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _stompService.dispose();
    _timer?.cancel();
    _questionRevealTimer?.cancel();
    return super.close();
  }
}