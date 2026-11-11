import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ThaiTtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static const MethodChannel _nativeChannel =
      MethodChannel('com.stepbystep.thai/native_tts');
  static bool isThaiAvailable = false;
  static String statusMessage = '正在檢測本機泰語 (th-TH) 語音引擎...';

  static Future<void> init() async {
    try {
      final available = await _flutterTts.isLanguageAvailable("th-TH");
      if (available == true) {
        await _flutterTts.setLanguage("th-TH");
        await _flutterTts.setPitch(1.0);
        isThaiAvailable = true;
        statusMessage = '✅ 本機泰語 TTS (th-TH) 已就緒。';
      } else {
        final nativeOk = await _nativeChannel
                .invokeMethod<bool>('isThaiVoiceAvailable') ??
            false;
        isThaiAvailable = nativeOk;
      }
    } catch (_) {
      isThaiAvailable = false;
    }
  }

  static Future<bool> speak(String text,
      {bool slow = false, double baseRate = 0.8}) async {
    if (!isThaiAvailable) {
      await init();
      if (!isThaiAvailable) return false;
    }
    final rate = slow ? 0.52 : baseRate;
    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(text);
    return true;
  }
}
