import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/features/room/bloc/contest_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_event_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_state.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import 'quiz_result_screen.dart';

@RoutePage()
class RoomQuizScreen extends StatelessWidget {
  final int contestId;
  final int participantId;

  const RoomQuizScreen({
    Key? key,
    required this.contestId,
    required this.participantId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc()
        ..add(StartQuizEvent(contestId: contestId, participantId: participantId)),
        child: RoomQuizView(contestId: contestId),
    );
  }
}

class RoomQuizView extends StatelessWidget {
  final int contestId;
  const RoomQuizView({Key? key, required this.contestId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<RoomBloc, RoomState>(
            listener: (context, state) {
              if (state is QuizFinished) {
                _navigateToResult(context);
              } else if (state is ShowLeaderboard) {
                _showLeaderboardModal(context, state);
              }
            },
            builder: (context, state) {
              if (state is RoomLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is QuestionInProgress) {
                return _buildQuestionContent(context, state);
              }

              if (state is ShowLeaderboard) {
                return _buildLeaderboardContent(context, state);
              }

              if (state is WaitingForQuestion) {
                return _buildWaitingContent(context);
              }

              if (state is RoomError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                    'Lỗi: ${state.message}',
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Quay lại'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(
                child: Text(
                  'Đang khởi tạo quiz...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, QuestionInProgress state) {
    final questionEvent = state.questionEvent;
    final progress = state.countdown / 30.0; // Assuming 30 seconds per question

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Exit
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.countdown}s',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Progress bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              state.isSubmitted ? Colors.green : Colors.orange
            ),
          ),
        ),

        // Submitted status
        if (state.isSubmitted) ...[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Đã nộp bài! Chờ câu hỏi tiếp theo...',
                  style: TextStyle(
                    color: Colors.green.shade200,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Question
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
                questionEvent.question,
              style: const TextStyle(
                  fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Answer options
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
              children: List.generate(questionEvent.options.length, (index) {
                final option = questionEvent.options[index];
              final isSelected = state.selectedAnswer == option;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: state.isSubmitted ? null : () => _selectAnswer(context, option),
                child: Container(
                      width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                        color: state.isSubmitted 
                            ? (isSelected ? Colors.orange.withOpacity(0.7) : Colors.white12)
                            : (isSelected ? Colors.orange : Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                          color: state.isSubmitted 
                              ? (isSelected ? Colors.orange.withOpacity(0.7) : Colors.white38)
                              : (isSelected ? Colors.orange : Colors.white54),
                      width: 2,
                    ),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                              color: state.isSubmitted 
                                  ? (isSelected ? Colors.white : Colors.white60)
                                  : (isSelected ? Colors.black : Colors.white),
                            fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (state.isSubmitted && isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardContent(BuildContext context, ShowLeaderboard state) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Text(
                'Bảng xếp hạng',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.countdown}s',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.leaderboardEvent.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = state.leaderboardEvent.leaderboard[index];
              final isTopThree = index < 3;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isTopThree ? Colors.orange.withOpacity(0.3) : Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                  border: isTopThree ? Border.all(color: Colors.orange, width: 2) : null,
                ),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTopThree ? Colors.orange : Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isTopThree ? Colors.black : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name
                    Expanded(
                      child: Text(
                        entry.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Score
                    Text(
                      '${entry.score} điểm',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Contest đã bắt đầu!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đang chờ câu hỏi đầu tiên...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Hãy chuẩn bị sẵn sàng!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(BuildContext context, String answer) {
    context.read<RoomBloc>().add(AnswerSelectedEvent(answer));
  }

  void _navigateToResult(BuildContext context) {
    // Get data from BLoC
    final roomBloc = context.read<RoomBloc>();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          questions: [], // Will be populated from contest data
          answers: roomBloc.userAnswers, // User's answers
          score: roomBloc.totalScore, // Calculated score
          contestId: roomBloc.contestId,
          totalTime: const Duration(minutes: 5), // Placeholder - calculate from answerTimes
        ),  
      ),
    );
  }

  void _showLeaderboardModal(BuildContext context, ShowLeaderboard state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientMiddle,
                      AppColors.gradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Bảng xếp hạng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.countdown}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Leaderboard List
                    Expanded(
                      child: state.leaderboardEvent.leaderboard.isEmpty
                          ? const Center(
                              child: Text(
                                'Chưa có dữ liệu bảng xếp hạng',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: state.leaderboardEvent.leaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = state.leaderboardEvent.leaderboard[index];
                                final isTopThree = index < 3;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isTopThree 
                                        ? Colors.orange.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isTopThree 
                                        ? Border.all(color: Colors.orange, width: 2)
                                        : Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Rank
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isTopThree 
                                              ? Colors.orange 
                                              : Colors.white.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isTopThree 
                                                  ? Colors.white 
                                                  : Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Name
                                      Expanded(
                                        child: Text(
                                          entry.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      
                                      // Score
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${entry.score} điểm',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Câu hỏi tiếp theo sẽ xuất hiện sau ${state.countdown} giây',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    
    // Auto close dialog when countdown reaches 0 or state changes
    Future.delayed(Duration(seconds: state.countdown), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
}