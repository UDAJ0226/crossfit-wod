import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/workout_record.dart';
import '../models/personal_record.dart';

/// 클라우드 동기화 서비스
class CloudSyncService {
  late final String _baseUrl;

  final http.Client _client;

  // 타임아웃 설정 (서버 콜드 스타트 대응)
  static const Duration _requestTimeout = Duration(seconds: 60);
  static const int _maxRetries = 3;

  CloudSyncService() : _client = http.Client() {
    _baseUrl = _getBaseUrl();
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      // 웹에서는 현재 접속한 주소를 기반으로 API URL 생성
      return '${Uri.base.origin}/api';
    }
    // 모바일 앱에서는 Render 서버 사용
    return 'https://crossfit-wod.onrender.com/api';
  }

  /// 헬스체크 - 서버 상태 확인 및 웜업
  Future<bool> healthCheck() async {
    try {
      final healthUrl = kIsWeb
          ? '${Uri.base.origin}/health'
          : 'https://crossfit-wod.onrender.com/health';

      final response = await _client
          .get(Uri.parse(healthUrl))
          .timeout(_requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('헬스체크 오류: $e');
      return false;
    }
  }

  /// 재시도 로직을 포함한 HTTP 요청
  Future<T?> _retryRequest<T>(
    Future<T> Function() request, {
    String errorContext = '요청',
  }) async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        return await request();
      } catch (e) {
        debugPrint('$errorContext 시도 ${i + 1}/$_maxRetries 실패: $e');

        if (i == _maxRetries - 1) {
          debugPrint('$errorContext 최종 실패');
          return null;
        }

        // 재시도 전 대기 (exponential backoff)
        await Future.delayed(Duration(seconds: 2 * (i + 1)));
      }
    }
    return null;
  }

  /// 닉네임 존재 확인
  Future<bool> checkNicknameExists(String nickname) async {
    return await _retryRequest<bool>(
          () async {
        final response = await _client
            .get(
          Uri.parse('$_baseUrl/check?nickname=${Uri.encodeComponent(nickname)}'),
        )
            .timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['exists'] == true;
        }
        return false;
      },
      errorContext: '닉네임 확인',
    ) ??
        false;
  }

  /// 사용자 생성
  Future<bool> createUser(String nickname) async {
    return await _retryRequest<bool>(
          () async {
        final response = await _client
            .post(
          Uri.parse('$_baseUrl/user'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'nickname': nickname}),
        )
            .timeout(_requestTimeout);

        return response.statusCode == 200;
      },
      errorContext: '사용자 생성',
    ) ??
        false;
  }

  /// 사용자 데이터 조회
  Future<Map<String, dynamic>?> getUserData(String nickname) async {
    return await _retryRequest<Map<String, dynamic>?>(
      () async {
        final response = await _client
            .get(
          Uri.parse('$_baseUrl/user?nickname=${Uri.encodeComponent(nickname)}'),
        )
            .timeout(_requestTimeout);

        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
        return null;
      },
      errorContext: '사용자 데이터 조회',
    );
  }

  /// 운동 기록 동기화
  Future<List<Map<String, dynamic>>?> syncWorkoutRecords(
    String nickname,
    List<WorkoutRecord> records,
  ) async {
    return await _retryRequest<List<Map<String, dynamic>>?>(
      () async {
        final response = await _client
            .post(
          Uri.parse('$_baseUrl/sync/workouts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nickname': nickname,
            'records': records.map((r) => r.toJson()).toList(),
          }),
        )
            .timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return List<Map<String, dynamic>>.from(data['records'] ?? []);
        }
        return null;
      },
      errorContext: '운동 기록 동기화',
    );
  }

  /// PR 동기화
  Future<List<Map<String, dynamic>>?> syncPersonalRecords(
    String nickname,
    List<PersonalRecord> records,
  ) async {
    return await _retryRequest<List<Map<String, dynamic>>?>(
      () async {
        final response = await _client
            .post(
          Uri.parse('$_baseUrl/sync/pr'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nickname': nickname,
            'records': records.map((r) => r.toJson()).toList(),
          }),
        )
            .timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return List<Map<String, dynamic>>.from(data['records'] ?? []);
        }
        return null;
      },
      errorContext: 'PR 동기화',
    );
  }

  void dispose() {
    _client.close();
  }
}
