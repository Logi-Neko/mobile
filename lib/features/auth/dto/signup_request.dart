// lib/data/models/signup_request.dart

import 'package:equatable/equatable.dart';

class SignUpRequest extends Equatable {
  final String username;
  final String email;
  final String fullName;
  final String password;

  const SignUpRequest({
    required this.username,
    required this.email,
    required this.fullName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [username, email, fullName, password];
}