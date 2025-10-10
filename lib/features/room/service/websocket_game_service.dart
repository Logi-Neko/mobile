import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';
import 'dart:io' show Platform;

class GameWebSocketService {
  WebSocketChannel? _channel;
  final _eventController = StreamController<GameEvent>.broadcast();

  Stream<GameEvent> get events => _eventController.stream;

  String get _wsUrl => Platform.isAndroid
      ? 'ws://10.0.2.2:8081'
      : 'ws://localhost:8081';

  void connect(int contestId) {
    try {
      final uri = Uri.parse('$_wsUrl/ws/game/$contestId');
      print('🔌 [WebSocket] Connecting to: $uri');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
            (message) {
          print('📨 [WebSocket] Received message: $message');
          try {
            final jsonData = json.decode(message);
            print('📋 [WebSocket] Parsed JSON: $jsonData');
            final event = GameEvent.fromJson(jsonData);
            print('🎯 [WebSocket] Created event: ${event.eventType}');
            _eventController.add(event);
          } catch (e) {
            print('❌ [WebSocket] Error parsing message: $e');
            print('❌ [WebSocket] Raw message: $message');
          }
        },
        onError: (error) {
          print('❌ [WebSocket] Connection error: $error');
          _eventController.addError(error);
        },
        onDone: () {
          print('🔌 [WebSocket] Connection closed');
        },
      );
    } catch (e) {
      print('❌ [WebSocket] Failed to connect: $e');
      _eventController.addError(e);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}