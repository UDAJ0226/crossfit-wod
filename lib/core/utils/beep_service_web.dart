import 'package:flutter/foundation.dart';
import 'package:web/web.dart';
import 'beep_service_interface.dart';

/// 웹용 비프 서비스 (Web Audio API 사용)
class BeepServiceWeb implements BeepServiceInterface {
  AudioContext? _audioContext;

  @override
  Future<void> init() async {
    try {
      _audioContext ??= AudioContext();
    } catch (e) {
      debugPrint('AudioContext init error: $e');
    }
  }

  @override
  Future<void> resumeAudioContext() async {
    if (_audioContext == null) return;
    try {
      if (_audioContext!.state == 'suspended') {
        _audioContext!.resume();
      }
    } catch (e) {
      debugPrint('AudioContext resume error: $e');
    }
  }

  @override
  void playBeep() {
    _playWebBeep(800, 0.15, 0.3);
  }

  @override
  void playHighBeep() {
    _playWebBeep(1400, 0.25, 0.4);
  }

  @override
  void playLowBeep() {
    _playWebBeep(600, 0.25, 0.35);
  }

  @override
  void playFinish() {
    _playWebBeep(880, 0.12, 0.4);
    Future.delayed(const Duration(milliseconds: 150), () {
      _playWebBeep(1100, 0.12, 0.4);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _playWebBeep(1400, 0.3, 0.5);
    });
  }

  void _playWebBeep(int frequency, double duration, double volume) {
    try {
      _audioContext ??= AudioContext();
      final ctx = _audioContext!;

      if (ctx.state == 'suspended') {
        ctx.resume();
      }

      final oscillator = ctx.createOscillator();
      final gainNode = ctx.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(ctx.destination);

      oscillator.frequency.value = frequency.toDouble();
      oscillator.type = 'sine';

      final currentTime = ctx.currentTime;
      gainNode.gain.setValueAtTime(volume, currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, currentTime + duration);

      oscillator.start(currentTime);
      oscillator.stop(currentTime + duration);
    } catch (e) {
      debugPrint('Beep error: $e');
      try {
        _audioContext = AudioContext();
      } catch (_) {}
    }
  }

  @override
  void speak(String text) {
    try {
      final synthesis = window.speechSynthesis;
      // 이전 음성 취소
      synthesis.cancel();

      final utterance = SpeechSynthesisUtterance(text);
      // web 패키지에서는 setter 사용
      utterance.lang = 'ko-KR';
      utterance.rate = 1.0;
      utterance.volume = 1.0;

      synthesis.speak(utterance);
      debugPrint('TTS speaking: $text');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }
}

BeepServiceInterface createBeepService() => BeepServiceWeb();
