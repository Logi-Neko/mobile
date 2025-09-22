// lib/data/models/signup_request.dart

import 'package:equatable/equatable.dart';

class SignupResponse extends Equatable {
  final int id;
  final String username;
  final String email;
  final String fullName;

  const SignupResponse({
    required this.username,
    required this.email,
    required this.fullName,
    required this.id,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'id': id,
    };
  }

  @override
  List<Object?> get props => [username, email, fullName, id];
}