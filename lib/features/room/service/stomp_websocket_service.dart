import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:logi_neko/features/room/dto/gameEvent.dart';
import 'dart:io' show Platform;

class StompWebSocketService {
  StompClient? _stompClient;
  final _eventController = StreamController<GameEvent>.broadcast();
  bool _isConnected = false;

  Stream<GameEvent> get events => _eventController.stream;

  // Use a platform-aware IP address
  final String _wsUrl = dotenv.env['SOCKET_URL'] ?? "";

  void connect(int contestId) {
    try {
      print('🔌 [STOMP] Connecting to: $_wsUrl/ws');
      
      _stompClient = StompClient(
        config: StompConfig(
          url: '$_wsUrl/ws',
          onConnect: (StompFrame frame) {
            print('✅ [STOMP] Connected successfully');
            _isConnected = true;
            _subscribeToContestEvents(contestId);
          },
          onWebSocketError: (dynamic error) {
            print('❌ [STOMP] WebSocket error: $error');
            if (!_eventController.isClosed) {
              _eventController.addError(error);
            }          },
          onStompError: (StompFrame frame) {
            print('❌ [STOMP] STOMP error: ${frame.body}');
            _eventController.addError('STOMP error: ${frame.body}');
          },
          onDisconnect: (StompFrame frame) {
            print('🔌 [STOMP] Disconnected');
            _isConnected = false;
          },
          beforeConnect: () async {
            print('🔄 [STOMP] Attempting to connect...');
          },
          stompConnectHeaders: {},
          webSocketConnectHeaders: {},
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('❌ [STOMP] Connection error: $e');
      _eventController.addError(e);
    }
  }

  void _subscribeToContestEvents(int contestId) {
    if (!_isConnected || _stompClient == null) {
      print('❌ [STOMP] Not connected, cannot subscribe');
      return;
    }

    final subscription = '/topic/contest.$contestId';
    print('📡 [STOMP] Subscribing to: $subscription');

    _stompClient!.subscribe(
      destination: subscription,
      callback: (StompFrame frame) {
        print('📨 [STOMP] Received message: ${frame.body}');
        try {
          final jsonData = json.decode(frame.body!);
          print('📋 [STOMP] Parsed JSON: $jsonData');
          final event = GameEvent.fromJson(jsonData);
          print('🎯 [STOMP] Created event: ${event.eventType}');
          _eventController.add(event);
        } catch (e) {
          print('❌ [STOMP] Error parsing message: $e');
          print('❌ [STOMP] Raw message: ${frame.body}');
        }
      },
    );
  }

  void sendMessage(String destination, Map<String, dynamic> message) {
    if (!_isConnected || _stompClient == null) {
      print('❌ [STOMP] Not connected, cannot send message');
      return;
    }

    print('📤 [STOMP] Sending message to $destination: $message');
    _stompClient!.send(
      destination: destination,
      body: json.encode(message),
    );
  }

  void disconnect() {
    print('🔌 [STOMP] Disconnecting...');
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
  }

  void dispose() {
    print('🔌 [STOMP] Disposing StompWebSocketService...');
    _stompClient?.deactivate();
    // Thêm kiểm tra trước khi đóng để tránh lỗi
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }

  bool get isConnected => _isConnected;
}
