import 'package:logi_neko/core/exception/exceptions.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';
import '../dto/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses({bool forceRefresh = false});
}

class CourseRepositoryImpl implements CourseRepository {
  static const String _cacheKey = 'courses_cache';
  static const String _cacheTimeKey = 'courses_cache_time';
  static const Duration _cacheDuration = Duration(hours: 1);

  @override
  Future<List<Course>> getCourses({bool forceRefresh = false}) async {
    // 1. Nếu có cache hợp lệ & không force refresh → trả ngay
    if (!forceRefresh) {
      final cachedCourses = await _getFromCache();
      if (cachedCourses != null) {
        print('✅ [CourseCache] Loaded from cache (${cachedCourses.length} courses)');
        return cachedCourses;
      }
    }

    // 2. Gọi API (chậm 20s)
    print('🌐 [CourseAPI] Fetching from server...');
    final response = await CourseApi.getCourses();

    if (response.isSuccess && response.hasData) {
      final courses = response.data!;

      // 3. Lưu cache
      await _saveToCache(courses);
      print('💾 [CourseCache] Saved ${courses.length} courses to cache');

      return courses;
    }

    // 4. Nếu API fail, thử dùng old cache
    final oldCachedCourses = await _getFromCache();
    if (oldCachedCourses != null) {
      print('⚠️ [CourseCache] API failed, using old cache');
      return oldCachedCourses;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch courses',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_COURSES_ERROR',
    );
  }

  // Lấy từ cache
  Future<List<Course>?> _getFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check cache còn hợp lệ không
      final cacheTime = prefs.getInt(_cacheTimeKey);
      if (cacheTime != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - cacheTime > _cacheDuration.inMilliseconds) {
          // Cache hết hạn
          await prefs.remove(_cacheKey);
          await prefs.remove(_cacheTimeKey);
          return null;
        }
      }

      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson == null) return null;

      final jsonList = jsonDecode(cachedJson) as List<dynamic>;
      return jsonList
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [CourseCache] Error reading cache: $e');
      return null;
    }
  }

  // Lưu cache
  Future<void> _saveToCache(List<Course> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonList = courses.map((c) => c.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('❌ [CourseCache] Error saving cache: $e');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      print('🗑️ [CourseCache] Cache cleared');
    } catch (e) {
      print('❌ [CourseCache] Error clearing cache: $e');
    }
  }
}
