import '../api/api.dart';
import '../bloc/quiz.dart';

class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  factory QuizRepository() => _instance;
  QuizRepository._internal();

  List<VideoData> _cachedVideos = [];
  int _currentVideoIndex = 0;

  // Lấy danh sách video từ API theo lessonId
  Future<List<VideoData>> getVideosByLessonId(int lessonId) async {
    try {
      final response = await ApiService.getVideosByLessonId(lessonId);

      if (response.status == 200) {
        _cachedVideos = response.data;
        _currentVideoIndex = 0;
        return _cachedVideos;
      } else {
        throw Exception('API returned error: ${response.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch videos for lesson $lessonId: $e');
    }
  }

  // Lấy video hiện tại
  VideoData? getCurrentVideo() {
    if (_cachedVideos.isEmpty || _currentVideoIndex >= _cachedVideos.length) {
      return null;
    }
    return _cachedVideos[_currentVideoIndex];
  }

  // Chuyển đến video tiếp theo
  bool nextVideo() {
    if (_currentVideoIndex < _cachedVideos.length - 1) {
      _currentVideoIndex++;
      return true;
    }
    return false;
  }

  // Quay về video trước
  bool previousVideo() {
    if (_currentVideoIndex > 0) {
      _currentVideoIndex--;
      return true;
    }
    return false;
  }

  // Lấy thông tin tiến độ
  Map<String, int> getProgress() {
    return {
      'current': _currentVideoIndex + 1,
      'total': _cachedVideos.length,
    };
  }

  // Reset về video đầu tiên
  void resetToFirst() {
    _currentVideoIndex = 0;
  }

  // Chuyển đến video theo index
  bool goToVideo(int index) {
    if (index >= 0 && index < _cachedVideos.length) {
      _currentVideoIndex = index;
      return true;
    }
    return false;
  }

  // Kiểm tra xem có video tiếp theo không
  bool hasNextVideo() {
    return _currentVideoIndex < _cachedVideos.length - 1;
  }

  // Kiểm tra xem có video trước đó không
  bool hasPreviousVideo() {
    return _currentVideoIndex > 0;
  }

  // Lấy tổng số video
  int getTotalVideos() {
    return _cachedVideos.length;
  }

  // Xóa cache
  void clearCache() {
    _cachedVideos.clear();
    _currentVideoIndex = 0;
  }
}