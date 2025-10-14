import 'dart:async';
import 'package:logi_neko/features/room/api/contest_api.dart';

/// Fallback service to poll contest status when WebSocket is not available
class ContestPollingService {
  final ContestService _apiService;
  Timer? _pollingTimer;
  final _eventController = StreamController<ContestStatus>.broadcast();
  
  ContestStatus _lastStatus = ContestStatus.waiting;
  int _contestId = 0;

  Stream<ContestStatus> get statusStream => _eventController.stream;

  ContestPollingService({ContestService? apiService}) 
      : _apiService = apiService ?? ContestService();

  void startPolling(int contestId) {
    _contestId = contestId;
    print('🔄 [PollingService] Starting polling for contest $contestId');
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkContestStatus();
    });
  }

  void stopPolling() {
    print('🔄 [PollingService] Stopping polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkContestStatus() async {
    try {
      final contest = await _apiService.getContestById(_contestId);
      print('🔄 [PollingService] Contest status: ${contest.status}');
      
      ContestStatus newStatus;
      switch (contest.status.toLowerCase()) {
        case 'started':
        case 'in_progress':
          newStatus = ContestStatus.started;
          break;
        case 'ended':
        case 'finished':
          newStatus = ContestStatus.ended;
          break;
        default:
          newStatus = ContestStatus.waiting;
      }
      
      if (newStatus != _lastStatus) {
        _lastStatus = newStatus;
        _eventController.add(newStatus);
        print('🔄 [PollingService] Status changed to: $newStatus');
        
        // Stop polling if contest ended
        if (newStatus == ContestStatus.ended) {
          stopPolling();
        }
      }
    } catch (e) {
      print('❌ [PollingService] Error checking status: $e');
    }
  }

  void dispose() {
    stopPolling();
    _eventController.close();
  }
}

enum ContestStatus {
  waiting,
  started,
  ended,
}
