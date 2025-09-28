import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final List<int> weeklyData = [30, 45, 60, 35, 80, 25, 40];
  final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thời gian học tuần này',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '12p / ngày',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: weeklyData[index].toDouble(),
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    weekDays[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
