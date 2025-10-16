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

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Progress animation - smooth 60fps
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Pulse animation for loading state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
          final progress = (6 - _countdown) / 5;
          _progressAnimation = Tween<double>(
            begin: progress - 0.2,
            end: progress,
          ).animate(CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOut,
          ));
          _progressController.reset();
          _progressController.forward();
        });
      } else {
        timer.cancel();
        _connectToWebSocket();
      }
    });
  }

  void _connectToWebSocket() {
    setState(() {
      _isWaitingForContestStart = true;
      _statusMessage = 'Đang kết nối...';
    });

    _stompService = StompWebSocketService();
    _stompService!.connect(widget.contestId);

    _webSocketSubscription = _stompService!.events.listen(
          (gameEvent) {
        if (gameEvent.eventType == 'contest.started') {
          _navigateToQuiz();
        }
      },
      onError: (error) {
        _startPollingFallback();
      },
    );

    _tryStartContest();

    _timeoutTimer = Timer(const Duration(seconds: 2), () {
      if (_isWaitingForContestStart && _pollingService == null) {
        _startPollingFallback();
      }
    });
  }

  void _startPollingFallback() {
    setState(() {
      _statusMessage = 'Đang kiểm tra...';
    });

    _pollingService = ContestPollingService();
    _pollingService!.startPolling(widget.contestId);

    _pollingSubscription = _pollingService!.statusStream.listen(
          (status) {
        if (status == ContestStatus.started) {
          _navigateToQuiz();
        }
      },
    );
  }

  Future<void> _tryStartContest() async {
    try {
      setState(() {
        _statusMessage = 'Đang khởi động...';
      });

      await _contestService.startContest(widget.contestId);

      setState(() {
        _statusMessage = 'Sẵn sàng!';
      });
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('RUNNING') || errorMessage.contains('already')) {
        setState(() {
          _statusMessage = 'Sẵn sàng!';
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
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradientStart.withOpacity(0.9),
              AppColors.gradientMiddle.withOpacity(0.95),
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return isMobile
                    ? _buildMobileLayout()
                    : _buildDesktopLayout();
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
        _buildStatusMessage(),
        const SizedBox(height: 60),
        _buildCountdownCircle(220),
        const SizedBox(height: 60),
        if (!_isWaitingForContestStart) _buildProgressBar(280),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusMessage(),
              const SizedBox(height: 40),
              if (!_isWaitingForContestStart) _buildProgressBar(350),
            ],
          ),
        ),
        const SizedBox(width: 100),
        _buildCountdownCircle(300),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          _statusMessage,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCountdownCircle(double size) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 900),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Colors.white,
              Color(0xFFFAFAFA),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 50,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: AppColors.gradientMiddle.withOpacity(0.4),
              blurRadius: 80,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Center(
          child: _isWaitingForContestStart
              ? _buildPulsingLoader()
              : _buildAnimatedCountdown(size),
        ),
      ),
    );
  }

  Widget _buildPulsingLoader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gradientStart,
                  AppColors.gradientMiddle,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCountdown(double size) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_countdown),
      duration: const Duration(milliseconds: 700),
      tween: Tween(begin: 1.4, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientStart,
                AppColors.gradientMiddle,
                AppColors.gradientEnd,
              ],
            ).createShader(bounds),
            child: Text(
              '$_countdown',
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                shadows: const [
                  Shadow(
                    color: Color(0x30000000),
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double width) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background shimmer effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Progress fill
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFFAFAFA),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}