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
                return _buildLoadingState();
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
                return _buildErrorState(context, state);
              }

              return _buildInitializingState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, RoomError state) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đã có lỗi xảy ra',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Quay lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitializingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang khởi tạo quiz...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, QuestionInProgress state) {
    final questionEvent = state.questionEvent;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeQuestion(context, state, questionEvent);
    }

    return Column(
      children: [
        _buildQuestionHeader(context, state),
        _buildProgressBar(state),
        if (state.isSubmitted) _buildSubmittedBadge(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildQuestionCard(questionEvent.question),
                const SizedBox(height: 8),
                _buildAnswerOptions(context, state, questionEvent.options),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeQuestion(
      BuildContext context,
      QuestionInProgress state,
      dynamic questionEvent,
      ) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildQuestionHeader(context, state),
              _buildProgressBar(state),
              if (state.isSubmitted) _buildSubmittedBadge(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildQuestionCard(questionEvent.question),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 7,
          child: _buildAnswerOptions(context, state, questionEvent.options),
        ),
      ],
    );
  }

  Widget _buildQuestionHeader(BuildContext context, QuestionInProgress state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              final isUrgent = value <= 5;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUrgent
                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                        : [AppColors.primaryBlue, const Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: (isUrgent ? Colors.red : AppColors.primaryBlue).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${value}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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

  Widget _buildProgressBar(QuestionInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.isSubmitted
                    ? AppColors.success
                    : (state.countdown <= 5 ? AppColors.error : AppColors.primaryBlue),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmittedBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, const Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text(
            'Đã nộp bài! Chờ công bố đáp án...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        question,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.5,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnswerOptions(BuildContext context, QuestionInProgress state, List<String> options) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: options.length,
      itemBuilder: (context, index) => _buildAnswerOption(
        context,
        state,
        options[index],
        index,
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
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isSelected && !state.isSubmitted
                  ? LinearGradient(
                colors: [
                  AppColors.primaryPurple,
                  AppColors.primaryPink,
                ],
              )
                  : null,
              color: isSelected && !state.isSubmitted
                  ? null
                  : state.isSubmitted
                  ? (isSelected ? AppColors.primaryPurple.withOpacity(0.3) : Colors.white.withOpacity(0.1))
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected && !state.isSubmitted
                  ? [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(isSelected ? 0.8 : 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryPurple : Colors.white,
                        fontSize: 18,
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (state.isSubmitted && isSelected)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryPurple,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWithCorrectAnswer(BuildContext context, ShowCorrectAnswer state) {
    // Lấy thông tin câu hỏi từ state nếu có, hoặc hiển thị placeholder
    final question = state.question ?? 'Câu hỏi';
    final options = state.options ?? [];

    return Column(
      children: [
        _buildCorrectAnswerHeader(context, state),
        _buildResultBanner(state),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildQuestionCard(question),
                const SizedBox(height: 16),
                options.isNotEmpty
                    ? _buildAnswerOptionsWithResult(context, state, options)
                    : _buildSimpleAnswerDisplay(state),
                _buildCountdownMessage(state),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSimpleAnswerDisplay(ShowCorrectAnswer state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (state.userAnswer.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: state.isCorrect
                      ? [AppColors.success.withOpacity(0.3), AppColors.success.withOpacity(0.2)]
                      : [AppColors.error.withOpacity(0.3), AppColors.error.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.isCorrect ? AppColors.success : AppColors.error,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Câu trả lời của bạn:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.userAnswer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success.withOpacity(0.3), AppColors.success.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đáp án đúng:',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

  Widget _buildCorrectAnswerHeader(BuildContext context, ShowCorrectAnswer state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${value}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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

  Widget _buildResultBanner(ShowCorrectAnswer state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isCorrect
              ? [AppColors.success, const Color(0xFF059669)]
              : [AppColors.error, const Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (state.isCorrect ? AppColors.success : AppColors.error).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isCorrect ? Icons.celebration_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            state.isCorrect ? 'Chính xác! Tuyệt vời! 🎉' : 'Chưa chính xác! 💪',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptionsWithResult(
      BuildContext context,
      ShowCorrectAnswer state,
      List<String> options,
      ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: options.length,
      itemBuilder: (context, index) => _buildAnswerOptionWithResult(
        options[index],
        index,
        state.userAnswer,
        state.correctAnswer,
      ),
    );
  }

  Widget _buildAnswerOptionWithResult(
      String option,
      int index,
      String userAnswer,
      String correctAnswer,
      ) {
    final labels = ['A', 'B', 'C', 'D'];
    final isUserAnswer = userAnswer == option;
    final isCorrectAnswer = correctAnswer == option;
    final isWrongAnswer = isUserAnswer && !isCorrectAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isCorrectAnswer
              ? LinearGradient(
            colors: [AppColors.success.withOpacity(0.3), AppColors.success.withOpacity(0.2)],
          )
              : isWrongAnswer
              ? LinearGradient(
            colors: [AppColors.error.withOpacity(0.3), AppColors.error.withOpacity(0.2)],
          )
              : null,
          color: isCorrectAnswer || isWrongAnswer ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCorrectAnswer
                ? AppColors.success
                : isWrongAnswer
                ? AppColors.error
                : Colors.white.withOpacity(0.3),
            width: isCorrectAnswer || isWrongAnswer ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCorrectAnswer
                    ? AppColors.success
                    : isWrongAnswer
                    ? AppColors.error
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isCorrectAnswer || isWrongAnswer
                    ? Icon(
                  isCorrectAnswer ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                )
                    : Text(
                  labels[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isCorrectAnswer || isWrongAnswer ? FontWeight.w600 : FontWeight.w500,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCorrectAnswer)
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đúng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownMessage(ShowCorrectAnswer state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Câu tiếp theo sau ${state.countdown}s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
              ? _buildEmptyLeaderboard()
              : GridView.builder(
            padding: EdgeInsets.all(isLandscape ? 12 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 2 : 1,
              childAspectRatio: isLandscape ? 4.5 : 7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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

  Widget _buildEmptyLeaderboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có dữ liệu',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardHeader(BuildContext context, ShowLeaderboard state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning.withOpacity(0.3), AppColors.warning.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bảng xếp hạng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TweenAnimationBuilder<int>(
            key: ValueKey(state.countdown),
            tween: IntTween(begin: state.countdown, end: state.countdown),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
    );
  }

  Widget _buildLeaderboardItem(dynamic entry, int rank, bool isTopThree) {
    final medalColors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      [const Color(0xFFC0C0C0), const Color(0xFFA8A8A8)], // Silver
      [const Color(0xFFCD7F32), const Color(0xFFB8733B)], // Bronze
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isTopThree
            ? LinearGradient(
          colors: [
            medalColors[rank - 1][0].withOpacity(0.2),
            medalColors[rank - 1][1].withOpacity(0.1),
          ],
        )
            : null,
        color: isTopThree ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTopThree ? medalColors[rank - 1][0] : Colors.white.withOpacity(0.2),
          width: isTopThree ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isTopThree
                  ? LinearGradient(
                colors: medalColors[rank - 1],
              )
                  : null,
              color: isTopThree ? null : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTopThree
                  ? const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 20,
              )
                  : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning.withOpacity(0.3), AppColors.warning.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Contest đã bắt đầu! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Text(
                'Đang chờ câu hỏi đầu tiên...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showLeaderboardModal(BuildContext context, ShowLeaderboard state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
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
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.warning.withOpacity(0.3), AppColors.warning.withOpacity(0.2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.warning,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                      TweenAnimationBuilder<int>(
                        key: ValueKey(state.countdown),
                        tween: IntTween(begin: state.countdown, end: state.countdown),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryBlue, Color(0xFF3B82F6)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${value}s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                Flexible(
                  child: state.leaderboardEvent.leaderboard.isEmpty
                      ? _buildEmptyLeaderboard()
                      : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(24),
                    itemCount: state.leaderboardEvent.leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = state.leaderboardEvent.leaderboard[index];
                      final isTopThree = index < 3;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildLeaderboardItem(entry, index + 1, isTopThree),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Câu hỏi tiếp theo sau ${state.countdown} giây',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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