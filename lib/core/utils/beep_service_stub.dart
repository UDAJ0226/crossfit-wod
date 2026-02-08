import 'beep_service_interface.dart';

/// 모바일용 비프 서비스 (햅틱 피드백만 사용)
class BeepServiceStub implements BeepServiceInterface {
  @override
  Future<void> init() async {}

  @override
  Future<void> resumeAudioContext() async {}

  @override
  void playBeep() {
    // 모바일에서는 HapticFeedback만 사용 (메인 서비스에서 처리)
  }

  @override
  void playHighBeep() {}

  @override
  void playLowBeep() {}

  @override
  void playFinish() {}

  @override
  void speak(String text) {
    // 모바일에서는 TTS 미지원 (필요시 flutter_tts 패키지 추가)
  }
}

BeepServiceInterface createBeepService() => BeepServiceStub();
