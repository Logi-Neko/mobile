import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/equation_display.dart';
import '../widgets/answer_button.dart';
import '../widgets/progress_indicator.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class QuizChoiceScreen extends StatefulWidget {
  @override
  _QuizChoiceScreenState createState() => _QuizChoiceScreenState();
}

class _QuizChoiceScreenState extends State<QuizChoiceScreen> {
  int selectedAnswer = -1;
  bool showResult = false;
  int correctAnswerIndex = 1;

  List<String> answers = [
    "17 - 17 - 0",
    "17 - 0 - 17",
    "17 - 17 - 17",
    "25 - 25 - 1"
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void onAnswerSelected(int index) {
    setState(() {
      selectedAnswer = index;
      showResult = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        selectedAnswer = -1;
        showResult = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text("Quay lại",
                          style: TextStyle(color: Colors.black)),
                    ),

                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: EquationDisplay(),
                      ),

                      SizedBox(width: 20),


                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Grid đáp án
                            Text(
                              'Hãy chọn đáp án đúng? 🤔',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 20),

                            Expanded(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: answers.length,
                                itemBuilder: (context, index) {
                                  return AnswerButton(
                                    text: answers[index],
                                    isSelected: selectedAnswer == index,
                                    isCorrect: index == correctAnswerIndex,
                                    showResult: showResult,
                                    onPressed: () => onAnswerSelected(index),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                GameProgressIndicator(current: 9, total: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}