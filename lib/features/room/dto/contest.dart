import 'dart:core';

class Contest {
  final int id;
  final String code;
  final String title;
  final String description;
  final String status;
  final DateTime startTime;

  Contest({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.status,
    required this.startTime,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      // Thêm kiểm tra null trước khi parse DateTime
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PaginatedResponse {
  final List<Contest> content;
  final int totalPages;
  final int totalElements;
  final int currentPage;
  final int pageSize;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      // Thêm kiểm tra null cho danh sách content
      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => Contest.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
    );
  }
}

class Participant {
  final int id;
  final String? accountName;
  final int score;
  final DateTime? joinAt;

  Participant({
    required this.id,
    this.accountName,
    required this.score,
    this.joinAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    String? accountName = json['accountName']?.toString() ??
        json['username']?.toString() ??
        json['fullName']?.toString() ??
        json['name']?.toString();

    if (accountName == null ||
        accountName.isEmpty ||
        accountName.toLowerCase() == 'system') {
      if (json['account'] != null) {
        final account = json['account'] as Map<String, dynamic>;
        accountName = account['username']?.toString() ??
            account['fullName']?.toString() ??
            account['name']?.toString();
      }

      if (accountName == null ||
          accountName.isEmpty ||
          accountName.toLowerCase() == 'system') {
        accountName = 'User ${json['id']?.toString() ?? 'Unknown'}';
      }
    }

    return Participant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      accountName: accountName,
      score: int.tryParse(json['score']?.toString() ?? '') ?? 0,
      joinAt: json['joinAt'] != null
          ? DateTime.tryParse(json['joinAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
      'score': score,
      'joinAt': joinAt?.toIso8601String(),
    };
  }
}

class ContestQuestionResponse {
  final int id;
  final int contestId;
  final int questionId;
  final int index;

  ContestQuestionResponse({
    required this.id,
    required this.contestId,
    required this.questionId,
    required this.index,
  });

  factory ContestQuestionResponse.fromJson(Map<String, dynamic> json) {
    return ContestQuestionResponse(
      // Thêm ?? 0 để xử lý null
      id: json["id"] ?? 0,
      contestId: json["contestId"] ?? 0,
      questionId: json["questionId"] ?? 0,
      index: json["index"] ?? 0,
    );
  }
}

class AnswerOptionResponse {
  final int id;
  final String optionText;
  final bool isCorrect;
  final int questionId;

  AnswerOptionResponse({
    required this.id,
    required this.optionText,
    required this.isCorrect,
    required this.questionId,
  });

  factory AnswerOptionResponse.fromJson(Map<String, dynamic> json) {
    return AnswerOptionResponse(
      // Thêm các giá trị mặc định để xử lý null
      id: json["id"] ?? 0,
      optionText: json["optionText"] ?? '',
      isCorrect: json["isCorrect"] ?? false,
      // ĐÂY LÀ CHỖ SỬA QUAN TRỌNG NHẤT
      questionId: json["questionId"] ?? 0,
    );
  }
}

class QuestionResponse {
  final int id;
  final String questionText;
  final List<AnswerOptionResponse> options;
  final int points;
  final int? timeLimit;

  QuestionResponse({
    required this.id,
    required this.questionText,
    required this.options,
    required this.points,
    this.timeLimit,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      // Thêm các giá trị mặc định để xử lý null
      id: json["id"] ?? 0,
      questionText: json["questionText"] ?? 'N/A',
      options: (json["options"] as List<dynamic>? ?? [])
          .map((e) => AnswerOptionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      points: json["points"] ?? 100,
      timeLimit: json["timeLimit"],
    );
  }
}