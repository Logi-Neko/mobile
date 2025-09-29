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
      : 'http://localhost:8081'; // Adjust for physical device testing

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

    final response = await http.post(uri);

    if (response.body == null) {
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

      return participantData
          .map((json) => Participant.fromJson(json as Map<String, dynamic>))
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
}