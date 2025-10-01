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
      child: const RoomQuizView(),
    );
  }
}

class RoomQuizView extends StatelessWidget {
  const RoomQuizView({Key? key}) : super(key: key);

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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),

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
                    onTap: () => _selectAnswer(context, option),
                child: Container(
                      width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                          color: isSelected ? Colors.orange : Colors.white54,
                      width: 2,
                    ),
                  ),
                    child: Text(
                      option,
                      style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const QuizResultScreen(
          questions: [],
          answers: {},
          score: 0,
        ),
      ),
    );
  }
}