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
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      startTime: DateTime.parse(json['startTime']),
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
      content: (json['content'] as List)
          .map((item) => Contest.fromJson(item))
          .toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? 0,
    );
  }
}class Participant {
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
    // Try multiple possible field names for account name
    String? accountName = json['accountName']?.toString() ?? 
                         json['username']?.toString() ?? 
                         json['fullName']?.toString() ?? 
                         json['name']?.toString();
    
    // Handle special cases
    if (accountName == null || accountName.isEmpty || accountName.toLowerCase() == 'system') {
      // Try to get user info from nested object or use ID
      if (json['account'] != null) {
        final account = json['account'] as Map<String, dynamic>;
        accountName = account['username']?.toString() ?? 
                     account['fullName']?.toString() ?? 
                     account['name']?.toString();
      }
      
      // Final fallback
      if (accountName == null || accountName.isEmpty || accountName.toLowerCase() == 'system') {
        accountName = 'User ${json['id']?.toString() ?? 'Unknown'}';
      }
    }
    
    return Participant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      accountName: accountName,
      score: int.tryParse(json['score']?.toString() ?? '') ?? 0,
      joinAt: json['joinAt'] != null ? DateTime.tryParse(json['joinAt'].toString()) : null,
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
      id: json["id"],
      contestId: json["contestId"],
      questionId: json["questionId"],
      index: json["index"],
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
      id: json["id"],
      optionText: json["optionText"],
      isCorrect: json["isCorrect"],
      questionId: json["questionId"],
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
      id: json["id"],
      questionText: json["questionText"],
      options: (json["options"] as List<dynamic>)
          .map((e) => AnswerOptionResponse.fromJson(e))
          .toList(),
      points: json["points"],
      timeLimit: json["timeLimit"],
    );
  }
}
