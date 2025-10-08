import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/features/room/bloc/contest_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_event_bloc.dart';
import 'package:logi_neko/features/room/bloc/room_state.dart';
import 'package:logi_neko/shared/color/app_color.dart';

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

              if (state is ShowCorrectAnswer) {
                return _buildQuestionWithCorrectAnswer(context, state);
              }

              if (state is RoomError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Quay lại'),
                        ),
                      ],
                    ),
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeQuestion(context, state, questionEvent);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tính toán chiều cao động
        final headerHeight = 60.0;
        final progressHeight = 20.0;
        final submittedBadgeHeight = state.isSubmitted ? 40.0 : 0.0;
        final questionHeight = constraints.maxHeight * 0.25; // 25% cho câu hỏi
        final optionsHeight = constraints.maxHeight - headerHeight - progressHeight - submittedBadgeHeight - questionHeight - 16;

        return Column(
          children: [
            // Header - Fixed
            SizedBox(
              height: headerHeight,
              child: _buildQuestionHeader(context, state),
            ),

            // Progress bar - Fixed
            SizedBox(
              height: progressHeight,
              child: _buildSmoothProgressBar(state),
            ),

            // Submitted badge
            if (state.isSubmitted)
              SizedBox(
                height: submittedBadgeHeight,
                child: _buildSubmittedBadge(),
              ),

            // Question - Scrollable với chiều cao cố định
            SizedBox(
              height: questionHeight,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  questionEvent.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Answer options - Chiều cao còn lại
            SizedBox(
              height: optionsHeight,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: questionEvent.options.length,
                itemBuilder: (context, index) => _buildAnswerOption(
                  context,
                  state,
                  questionEvent.options[index],
                  index,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeQuestion(
      BuildContext context,
      QuestionInProgress state,
      dynamic questionEvent,
      ) {
    return Row(
      children: [
        // Left: Question
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildQuestionHeader(context, state),
              _buildSmoothProgressBar(state),
              if (state.isSubmitted) _buildSubmittedBadge(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      questionEvent.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right: Options
        Expanded(
          flex: 7,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: questionEvent.options.length,
            itemBuilder: (context, index) => _buildAnswerOption(
              context,
              state,
              questionEvent.options[index],
              index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(BuildContext context, QuestionInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: value <= 5
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (value <= 5 ? Colors.red : Colors.orange).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${value}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSmoothProgressBar(QuestionInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TweenAnimationBuilder<double>(
          key: ValueKey('${state.countdown}_${state.isSubmitted}'),
          tween: Tween<double>(
            begin: state.countdown / 30.0,
            end: state.countdown / 30.0,
          ),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.linear,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.2),
              minHeight: 6,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.isSubmitted ? Colors.green : Colors.orange,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmittedBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Đã nộp bài! Chờ hiển thị đáp án...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
      BuildContext context,
      QuestionInProgress state,
      String option,
      int index,
      ) {
    final isSelected = state.selectedAnswer == option;
    final labels = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state.isSubmitted ? null : () => _selectAnswer(context, option),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected && !state.isSubmitted
                  ? LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              )
                  : null,
              color: isSelected && !state.isSubmitted
                  ? null
                  : state.isSubmitted
                  ? (isSelected ? Colors.orange.withOpacity(0.5) : Colors.white.withOpacity(0.15))
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.orange.shade300
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected && !state.isSubmitted
                  ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                // Label A, B, C, D
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.orange.shade700 : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected && !state.isSubmitted
                          ? Colors.white
                          : state.isSubmitted
                          ? (isSelected ? Colors.white : Colors.white70)
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (state.isSubmitted && isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context, ShowLeaderboard state) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Column(
      children: [
        _buildLeaderboardHeader(context, state),
        Expanded(
          child: state.leaderboardEvent.leaderboard.isEmpty
              ? const Center(
            child: Text(
              'Chưa có dữ liệu',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
              : GridView.builder(
            padding: EdgeInsets.all(isLandscape ? 12 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 2 : 1,
              childAspectRatio: isLandscape ? 4.5 : 7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
            ),
            itemCount: state.leaderboardEvent.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = state.leaderboardEvent.leaderboard[index];
              final isTopThree = index < 3;
              return _buildLeaderboardItem(entry, index + 1, isTopThree);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardHeader(BuildContext context, ShowLeaderboard state) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bảng xếp hạng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  '${value}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(dynamic entry, int rank, bool isTopThree) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: isTopThree
            ? LinearGradient(
          colors: [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.2)],
        )
            : null,
        color: isTopThree ? null : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTopThree ? Colors.orange : Colors.white.withOpacity(0.3),
          width: isTopThree ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              )
                  : null,
              color: isTopThree ? null : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
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
  }

  Widget _buildQuestionWithCorrectAnswer(BuildContext context, ShowCorrectAnswer state) {
    return Column(
      children: [
        // Header with timer
        _buildCorrectAnswerHeader(context, state),
        
        // Result message
        _buildResultMessage(state),
        
        // Question content with highlighted answers
        Expanded(
          child: _buildQuestionWithHighlights(context, state),
        ),
        
        // Countdown message
        _buildCountdownMessage(state),
      ],
    );
  }

  Widget _buildCorrectAnswerHeader(BuildContext context, ShowCorrectAnswer state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${value}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultMessage(ShowCorrectAnswer state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isCorrect 
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (state.isCorrect ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isCorrect ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            state.isCorrect ? 'Chính xác! 🎉' : 'Sai rồi! 😔',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWithHighlights(BuildContext context, ShowCorrectAnswer state) {
    // Get the question from the previous state or create a mock one
    // For now, we'll create a simple display
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Your answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đáp án của bạn:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.userAnswer.isEmpty ? 'Không trả lời' : state.userAnswer,
                  style: TextStyle(
                    color: state.userAnswer.isEmpty ? Colors.grey.shade300 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Correct answer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đáp án đúng:',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.correctAnswer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownMessage(ShowCorrectAnswer state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Chuyển sang câu tiếp theo sau ${state.countdown} giây...',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildWaitingContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Contest đã bắt đầu!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang chờ câu hỏi đầu tiên...',
              style: TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(BuildContext context, String answer) {
    context.read<RoomBloc>().add(AnswerSelectedEvent(answer));
  }

  void _navigateToResult(BuildContext context) {
    // Navigate back to contest list or home screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showLeaderboardModal(BuildContext context, ShowLeaderboard state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
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
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.orange,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bảng xếp hạng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        key: ValueKey(state.countdown),
                        tween: IntTween(begin: state.countdown, end: state.countdown),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade400, Colors.orange.shade600],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${value}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: state.leaderboardEvent.leaderboard.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Chưa có dữ liệu bảng xếp hạng',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.leaderboardEvent.leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = state.leaderboardEvent.leaderboard[index];
                      final isTopThree = index < 3;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isTopThree
                              ? LinearGradient(
                            colors: [
                              Colors.orange.withOpacity(0.3),
                              Colors.orange.withOpacity(0.2)
                            ],
                          )
                              : null,
                          color: isTopThree ? null : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isTopThree
                                ? Colors.orange
                                : Colors.white.withOpacity(0.2),
                            width: isTopThree ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: isTopThree
                                    ? LinearGradient(
                                  colors: [
                                    Colors.orange.shade400,
                                    Colors.orange.shade600
                                  ],
                                )
                                    : null,
                                color: isTopThree ? null : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                entry.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '${entry.score} điểm',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 13,
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Câu hỏi tiếp theo sẽ xuất hiện sau ${state.countdown} giây',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
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

    Future.delayed(Duration(seconds: state.countdown), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
}