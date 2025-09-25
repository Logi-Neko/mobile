import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/shared/color/app_color.dart';
import '../bloc/room_bloc.dart';
import '../widgets/quiz_header.dart';
import '../widgets/quiz_progress.dart';
import '../widgets/question_card.dart';
import '../widgets/answer_option.dart';
import 'quiz_result_screen.dart';

@RoutePage()
class RoomQuizScreen extends StatelessWidget {
  const RoomQuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc()..add(LoadQuizEvent()),
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
              if (state is QuizCompletedState) {
                _navigateToResult(context, state);
              }
            },
            builder: (context, state) {
              if (state is RoomLoading) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Đang tải câu hỏi...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is QuizInProgressState) {
                return _buildQuizContent(context, state);
              }

              if (state is RoomError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Đang khởi tạo quiz...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizInProgressState state) {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Column(
      children: [
        // Top bar với nút thoát, số câu, và thời gian
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button (Exit) - bên trái
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Số câu đang làm - ở giữa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${state.currentQuestionIndex + 1}/${state.questions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Timer - bên phải
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0:45',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Question container - mở rộng để có thêm không gian
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Question text với khoảng cách lớn hơn
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 4 Answer options in a row với khoảng cách tối ưu
                Expanded(
                  flex: 1,
                  child: Row(
                    children: List.generate(4, (index) {
                      if (index >= currentQuestion.options.length) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade300,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      
                      final option = currentQuestion.options[index];
                      final isSelected = state.selectedAnswer == option;
                      final isAnswered = state.isAnswered;
                      
                      List<Color> gradientColors;
                      Color textColor;
                      Color borderColor;
                      
                      if (isAnswered && isSelected) {
                        gradientColors = [Colors.green.shade400, Colors.green.shade600];
                        textColor = Colors.white;
                        borderColor = Colors.green.shade700;
                      } else if (isSelected) {
                        gradientColors = [Colors.blue.shade300, Colors.blue.shade500];
                        textColor = Colors.white;
                        borderColor = Colors.blue.shade700;
                      } else {
                        // Màu sắc gradient khác nhau cho từng đáp án
                        switch (index) {
                          case 0:
                            gradientColors = [Colors.red.shade200, Colors.red.shade400];
                            textColor = Colors.red.shade800;
                            borderColor = Colors.red.shade500;
                            break;
                          case 1:
                            gradientColors = [Colors.blue.shade200, Colors.blue.shade400];
                            textColor = Colors.blue.shade800;
                            borderColor = Colors.blue.shade500;
                            break;
                          case 2:
                            gradientColors = [Colors.green.shade200, Colors.green.shade400];
                            textColor = Colors.green.shade800;
                            borderColor = Colors.green.shade500;
                            break;
                          case 3:
                            gradientColors = [Colors.orange.shade200, Colors.orange.shade400];
                            textColor = Colors.orange.shade800;
                            borderColor = Colors.orange.shade500;
                            break;
                          default:
                            gradientColors = [Colors.grey.shade200, Colors.grey.shade400];
                            textColor = Colors.grey.shade800;
                            borderColor = Colors.grey.shade500;
                        }
                      }

                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: GestureDetector(
                            onTap: () => _selectAnswer(context, option, state.currentQuestionIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 100, // Tăng chiều cao từ 90 lên 100
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: borderColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    blurRadius: 8,
                                    offset: const Offset(-2, -2),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6), // Giảm padding từ 8 xuống 6
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min, // Thêm để tối ưu kích thước
                                  children: [
                                    // Index number với style đẹp
                                    // Container(
                                    //   width: 24, // Giảm từ 28 xuống 24
                                    //   height: 28, // Giảm từ 28 xuống 24
                                    //   decoration: BoxDecoration(
                                    //     color: textColor.withOpacity(0.2),
                                    //     shape: BoxShape.circle,
                                    //     border: Border.all(
                                    //       color: textColor,
                                    //       width: 2,
                                    //     ),
                                    //   ),
                                    //   child: Center(
                                    //     child: Text(
                                    //       '${state.answers}',
                                    //       style: TextStyle(
                                    //         fontSize: 12, // Giảm từ 14 xuống 12
                                    //         fontWeight: FontWeight.bold,
                                    //         color: textColor,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(height: 4), // Giảm từ 6 xuống 4
                                    // // Answer text
                                    Flexible( // Thay Expanded bằng Flexible
                                      child: Center(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 16, // Giảm từ 12 xuống 11
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF000000),
                                            height: 1.2, // Giảm line height từ 1.2 xuống 1.1
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3, // Tăng từ 2 lên 3 dòng
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom spacing - chỉ để tạo khoảng cách
        const SizedBox(height: 16),
      ],
    );
  }

  void _selectAnswer(BuildContext context, String selectedAnswer, int questionIndex) {
    context.read<RoomBloc>().add(AnswerQuestionEvent(
      selectedAnswer: selectedAnswer,
      questionIndex: questionIndex,
    ));

    // Wait 2 seconds then move to next question or finish quiz
    Future.delayed(const Duration(seconds: 2), () {
      final currentState = context.read<RoomBloc>().state;
      if (currentState is QuizInProgressState) {
        if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
          context.read<RoomBloc>().add(NextQuestionEvent());
        } else {
          context.read<RoomBloc>().add(FinishQuizEvent());
        }
      }
    });
  }

  void _navigateToResult(BuildContext context, QuizCompletedState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          questions: state.questions,
          answers: state.answers,
          score: state.score,
        ),
      ),
    );
  }
}