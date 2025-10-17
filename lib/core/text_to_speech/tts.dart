import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      try {
        listener();
      } catch (e) {
        print('Error notifying listener: $e');
      }
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    try {
      List<String> vietnameseOptions = ["vi-VN", "vi", "vietnamese"];
      bool languageSet = false;

      for (String lang in vietnameseOptions) {
        try {
          await _flutterTts!.setLanguage(lang);
          languageSet = true;
          print('TTS: Successfully set language to $lang');
          break;
        } catch (e) {
          print('TTS: Failed to set language $lang: $e');
          continue;
        }
      }

      if (!languageSet) {
        await _flutterTts!.setLanguage("en-US");
        print('TTS: Fallback to English');
      }

      await _flutterTts!.setSpeechRate(0.45);
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.3);

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
        _notifyListeners();
      });

      _flutterTts!.setErrorHandler((message) {
        _isSpeaking = false;
        _notifyListeners();
        print('TTS Error: $message');
      });

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  Future<bool> isVietnameseSupported() async {
    if (!_isInitialized) await initialize();

    try {
      List<dynamic> languages = await _flutterTts!.getLanguages;
      return languages.any((lang) =>
      lang.toString().contains('vi') ||
          lang.toString().contains('VN') ||
          lang.toString().contains('Vietnamese'));
    } catch (e) {
      return false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (text.isEmpty) return;

    try {
      _isSpeaking = true;
      _notifyListeners();

      await _flutterTts!.speak(text);

      await Future.delayed(Duration(milliseconds: 100));
      await _flutterTts!.awaitSpeakCompletion(true);

      _isSpeaking = false;
      _notifyListeners();
    } catch (e) {
      print('Error speaking: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  Future<void> speakVietnameseQuestion(String question, List<String> options) async {
    if (!_isInitialized) await initialize();

    if (_isSpeaking) {
      print('TTS: Already speaking, skipping...');
      return;
    }

    await forceStop();
    await Future.delayed(Duration(milliseconds: 200));

    try {
      _isSpeaking = true;
      _notifyListeners();

      print('=== Vietnamese TTS Debug ===');
      print('Raw Question: "$question"');

      String processedQuestion = _preprocessVietnameseText(question);
      print('Processed Question: "$processedQuestion"');

      if (processedQuestion.isNotEmpty) {
        await _speakVietnameseTextSlowly("Câu hỏi: $processedQuestion");
      }

      if (!_isSpeaking) {
        print('TTS: Stopped during question reading');
        return;
      }

      final letters = ['A', 'B', 'C', 'D'];
      for (int i = 0; i < options.length && i < 4; i++) {
        if (!_isSpeaking) {
          print('TTS: Stopped during options reading');
          return;
        }

        if (options[i].isNotEmpty) {
          String processedOption = _preprocessVietnameseText(options[i]);
          print('Processed Option ${letters[i]}: "$processedOption"');

          if (processedOption.isNotEmpty) {
            await _speakVietnameseTextSlowly("${letters[i]} $processedOption");
          }
        }
      }

      print('=== End Debug ===');
      _isSpeaking = false;
      _notifyListeners();
    } catch (e) {
      print('Error speaking Vietnamese question: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  String _preprocessVietnameseText(String text) {
    String processed = text
        .replaceAll(RegExp(r'[^\w\s\.\,\?\!\:\;\(\)\-\+\=àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (!processed.endsWith('.') && !processed.endsWith('?') && !processed.endsWith('!')) {
      if (processed.toLowerCase().contains('bao nhiêu') ||
          processed.toLowerCase().contains('là gì') ||
          processed.toLowerCase().contains('như thế nào') ||
          processed.toLowerCase().startsWith('có') ||
          processed.toLowerCase().contains('phải không')) {
        processed += '?';
      } else {
        processed += '.';
      }
    }

    return processed;
  }

  Future<void> _speakVietnameseTextSlowly(String text) async {
    if (_flutterTts == null) return;

    await _flutterTts!.setSpeechRate(0.3);
    await _flutterTts!.setPitch(1.1);

    bool completed = false;
    _flutterTts!.setCompletionHandler(() {
      completed = true;
    });

    await _flutterTts!.speak(text);

    int timeoutCount = 0;
    int maxTimeout = text.length > 50 ? 200 : 100;

    while (!completed && timeoutCount < maxTimeout) {
      await Future.delayed(Duration(milliseconds: 100));
      timeoutCount++;
    }

    await Future.delayed(Duration(milliseconds: 800));

    await _flutterTts!.setSpeechRate(0.4);
    await _flutterTts!.setPitch(1.0);
  }

  Future<void> speakOption(String option, int index) async {
    if (!_isInitialized) await initialize();

    if (_isSpeaking) {
      await forceStop();
    }

    try {
      _isSpeaking = true;
      _notifyListeners();

      final letters = ['A', 'B', 'C', 'D'];
      String cleanOption = _preprocessVietnameseText(option);

      String text = "${letters[index]} $cleanOption";

      await _speakVietnameseTextSlowly(text);

      _isSpeaking = false;
      _notifyListeners();
    } catch (e) {
      print('Error speaking option: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  Future<void> speakCompletion(int correct, int total) async {
    if (!_isInitialized) await initialize();

    if (_isSpeaking) {
      await forceStop();
    }

    try {
      _isSpeaking = true;
      _notifyListeners();

      String text = "Chúc mừng! Bạn đã hoàn thành bài quiz với $correct câu đúng trên tổng $total câu hỏi.";
      await _speakVietnameseTextSlowly(text);

      _isSpeaking = false;
      _notifyListeners();
    } catch (e) {
      print('Error speaking completion: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  Future<void> forceStop() async {
    print('TTS: Force stopping...');

    _isSpeaking = false;
    _notifyListeners();

    if (_flutterTts != null) {
      try {
        await _flutterTts!.stop();
        await Future.delayed(Duration(milliseconds: 100));
        await _flutterTts!.stop();
        print('TTS: Force stopped successfully');
      } catch (e) {
        print('TTS: Error force stopping: $e');
      }
    }
  }

  Future<void> stop() async {
    await forceStop();
  }

  Future<void> playSuccessSound() async {
    if (!_isInitialized) await initialize();

    try {
      _isSpeaking = true;
      _notifyListeners();

      await _flutterTts!.setSpeechRate(1.2);
      await _flutterTts!.setPitch(1.5);
      await _flutterTts!.setVolume(1.0);

      await _flutterTts!.speak("Đúng");

      Future.delayed(Duration(milliseconds: 1000), () {
        _isSpeaking = false;
        _notifyListeners();
      });
    } catch (e) {
      print('Error playing success sound: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  Future<void> playErrorSound() async {
    if (!_isInitialized) await initialize();

    try {
      _isSpeaking = true;
      _notifyListeners();

      await _flutterTts!.setSpeechRate(1.0);
      await _flutterTts!.setPitch(0.7);
      await _flutterTts!.setVolume(1.0);

      await _flutterTts!.speak("Sai");

      Future.delayed(Duration(milliseconds: 1000), () {
        _isSpeaking = false;
        _notifyListeners();
      });
    } catch (e) {
      print('Error playing error sound: $e');
      _isSpeaking = false;
      _notifyListeners();
    }
  }

  bool get isSpeaking => _isSpeaking;

  void dispose() {
    _flutterTts?.stop();
    _flutterTts = null;
    _isInitialized = false;
    _isSpeaking = false;
    _listeners.clear();
  }

  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) await initialize();
    try {
      await _flutterTts!.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (!_isInitialized) await initialize();
    try {
      await _flutterTts!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) await initialize();
    try {
      await _flutterTts!.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      print('Error setting pitch: $e');
    }
  }
}