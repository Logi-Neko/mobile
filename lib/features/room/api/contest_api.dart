import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logi_neko/features/room/dto/contest.dart';
import 'dart:io' show Platform;

class ContestService {
  // Use a platform-aware IP address
  // '10.0.2.2' for Android Emulator
  // 'localhost' or '127.0.0.1' for iOS Simulator
  // Your machine's local IP address (e.g., '192.168.1.5') for physical devices
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8081'
      : 'http://192.168.1.12:8081'; // Adjust for physical device testing

  Future<PaginatedResponse> getAllContests({
    String? keyword,
    int page = 0,
    int size = 10,
    String sortBy = 'id',
    String sortDir = 'asc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    };

    final uri = Uri.parse('$baseUrl/api/contest')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PaginatedResponse.fromJson(jsonData['data']);
    } else {
      throw Exception('Failed to load contests');
    }
  }
  Future<Contest> getContestById(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/contest/$contestId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      // Giả sử API trả về {status: 200, message: "...", data: {...}}
      return Contest.fromJson(jsonData['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load contest details: ${response.body}');
    }
  }
  Future<void> deleteContest(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/contest/$id'),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete contest');
    }
  }
  Future<void> joinContest(int contestId, int accountId) async {
    final uri = Uri.parse('$baseUrl/api/game/$contestId/join')
        .replace(queryParameters: {'accountId': accountId.toString()});

    print('🔑 [ContestAPI] Joining contest $contestId with accountId: $accountId');
    print('🔑 [ContestAPI] Request URL: $uri');

    final response = await http.post(uri);

    print('🔑 [ContestAPI] Join contest response status: ${response.statusCode}');
    print('🔑 [ContestAPI] Join contest response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to join contest: ${response.body}');
    }
  }

  Future<List<Participant>> getAllParticipantsInContest(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/contest/participant')
        .replace(queryParameters: {'contestId': contestId.toString()});

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> participantData = jsonData['data'];
      
      print('📋 [ContestAPI] Raw participants data: $participantData');

      return participantData
          .map((json) {
            print('👤 [ContestAPI] Processing participant: $json');
            return Participant.fromJson(json as Map<String, dynamic>);
          })
          .toList();
    } else {
      throw Exception('Failed to load participants: ${response.body}');
    }
  }
  Future<void> startContest(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/game/$contestId/start');

    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to start contest: ${response.body}');
    }
  }

  Future<void> submitAnswer({
    required int contestId,
    required int participantId,
    required int contestQuestionId,
    required String answer,
    int? timeSpent, // Time spent in seconds
  }) async {
    try {
      // Validate inputs
      if (answer.trim().isEmpty) {
        throw Exception('Answer cannot be empty');
      }
      
      final queryParams = {
        'answer': answer.trim(),
        if (timeSpent != null && timeSpent >= 0) 'timeSpent': timeSpent.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/api/game/$contestId/submit/$participantId/$contestQuestionId')
          .replace(queryParameters: queryParams);

      print('📤 [ContestAPI] Submitting answer: "$answer", timeSpent: $timeSpent seconds');
      print('📤 [ContestAPI] Request URL: $uri');
      print('📤 [ContestAPI] Query params: $queryParams');
      
      final response = await http.post(uri);
      
      print('📤 [ContestAPI] Response status: ${response.statusCode}');
      print('📤 [ContestAPI] Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [ContestAPI] Answer submitted successfully');
      } else {
        // Parse error response for better error messages
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['message'] ?? 'Unknown error';
          throw Exception('Failed to submit answer: $errorMessage');
        } catch (e) {
          throw Exception('Failed to submit answer: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ [ContestAPI] Error submitting answer: $e');
      rethrow;
    }
  }

  // This endpoint is likely called by a host/admin, but included for completeness
  Future<void> revealQuestion(int contestQuestionId) async {
    final uri = Uri.parse('$baseUrl/api/game/reveal/$contestQuestionId');
    final response = await http.post(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to reveal question');
    }
  }

  Future<void> endQuestion(int contestQuestionId) async {
    final uri = Uri.parse('$baseUrl/api/game/end-question/$contestQuestionId');
    final response = await http.post(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to end question: ${response.body}');
    }
  }

  Future<void> endContest(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/game/$contestId/end');
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to end contest: ${response.body}');
    }
  }

  Future<void> refreshLeaderboard(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/game/$contestId/leaderboard/refresh');
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to refresh leaderboard: ${response.body}');
    }
  }

  Future<List<ContestQuestionResponse>> getContestQuestions(int contestId) async {
    final response = await http.get(Uri.parse("$baseUrl/api/contest-questions/contest/$contestId"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      return data.map((e) => ContestQuestionResponse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load contest questions");
    }
  }

  Future<QuestionResponse> getQuestionById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/api/questions/$id"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return QuestionResponse.fromJson(json["data"]);
    } else {
      throw Exception("Failed to load question");
    }
  }

  Future<List<dynamic>> getLeaderboard(int contestId) async {
    final uri = Uri.parse('$baseUrl/api/game/$contestId/leaderboard');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data']['leaderboard'] as List<dynamic>;
    } else {
      throw Exception('Failed to get leaderboard: ${response.body}');
    }
  }
}