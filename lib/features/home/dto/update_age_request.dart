class UpdateAgeRequest {
  final String dateOfBirth;

  UpdateAgeRequest({
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth,
    };
  }

  factory UpdateAgeRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAgeRequest(
      dateOfBirth: json['dateOfBirth'] as String,
    );
  }
}