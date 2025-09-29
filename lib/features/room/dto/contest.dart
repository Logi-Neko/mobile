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
      currentPage: json['currentPage']as int? ?? 0,
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
    return Participant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      accountName: json['accountName']?.toString(),
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
