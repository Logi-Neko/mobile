class LeaderboardEntry {
  final String name;
  final int score;
  final int stars;

  LeaderboardEntry({
    required this.name,
    required this.score,
    required this.stars,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      stars: json['stars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
      'stars': stars,
    };
  }
}
