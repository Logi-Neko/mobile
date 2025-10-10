class LeaderboardEntry {
  final int participantId;
  final String name;
  final int score;
  final int rank;
  final int stars;

  LeaderboardEntry({
    required this.participantId,
    required this.name,
    required this.score,
    required this.rank,
    this.stars = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      participantId: json['participantId'] ?? 0,
      name: json['participantName'] ?? json['name'] ?? 'Unknown',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      stars: json['stars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'participantName': name,
      'score': score,
      'rank': rank,
      'stars': stars,
    };
  }
}
