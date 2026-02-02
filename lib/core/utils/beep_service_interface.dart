/// 비프 서비스 인터페이스
abstract class BeepServiceInterface {
  Future<void> init();
  Future<void> resumeAudioContext();
  void playBeep();
  void playHighBeep();
  void playLowBeep();
  void playFinish();
}
