import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/learning_card_widget.dart';
import 'package:logi_neko/shared/color/app_color.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> learningTopics = [
    {
      'title': 'Tư duy logic',
      'icon': Icons.psychology,
      'color': const Color(0xFF9C5AB8),
      'bgColor': const Color(0xFFE1BEF0),
    },
    {
      'title': 'Xử lý tình huống',
      'icon': Icons.lightbulb,
      'color': const Color(0xFFFF8C42),
      'bgColor': const Color(0xFFFFE0CC),
    },
    {
      'title': 'Chữ cái',
      'icon': Icons.text_fields,
      'color': const Color(0xFF4CAF50),
      'bgColor': const Color(0xFFDCF2DD),
    },
    {
      'title': 'Toán học',
      'icon': Icons.calculate,
      'color': const Color(0xFF2196F3),
      'bgColor': const Color(0xFFD1E7FF),
      'badge': '12\n34',
    },
    {
      'title': 'Trò chơi',
      'icon': Icons.games,
      'color': const Color(0xFFFF5722),
      'bgColor': const Color(0xFFFFE4E1),
    },
    {
      'title': 'Phòng thi đấu',
      'icon': Icons.sports_esports,
      'color': const Color(0xFF9C5AB8),
      'bgColor': const Color(0xFFE1BEF0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const HeaderWidget(),
                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[0]['title'],
                                icon: learningTopics[0]['icon'],
                                color: learningTopics[0]['color'],
                                bgColor: learningTopics[0]['bgColor'],
                                badge: learningTopics[0]['badge'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[1]['title'],
                                icon: learningTopics[1]['icon'],
                                color: learningTopics[1]['color'],
                                bgColor: learningTopics[1]['bgColor'],
                                badge: learningTopics[1]['badge'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[2]['title'],
                                icon: learningTopics[2]['icon'],
                                color: learningTopics[2]['color'],
                                bgColor: learningTopics[2]['bgColor'],
                                badge: learningTopics[2]['badge'],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[3]['title'],
                                icon: learningTopics[3]['icon'],
                                color: learningTopics[3]['color'],
                                bgColor: learningTopics[3]['bgColor'],
                                badge: learningTopics[3]['badge'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[4]['title'],
                                icon: learningTopics[4]['icon'],
                                color: learningTopics[4]['color'],
                                bgColor: learningTopics[4]['bgColor'],
                                badge: learningTopics[4]['badge'],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: LearningCardWidget(
                                title: learningTopics[5]['title'],
                                icon: learningTopics[5]['icon'],
                                color: learningTopics[5]['color'],
                                bgColor: learningTopics[5]['bgColor'],
                                badge: learningTopics[5]['badge'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}