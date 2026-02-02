import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/workout_record.dart';
import '../models/personal_record.dart';

/// 클라우드 동기화 서비스
class CloudSyncService {
  late final String _baseUrl;

  final http.Client _client;

  CloudSyncService() : _client = http.Client() {
    _baseUrl = _getBaseUrl();
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      // 웹에서는 현재 접속한 주소를 기반으로 API URL 생성
      return '${Uri.base.origin}/api';
    }
    // 모바일 앱에서는 서버 주소 직접 지정 (필요시 수정)
    return 'http://localhost:9000/api';
  }

  /// 닉네임 존재 확인
  Future<bool> checkNicknameExists(String nickname) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/check?nickname=${Uri.encodeComponent(nickname)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('닉네임 확인 오류: $e');
      return false;
    }
  }

  /// 사용자 생성
  Future<bool> createUser(String nickname) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nickname': nickname}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('사용자 생성 오류: $e');
      return false;
    }
  }

  /// 사용자 데이터 조회
  Future<Map<String, dynamic>?> getUserData(String nickname) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/user?nickname=${Uri.encodeComponent(nickname)}'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('사용자 데이터 조회 오류: $e');
      return null;
    }
  }

  /// 운동 기록 동기화
  Future<List<Map<String, dynamic>>?> syncWorkoutRecords(
    String nickname,
    List<WorkoutRecord> records,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/sync/workouts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nickname': nickname,
          'records': records.map((r) => r.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['records'] ?? []);
      }
      return null;
    } catch (e) {
      debugPrint('운동 기록 동기화 오류: $e');
      return null;
    }
  }

  /// PR 동기화
  Future<List<Map<String, dynamic>>?> syncPersonalRecords(
    String nickname,
    List<PersonalRecord> records,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/sync/pr'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nickname': nickname,
          'records': records.map((r) => r.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['records'] ?? []);
      }
      return null;
    } catch (e) {
      debugPrint('PR 동기화 오류: $e');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
