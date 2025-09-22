class QuizResponse {
  final int status;
  final String code;
  final String message;
  final List<VideoData> data;

  QuizResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      status: json['status'] ?? 0,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => VideoData.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class VideoData {
  final int id;
  final String title;
  final String videoUrl;
  final String videoPublicId;
  final String thumbnailUrl;
  final String thumbnailPublicId;
  final int duration;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final VideoQuestion videoQuestion;

  VideoData({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.videoPublicId,
    required this.thumbnailUrl,
    required this.thumbnailPublicId,
    required this.duration,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.videoQuestion,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      videoPublicId: json['videoPublicId'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      thumbnailPublicId: json['thumbnailPublicId'] ?? '',
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      videoQuestion: VideoQuestion.fromJson(json['videoQuestion'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'videoPublicId': videoPublicId,
      'thumbnailUrl': thumbnailUrl,
      'thumbnailPublicId': thumbnailPublicId,
      'duration': duration,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'videoQuestion': videoQuestion.toJson(),
    };
  }
}

class VideoQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String answer;

  VideoQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.answer,
  });

  factory VideoQuestion.fromJson(Map<String, dynamic> json) {
    return VideoQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      optionA: json['optionA'] ?? '',
      optionB: json['optionB'] ?? '',
      optionC: json['optionC'] ?? '',
      optionD: json['optionD'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'answer': answer,
    };
  }

  List<String> get options => [optionA, optionB, optionC, optionD];

  int get correctAnswerIndex {
    switch (answer.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }
}