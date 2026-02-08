import 'package:flutter/services.dart';
import 'beep_service_interface.dart';
import 'beep_service_stub.dart'
    if (dart.library.html) 'beep_service_web.dart' as impl;

/// 비프음 서비스 (웹/모바일 호환)
class BeepService {
  static final BeepService _instance = BeepService._();
  static BeepService get instance => _instance;

  BeepService._();

  final BeepServiceInterface _impl = impl.createBeepService();

  /// 초기화
  Future<void> init() async {
    await _impl.init();
  }

  /// AudioContext resume (사용자 인터랙션 후 호출)
  Future<void> resumeAudioContext() async {
    await _impl.resumeAudioContext();
  }

  /// 짧은 비프음 (카운트다운) - 800Hz
  void playBeep() {
    HapticFeedback.mediumImpact();
    _impl.playBeep();
  }

  /// 높은 비프음 (시작) - 1400Hz
  void playHighBeep() {
    HapticFeedback.heavyImpact();
    _impl.playHighBeep();
  }

  /// 낮은 비프음 (휴식 시작) - 600Hz
  void playLowBeep() {
    HapticFeedback.lightImpact();
    _impl.playLowBeep();
  }

  /// 완료 사운드
  void playFinish() {
    HapticFeedback.heavyImpact();
    _impl.playFinish();
  }

  /// 운동 종목 음성 안내
  void speak(String text) {
    _impl.speak(text);
  }
}
