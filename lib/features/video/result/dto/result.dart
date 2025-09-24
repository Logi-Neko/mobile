class QuizResultResponse {
  final int status;
  final String code;
  final String message;
  final QuizResultData data;

  QuizResultResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuizResultResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultResponse(
      status: json['status'] ?? 0,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: QuizResultData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class QuizResultData {
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String grade;
  final bool passed;
  final String completedAt;

  QuizResultData({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.grade,
    required this.passed,
    required this.completedAt,
  });

  factory QuizResultData.fromJson(Map<String, dynamic> json) {
    return QuizResultData(
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      grade: json['grade'] ?? '',
      passed: json['passed'] ?? false,
      completedAt: json['completedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'percentage': percentage,
      'grade': grade,
      'passed': passed,
      'completedAt': completedAt,
    };
  }
}

class SubmitAnswerRequest {
  final int videoId;
  final String answer;

  SubmitAnswerRequest({
    required this.videoId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'answer': answer,
    };
  }
}