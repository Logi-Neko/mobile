import 'package:flutter/material.dart';

class SubjectProgress extends StatelessWidget {
  final List<Map<String, dynamic>> subjects = [
    {
      'name': '🧠 Tư duy logic',
      'progress': 0.0,
      'total': 10,
    },
    {
      'name': '📊 Toán học cơ bản',
      'progress': 0.0,
      'total': 10,
    },
    {
      'name': '🎭 Xử lí tình huống',
      'progress': 0.0,
      'total': 10,
    },
    {
      'name': '🔤 Nhận biết chữ cái',
      'progress': 0.0,
      'total': 10,
    },
  ];

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
          Text(
            'Tiến độ các môn học',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: subjects.map((subject) => _buildSubjectItem(subject)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(Map<String, dynamic> subject) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '0/${subject['total']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: subject['progress'],
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}