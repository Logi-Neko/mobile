import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logi_neko/core/router/app_router.dart';
import 'dart:async';
import 'package:logi_neko/shared/color/app_color.dart';
import 'package:logi_neko/features/room/service/stomp_websocket_service.dart';
import 'package:logi_neko/features/room/service/contest_polling_service.dart';
import 'package:logi_neko/features/room/api/contest_api.dart';

@RoutePage()
class CountdownScreen extends StatefulWidget {
  final int contestId;
  final int participantId;

  const CountdownScreen({
    Key? key,
    required this.contestId,
    required this.participantId,
  }) : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _countdown = 5;
  Timer? _timer;
  Timer? _timeoutTimer;
  StompWebSocketService? _stompService;
  ContestPollingService? _pollingService;
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _pollingSubscription;
  bool _isWaitingForContestStart = false;
  String _statusMessage = 'Chuẩn bị bắt đầu!';
  final ContestService _contestService = ContestService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _connectToWebSocket();
      }
    });
  }

  void _connectToWebSocket() {
    print('🚀 [CountdownScreen] Starting STOMP WebSocket connection for contest ${widget.contestId}');
    setState(() {
      _isWaitingForContestStart = true;
      _statusMessage = 'Đang chờ contest bắt đầu...';
    });

    _stompService = StompWebSocketService();
    _stompService!.connect(widget.contestId);

    _webSocketSubscription = _stompService!.events.listen(
      (gameEvent) {
        print('🎯 [CountdownScreen] Received STOMP event: ${gameEvent.eventType}');
        if (gameEvent.eventType == 'contest.started') {
          print('🎉 [CountdownScreen] Contest started via STOMP! Navigating to quiz...');
          _navigateToQuiz();
        }
      },
      onError: (error) {
        print('❌ [CountdownScreen] STOMP WebSocket error: $error');
        print('🔄 [CountdownScreen] Falling back to polling service...');
        _startPollingFallback();
      },
    );

    // Try to start the contest automatically
    _tryStartContest();

    // Always start polling fallback after 2 seconds regardless of WebSocket status
    _timeoutTimer = Timer(const Duration(seconds: 2), () {
      if (_isWaitingForContestStart && _pollingService == null) {
        print('⏰ [CountdownScreen] Starting polling fallback (2s timeout)...');
        _startPollingFallback();
      }
    });
  }

  void _startPollingFallback() {
    print('🔄 [CountdownScreen] Starting polling fallback for contest ${widget.contestId}');
    setState(() {
      _statusMessage = 'Đang kiểm tra trạng thái contest...';
    });

    _pollingService = ContestPollingService();
    _pollingService!.startPolling(widget.contestId);

    _pollingSubscription = _pollingService!.statusStream.listen(
      (status) {
        print('🔄 [CountdownScreen] Polling status: $status');
        if (status == ContestStatus.started) {
          print('🎉 [CountdownScreen] Contest started via polling! Navigating to quiz...');
          _navigateToQuiz();
        }
      },
      onError: (error) {
        print('❌ [CountdownScreen] Polling error: $error');
        setState(() {
          _statusMessage = 'Lỗi kiểm tra trạng thái: $error';
        });
      },
    );
  }

  Future<void> _tryStartContest() async {
    try {
      print('🎯 [CountdownScreen] Attempting to start contest ${widget.contestId}');
      setState(() {
        _statusMessage = 'Đang khởi động contest...';
      });
      
      await _contestService.startContest(widget.contestId);
      print('✅ [CountdownScreen] Contest started successfully');
      
      setState(() {
        _statusMessage = 'Contest đã bắt đầu! Đang chờ câu hỏi...';
      });
    } catch (e) {
      final errorMessage = e.toString();
      print('⚠️ [CountdownScreen] Failed to start contest: $e');
      
      // Check if contest is already running
      if (errorMessage.contains('RUNNING') || errorMessage.contains('already')) {
        print('ℹ️ [CountdownScreen] Contest is already running, proceeding...');
        setState(() {
          _statusMessage = 'Contest đã bắt đầu! Đang chờ câu hỏi...';
        });
      } else {
        print('❌ [CountdownScreen] Unexpected error starting contest: $e');
        setState(() {
          _statusMessage = 'Lỗi khởi động contest. Đang thử lại...';
        });
        
        // Try again after 2 seconds
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _statusMessage = 'Đang chờ contest bắt đầu...';
            });
          }
        });
      }
    }
  }

  void _navigateToQuiz() {
    if (mounted) {
      _webSocketSubscription?.cancel();
      _stompService?.disconnect();
      _pollingSubscription?.cancel();
      _pollingService?.dispose();
      
      context.router.replaceAll([
        RoomQuizRoute(
          contestId: widget.contestId,
          participantId: widget.participantId,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    _webSocketSubscription?.cancel();
    _stompService?.dispose();
    _pollingSubscription?.cancel();
    _pollingService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientMiddle,
              AppColors.gradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout for mobile
                if (constraints.maxWidth < 600) {
                  return _buildMobileLayout();
                }
                return _buildDesktopLayout();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Colors.white70],
          ).createShader(bounds),
          child: Text(
            _statusMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _isWaitingForContestStart 
                ? 'Đang kết nối với server...'
                : 'Trò chơi sẽ bắt đầu trong...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientMiddle.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: Center(
            child: _isWaitingForContestStart
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradientStart),
                    strokeWidth: 4,
                  )
                : ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientMiddle,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 40),
        if (!_isWaitingForContestStart)
          Container(
            width: 200,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (5 - _countdown) / 5,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ).createShader(bounds),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _isWaitingForContestStart 
                      ? 'Đang kết nối với server...'
                      : 'Trò chơi sẽ bắt đầu trong...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isWaitingForContestStart)
                Container(
                  width: 250,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (5 - _countdown) / 5,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientMiddle.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 10,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Center(
                child: _isWaitingForContestStart
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradientStart),
                        strokeWidth: 4,
                      )
                    : ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientMiddle,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}