import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_neko/features/room/api/contest_api.dart';
import 'package:logi_neko/features/room/bloc/room_event_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_state.dart';
import 'package:logi_neko/features/room/service/stomp_websocket_service.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';
import 'package:logi_neko/features/room/dto/contest.dart';
import 'package:logi_neko/features/room/dto/leaderboard_entry.dart';

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
  int _currentQuestionIndex = 0;
  Timer? _questionRevealTimer;
  
  // Scoring and timing
  int _totalScore = 0;
  Map<int, String> _userAnswers = {}; // questionIndex -> answer
  Map<int, int> _answerTimes = {}; // questionIndex -> time spent
  bool _isQuestionEnding = false; // Flag to prevent multiple endQuestion calls

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
    on<CorrectAnswerTimerTicked>(_onCorrectAnswerTimerTicked);
    on<ShowLeaderboardEvent>(_onShowLeaderboard);
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
      
      // Add fallback timer - if no contest.started event in 5 seconds, try to load questions anyway
      Timer(const Duration(seconds: 5), () {
        if (_contestQuestions.isEmpty) {
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
        
        // Use 45 seconds as default (from the STOMP event we saw)
        const timeLimit = 45; // Based on the STOMP event log showing timeLimit: 45
        
        print('📝 [RoomBloc] Using timeLimit: ${timeLimit}s from STOMP event');
        
        emit(QuestionInProgress(
          questionEvent: questionEvent,
          countdown: timeLimit,
          selectedAnswer: _selectedAnswer,
          initialTime: timeLimit,
          isSubmitted: false,
        ));
        _startQuestionTimer();
        break;
        
      case 'leaderboard.updated':
        print('🏆 [RoomBloc] Leaderboard updated event received');
        final leaderboardEvent = gameEvent as LeaderboardUpdatedEvent;
        
        // If we're currently showing leaderboard, update it with new data
        if (state is ShowLeaderboard) {
          print('🏆 [RoomBloc] Updating existing leaderboard with new data');
          emit(ShowLeaderboard(
            leaderboardEvent: leaderboardEvent,
            countdown: (state as ShowLeaderboard).countdown, // Keep current countdown
          ));
        } else {
          print('🏆 [RoomBloc] Leaderboard update received but not currently showing leaderboard');
        }
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
        
      case 'question.ended':
        print('⏰ [RoomBloc] Question ended! Showing correct answer...');
        _handleQuestionEnded(gameEvent, emit);
        break;
        
      case 'answer.submitted':
        print('📤 [RoomBloc] Answer submitted event received');
        // This event is just for confirmation, no action needed
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
    if (currentState is QuestionInProgress && !currentState.isSubmitted) {
      // Calculate time spent (initial time - remaining time)
      final timeSpent = currentState.initialTime - currentState.countdown;
      
      // Validate timeSpent
      final validTimeSpent = timeSpent >= 0 ? timeSpent : 0;
      
      print('🎯 [RoomBloc] Answer selected: "${event.answer}"');
      print('🎯 [RoomBloc] Time spent: ${validTimeSpent}s (initial: ${currentState.initialTime}s, remaining: ${currentState.countdown}s)');
      
      // Store answer and time
      _userAnswers[_currentQuestionIndex] = event.answer;
      _answerTimes[_currentQuestionIndex] = validTimeSpent;
      
      emit(QuestionInProgress(
        questionEvent: currentState.questionEvent,
        countdown: currentState.countdown,
        selectedAnswer: _selectedAnswer,
        initialTime: currentState.initialTime,
        isSubmitted: true, // Mark as submitted
      ));
      
      // Submit answer to server with time
      _submitAnswer(currentState.questionEvent.contestQuestionId, event.answer, validTimeSpent);
    }
  }

  void _onQuestionTimerTicked(
      QuestionTimerTicked event, Emitter<RoomState> emit) {
    final currentState = state;
    print('⏰ [RoomBloc] Timer ticked - current countdown: ${currentState is QuestionInProgress ? currentState.countdown : 'N/A'}');
    
    if (currentState is QuestionInProgress) {
      final newCountdown = currentState.countdown - 1;
      print('⏰ [RoomBloc] New countdown: $newCountdown, isSubmitted: ${currentState.isSubmitted}');
      
      if (newCountdown > 0) {
        emit(QuestionInProgress(
          questionEvent: currentState.questionEvent,
          countdown: newCountdown,
          selectedAnswer: currentState.selectedAnswer,
          initialTime: currentState.initialTime,
          isSubmitted: currentState.isSubmitted,
        ));
            } else {
              print('⏰ [RoomBloc] Time\'s up! Countdown reached 0');
              
              // Time's up, auto-submit if not already submitted
              if (!currentState.isSubmitted) {
                final timeSpent = currentState.initialTime;
                _userAnswers[_currentQuestionIndex] = ''; // No answer
                _answerTimes[_currentQuestionIndex] = timeSpent;
                
                print('⏰ [RoomBloc] Time\'s up! Auto-submitting empty answer with time: ${timeSpent}s');
                
                // Submit empty answer
                _submitAnswer(currentState.questionEvent.contestQuestionId, '', timeSpent);
              }
              
              // End the question to calculate scores and show correct answer
              if (!_isQuestionEnding) {
                print('⏰ [RoomBloc] Calling _endQuestionAndShowResults...');
                _endQuestionAndShowResults(currentState.questionEvent.contestQuestionId, emit);
              } else {
                print('⚠️ [RoomBloc] Question ending already in progress, skipping...');
              }
            }
    } else {
      print('⚠️ [RoomBloc] Timer ticked but current state is not QuestionInProgress: ${currentState.runtimeType}');
    }
  }

  Future<void> _endQuestionAndShowResults(int contestQuestionId, Emitter<RoomState> emit) async {
    if (_isQuestionEnding) {
      print('⚠️ [RoomBloc] Question ending already in progress, skipping...');
      return;
    }
    
    _isQuestionEnding = true;
    
    try {
      print('⏰ [RoomBloc] Ending question $contestQuestionId to calculate scores');
      
      // Call backend to end question and calculate scores
      await _apiService.endQuestion(contestQuestionId);
      
      // Wait a bit for scores to be calculated
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Don't move to next question here - wait for question.ended event
      // The question.ended event will trigger showing correct answer
      print('✅ [RoomBloc] Question ended API called successfully, waiting for question.ended event...');
      
    } catch (e) {
      print('❌ [RoomBloc] Error ending question: $e');
      // Continue anyway
      _timer?.cancel();
      _currentQuestionIndex++;
      _isQuestionEnding = false; // Reset flag
      
      if (_currentQuestionIndex < _contestQuestions.length) {
        if (!emit.isDone) {
          _showLeaderboardAndNextQuestion(emit);
        }
      } else {
        if (!emit.isDone) {
          emit(QuizFinished());
        }
      }
    }
  }

  void _showLeaderboardAndNextQuestion(Emitter<RoomState> emit) async {
    try {
      print('🏆 [RoomBloc] Starting _showLeaderboardAndNextQuestion...');
      
      // Get current leaderboard data
      print('🏆 [RoomBloc] Refreshing leaderboard for contest $_contestId...');
      await _apiService.refreshLeaderboard(_contestId);
      print('🏆 [RoomBloc] Leaderboard refresh completed');
      
      await Future.delayed(const Duration(milliseconds: 500));
      print('🏆 [RoomBloc] Getting leaderboard data...');
      final leaderboardData = await _apiService.getLeaderboard(_contestId);
      print('🏆 [RoomBloc] Got leaderboard data: ${leaderboardData.length} entries');
      
      final leaderboardEntries = leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
      print('🏆 [RoomBloc] Parsed leaderboard entries: ${leaderboardEntries.length}');
      
      final leaderboardEvent = LeaderboardUpdatedEvent(
        eventType: 'leaderboard.updated',
        timestamp: DateTime.now(),
        leaderboard: leaderboardEntries,
      );
      
      print('🏆 [RoomBloc] Created leaderboard event, emitting ShowLeaderboard...');
      
      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        print('🏆 [RoomBloc] Emitting ShowLeaderboard state...');
        emit(ShowLeaderboard(
          leaderboardEvent: leaderboardEvent,
          countdown: 5, // 5 seconds to show leaderboard
        ));
        
        print('🏆 [RoomBloc] Starting leaderboard timer...');
        _startLeaderboardTimer();
        print('🏆 [RoomBloc] Leaderboard timer started successfully');
      } else {
        print('⚠️ [RoomBloc] Emit is done, cannot emit ShowLeaderboard');
      }
    } catch (e) {
      print('❌ [RoomBloc] Failed to load leaderboard: $e');
      // Fallback to empty leaderboard
      final leaderboardEvent = LeaderboardUpdatedEvent(
        eventType: 'leaderboard.updated',
        timestamp: DateTime.now(),
        leaderboard: [],
      );
      
      // Check if emit is still valid before emitting
      if (!emit.isDone) {
        emit(ShowLeaderboard(
          leaderboardEvent: leaderboardEvent,
          countdown: 3,
        ));
        
        _startLeaderboardTimer();
      }
    }
  }

  void _onLeaderboardTimerTicked(
      LeaderboardTimerTicked event, Emitter<RoomState> emit) {
    final currentState = state;
    print('⏰ [RoomBloc] Leaderboard timer ticked - current countdown: ${currentState is ShowLeaderboard ? currentState.countdown : 'N/A'}');
    
    if (currentState is ShowLeaderboard) {
      final newCountdown = currentState.countdown - 1;
      print('⏰ [RoomBloc] Leaderboard new countdown: $newCountdown');
      
      if (newCountdown > 0) {
        emit(ShowLeaderboard(
          leaderboardEvent: currentState.leaderboardEvent,
          countdown: newCountdown,
        ));
      } else {
        print('⏰ [RoomBloc] Leaderboard time\'s up! Checking if more questions...');
        // Leaderboard time's up, check if more questions
        _timer?.cancel();
        
        if (_currentQuestionIndex < _contestQuestions.length) {
          print('⏰ [RoomBloc] Moving to next question...');
          _revealNextQuestion(emit);
        } else {
          print('⏰ [RoomBloc] All questions done, finishing quiz...');
          if (!emit.isDone) {
            emit(QuizFinished());
          }
        }
      }
    } else {
      print('⚠️ [RoomBloc] Leaderboard timer ticked but current state is not ShowLeaderboard: ${currentState.runtimeType}');
    }
  }

  void _handleQuestionEnded(dynamic gameEvent, Emitter<RoomState> emit) {
    try {
      // Get correct answer from event
      String correctAnswer = gameEvent.correctAnswer ?? '';
      
      // Get user's answer for current question
      String userAnswer = _userAnswers[_currentQuestionIndex] ?? '';
      
      // Check if user's answer is correct
      bool isCorrect = correctAnswer == userAnswer;
      
      print('🎯 [RoomBloc] Correct answer: "$correctAnswer", User answer: "$userAnswer", Is correct: $isCorrect');
      
      // Show correct answer for 3 seconds
      emit(ShowCorrectAnswer(
        correctAnswer: correctAnswer,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        countdown: 3,
      ));
      
      print('⏰ [RoomBloc] Emitted ShowCorrectAnswer state, starting timer...');
      
      // Start timer for correct answer display
      _startCorrectAnswerTimer();
      
    } catch (e) {
      print('❌ [RoomBloc] Error handling question ended: $e');
      // Fallback to leaderboard
      _showLeaderboardAndNextQuestion(emit);
    }
  }

  void _onShowLeaderboard(ShowLeaderboardEvent event, Emitter<RoomState> emit) {
    print('🏆 [RoomBloc] ShowLeaderboardEvent received, calling _showLeaderboardAndNextQuestion...');
    _showLeaderboardAndNextQuestionSync(emit);
  }

  void _showLeaderboardAndNextQuestionSync(Emitter<RoomState> emit) {
    print('🏆 [RoomBloc] Starting _showLeaderboardAndNextQuestionSync...');
    
    // Create empty leaderboard event for now
    final leaderboardEvent = LeaderboardUpdatedEvent(
      eventType: 'leaderboard.updated',
      timestamp: DateTime.now(),
      leaderboard: [],
    );
    
    print('🏆 [RoomBloc] Emitting ShowLeaderboard state...');
    emit(ShowLeaderboard(
      leaderboardEvent: leaderboardEvent,
      countdown: 5, // 5 seconds to show leaderboard
    ));
    
    print('🏆 [RoomBloc] Starting leaderboard timer...');
    _startLeaderboardTimer();
    print('🏆 [RoomBloc] Leaderboard timer started successfully');
    
    // Load leaderboard data in background
    _loadLeaderboardDataInBackground();
  }

  void _loadLeaderboardDataInBackground() async {
    try {
      print('🏆 [RoomBloc] Loading leaderboard data in background...');
      
      // Get current leaderboard data
      await _apiService.refreshLeaderboard(_contestId);
      print('🏆 [RoomBloc] Leaderboard refresh completed');
      
      await Future.delayed(const Duration(milliseconds: 500));
      print('🏆 [RoomBloc] Getting leaderboard data...');
      final leaderboardData = await _apiService.getLeaderboard(_contestId);
      print('🏆 [RoomBloc] Got leaderboard data: ${leaderboardData.length} entries');
      
      final leaderboardEntries = leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
      print('🏆 [RoomBloc] Parsed leaderboard entries: ${leaderboardEntries.length}');
      
      // Update the leaderboard via event
      final leaderboardEvent = LeaderboardUpdatedEvent(
        eventType: 'leaderboard.updated',
        timestamp: DateTime.now(),
        leaderboard: leaderboardEntries,
      );
      
      print('🏆 [RoomBloc] Broadcasting leaderboard update...');
      add(GameEventReceived(leaderboardEvent));
      
    } catch (e) {
      print('❌ [RoomBloc] Failed to load leaderboard in background: $e');
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
    print('⏰ [RoomBloc] Starting question timer...');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('⏰ [RoomBloc] Timer tick - adding QuestionTimerTicked event');
      add(QuestionTimerTicked());
    });
  }

  void _startLeaderboardTimer() {
    _timer?.cancel();
    print('⏰ [RoomBloc] Starting leaderboard timer...');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('⏰ [RoomBloc] Leaderboard timer tick - adding LeaderboardTimerTicked event');
      add(LeaderboardTimerTicked());
    });
  }

  void _startCorrectAnswerTimer() {
    _timer?.cancel();
    print('⏰ [RoomBloc] Starting correct answer timer...');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('⏰ [RoomBloc] Correct answer timer tick - adding CorrectAnswerTimerTicked event');
      add(CorrectAnswerTimerTicked());
    });
  }

  void _onCorrectAnswerTimerTicked(
      CorrectAnswerTimerTicked event, Emitter<RoomState> emit) {
    final currentState = state;
    print('⏰ [RoomBloc] Correct answer timer ticked - current countdown: ${currentState is ShowCorrectAnswer ? currentState.countdown : 'N/A'}');
    
    if (currentState is ShowCorrectAnswer) {
      final newCountdown = currentState.countdown - 1;
      print('⏰ [RoomBloc] Correct answer new countdown: $newCountdown');
      
      if (newCountdown > 0) {
        emit(ShowCorrectAnswer(
          correctAnswer: currentState.correctAnswer,
          userAnswer: currentState.userAnswer,
          isCorrect: currentState.isCorrect,
          countdown: newCountdown,
        ));
      } else {
        print('⏰ [RoomBloc] Correct answer time\'s up! Moving to leaderboard...');
        // Correct answer time's up, show leaderboard
        _timer?.cancel();
        _currentQuestionIndex++;
        _isQuestionEnding = false; // Reset flag for next question
        
        // Always show leaderboard first, then decide what to do next
        print('⏰ [RoomBloc] Moving to leaderboard...');
        add(ShowLeaderboardEvent());
      }
    } else {
      print('⚠️ [RoomBloc] Correct answer timer ticked but current state is not ShowCorrectAnswer: ${currentState.runtimeType}');
    }
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
      if (!emit.isDone) {
        emit(QuizFinished());
      }
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
      final questionTime = question.timeLimit ?? 30; // Default to 30 if null
      
      // Reset flag for new question
      _isQuestionEnding = false;
      
      if (!emit.isDone) {
        emit(QuestionInProgress(
          questionEvent: questionEvent,
          countdown: questionTime,
          selectedAnswer: _selectedAnswer,
          initialTime: questionTime,
          isSubmitted: false,
        ));
        
        _startQuestionTimer();
      }
      
    } catch (e) {
      print('❌ [RoomBloc] Failed to reveal question: $e');
      if (!emit.isDone) {
        emit(RoomError('Failed to reveal question: $e'));
      }
    }
  }

  Future<void> _submitAnswer(int contestQuestionId, String answer, int timeSpent) async {
    try {
      print('📤 [RoomBloc] Submitting answer: "$answer" with time: ${timeSpent}s');
      print('📤 [RoomBloc] ContestId: $_contestId, ParticipantId: $_participantId, ContestQuestionId: $contestQuestionId');
      
      await _apiService.submitAnswer(
        contestId: _contestId,
        participantId: _participantId,
        contestQuestionId: contestQuestionId,
        answer: answer,
        timeSpent: timeSpent,
      );
      
      print('✅ [RoomBloc] Answer submitted successfully - Score will be calculated when question ends');
      
      // Don't refresh leaderboard yet - wait for question to end
      
    } catch (e) {
      print('❌ [RoomBloc] Failed to submit answer: $e');
      // You might want to emit an error state here or show a snackbar
      // For now, we'll just log the error and continue
    }
  }



  // Getters for accessing private data
  int get contestId => _contestId;
  int get participantId => _participantId;
  int get totalScore => _totalScore;
  Map<int, String> get userAnswers => Map.from(_userAnswers);
  Map<int, int> get answerTimes => Map.from(_answerTimes);
  List<ContestQuestionResponse> get contestQuestions => List.from(_contestQuestions);

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _stompService.dispose();
    _timer?.cancel();
    _questionRevealTimer?.cancel();
    return super.close();
  }
}