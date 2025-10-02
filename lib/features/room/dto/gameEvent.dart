import 'package:logi_neko/features/room/dto/leaderboard_entry.dart';

abstract class GameEvent {
  final String eventType;
  final DateTime timestamp;

  GameEvent({required this.eventType, required this.timestamp});

  factory GameEvent.fromJson(Map<String, dynamic> json) {
    switch (json['eventType']) {
      case 'question.revealed':
        return QuestionRevealedEvent.fromJson(json);
      case 'leaderboard.updated':
        return LeaderboardUpdatedEvent.fromJson(json);
      case 'contest.ended':
        return ContestEndedEvent.fromJson(json);
      case 'contest.started':
        return ContestStartedEvent.fromJson(json);
      case 'participant.joined':
        return ParticipantJoinedEvent.fromJson(json);
      case 'participant.left':
        return ParticipantLeftEvent.fromJson(json);
      default:
        throw Exception('Unknown event type: ${json['eventType']}');
    }
  }

  // Helper method to parse timestamp from various formats
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is num) {
      // Handle Unix timestamp in seconds or milliseconds
      int timestampMs;
      if (timestamp > 1e12) {
        // Already in milliseconds
        timestampMs = timestamp.toInt();
      } else {
        // In seconds, convert to milliseconds
        timestampMs = (timestamp * 1000).toInt();
      }
      return DateTime.fromMillisecondsSinceEpoch(timestampMs);
    } else {
      throw Exception('Invalid timestamp format: $timestamp');
    }
  }
}

// Event for a new question
class QuestionRevealedEvent extends GameEvent {
  final int contestQuestionId;
  final String question;
  final List<String> options;

  QuestionRevealedEvent({
    required String eventType,
    required DateTime timestamp,
    required this.contestQuestionId,
    required this.question,
    required this.options,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory QuestionRevealedEvent.fromJson(Map<String, dynamic> json) {
    final questionData = json['question'] as Map<String, dynamic>;
    final optionsData = questionData['options'] as List<dynamic>;
    
    return QuestionRevealedEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
      contestQuestionId: json['contestQuestionId'],
      question: questionData['questionText'] ?? questionData['text'] ?? '',
      options: optionsData.map((option) => option['optionText'] ?? option.toString()).cast<String>().toList(),
    );
  }
}

// Event for leaderboard updates
class LeaderboardUpdatedEvent extends GameEvent {
  final List<LeaderboardEntry> leaderboard;

  LeaderboardUpdatedEvent({
    required String eventType,
    required DateTime timestamp,
    required this.leaderboard,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory LeaderboardUpdatedEvent.fromJson(Map<String, dynamic> json) {
    final leaderboardData = List<Map<String, dynamic>>.from(json['leaderboard']);
    return LeaderboardUpdatedEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
      leaderboard: leaderboardData.map((e) => LeaderboardEntry.fromJson(e)).toList(),
    );
  }
}


// Event for when the contest starts
class ContestStartedEvent extends GameEvent {
  ContestStartedEvent({
    required String eventType,
    required DateTime timestamp,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory ContestStartedEvent.fromJson(Map<String, dynamic> json) {
    return ContestStartedEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
    );
  }
}

// Event for when a participant joins
class ParticipantJoinedEvent extends GameEvent {
  final String participantName;
  final int participantId;

  ParticipantJoinedEvent({
    required String eventType,
    required DateTime timestamp,
    required this.participantName,
    required this.participantId,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory ParticipantJoinedEvent.fromJson(Map<String, dynamic> json) {
    return ParticipantJoinedEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
      participantName: json['participantName'] ?? '',
      participantId: json['participantId'] ?? 0,
    );
  }
}

// Event for when a participant leaves
class ParticipantLeftEvent extends GameEvent {
  final String participantName;
  final int participantId;

  ParticipantLeftEvent({
    required String eventType,
    required DateTime timestamp,
    required this.participantName,
    required this.participantId,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory ParticipantLeftEvent.fromJson(Map<String, dynamic> json) {
    return ParticipantLeftEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
      participantName: json['participantName'] ?? '',
      participantId: json['participantId'] ?? 0,
    );
  }
}

// Event for when the contest ends
class ContestEndedEvent extends GameEvent {
  ContestEndedEvent({
    required String eventType,
    required DateTime timestamp,
  }) : super(eventType: eventType, timestamp: timestamp);

  factory ContestEndedEvent.fromJson(Map<String, dynamic> json) {
    return ContestEndedEvent(
      eventType: json['eventType'],
      timestamp: GameEvent._parseTimestamp(json['timestamp']),
    );
  }
}