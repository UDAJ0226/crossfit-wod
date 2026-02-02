import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/local_storage.dart';
import '../data/services/cloud_sync_service.dart';
import '../data/models/workout_record.dart';
import '../data/models/personal_record.dart';

/// 현재 사용자 닉네임 Provider
final currentNicknameProvider = StateProvider<String?>((ref) {
  final localStorage = LocalStorage.instance;
  return localStorage.getSetting<String>('nickname');
});

/// 클라우드 동기화 서비스 Provider
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService();
});

/// 사용자 관리 Notifier
class UserNotifier extends StateNotifier<AsyncValue<String?>> {
  final LocalStorage _localStorage;
  final CloudSyncService _syncService;

  UserNotifier(this._localStorage, this._syncService)
      : super(AsyncValue.data(_localStorage.getSetting<String>('nickname')));

  /// 닉네임으로 로그인/가입
  Future<bool> loginOrRegister(String nickname) async {
    state = const AsyncValue.loading();

    try {
      // 닉네임 존재 확인
      final exists = await _syncService.checkNicknameExists(nickname);

      if (!exists) {
        // 새 사용자 생성
        final created = await _syncService.createUser(nickname);
        if (!created) {
          state = AsyncValue.error('사용자 생성 실패', StackTrace.current);
          return false;
        }
      }

      // 로컬에 닉네임 저장
      await _localStorage.saveSetting('nickname', nickname);

      // 서버에서 데이터 가져오기
      await syncFromServer(nickname);

      state = AsyncValue.data(nickname);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 서버에서 데이터 동기화
  Future<void> syncFromServer(String nickname) async {
    try {
      final userData = await _syncService.getUserData(nickname);
      if (userData == null) return;

      // 운동 기록 동기화
      final workoutRecords = userData['workoutRecords'] as List<dynamic>?;
      if (workoutRecords != null && workoutRecords.isNotEmpty) {
        for (final recordJson in workoutRecords) {
          try {
            final record = WorkoutRecord.fromJson(
              Map<String, dynamic>.from(recordJson),
            );
            await _localStorage.saveWorkoutRecord(record);
          } catch (e) {
            debugPrint('운동 기록 파싱 오류: $e');
          }
        }
      }

      // PR 동기화
      final prRecords = userData['personalRecords'] as List<dynamic>?;
      if (prRecords != null && prRecords.isNotEmpty) {
        for (final recordJson in prRecords) {
          try {
            final record = PersonalRecord.fromJson(
              Map<String, dynamic>.from(recordJson),
            );
            await _localStorage.savePersonalRecord(record);
          } catch (e) {
            debugPrint('PR 파싱 오류: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('서버 동기화 오류: $e');
    }
  }

  /// 서버로 데이터 업로드
  Future<void> syncToServer() async {
    final nickname = state.value;
    if (nickname == null) return;

    try {
      // 운동 기록 업로드
      final workoutRecords = _localStorage.getAllWorkoutRecords();
      await _syncService.syncWorkoutRecords(nickname, workoutRecords);

      // PR 업로드
      final prRecords = _localStorage.getAllPersonalRecords();
      await _syncService.syncPersonalRecords(nickname, prRecords);
    } catch (e) {
      debugPrint('서버 업로드 오류: $e');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _localStorage.saveSetting('nickname', null);
    state = const AsyncValue.data(null);
  }

  /// 현재 닉네임
  String? get currentNickname => state.value;
}

/// 사용자 관리 Provider
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<String?>>((ref) {
  final localStorage = LocalStorage.instance;
  final syncService = ref.watch(cloudSyncServiceProvider);
  return UserNotifier(localStorage, syncService);
});
