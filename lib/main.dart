import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/local_storage.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/services/cloud_sync_service.dart';
import 'core/constants/app_colors.dart';

// 현재 데이터 버전 (운동 데이터 변경 시 증가)
const int currentDataVersion = 5;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E1E1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 스플래시 화면 먼저 표시
  runApp(const _SplashApp());

  // 백그라운드에서 초기화 진행
  await _initializeApp();

  // 메인 앱으로 전환
  runApp(
    const ProviderScope(
      child: CrossFitWodApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  // 화면 방향 설정과 스토리지 초기화 병렬 처리
  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]),
    LocalStorage.instance.init(),
  ]);

  // 서버 헬스체크 (콜드 스타트 시 웜업)
  final cloudSyncService = CloudSyncService();

  // 서버가 슬립 상태일 수 있으므로 백그라운드에서 웜업 시도
  cloudSyncService.healthCheck().then((healthy) {
    if (healthy) {
      debugPrint('✓ 서버 연결 성공');
    } else {
      debugPrint('✗ 서버 연결 실패 (오프라인 모드)');
    }
  }).catchError((e) {
    debugPrint('서버 헬스체크 오류: $e');
  });

  // 버전 확인 후 필요시에만 운동 데이터 갱신
  final exerciseRepository = ExerciseRepository(LocalStorage.instance);
  final storedVersion = LocalStorage.instance.dataVersion;

  if (storedVersion < currentDataVersion) {
    await exerciseRepository.resetExercises();
    await LocalStorage.instance.setDataVersion(currentDataVersion);
  } else if (!exerciseRepository.hasExercises()) {
    await exerciseRepository.loadInitialExercises();
  }

  // 최소 로딩 시간 보장
  await Future.delayed(const Duration(milliseconds: 500));
}

/// 스플래시 화면 앱
class _SplashApp extends StatelessWidget {
  const _SplashApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              // 앱 이름
              const Text(
                'CrossFit WOD',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              // 로딩 인디케이터
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 로딩 메시지
              const Text(
                '서버 연결 중...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '첫 접속 시 30초 정도 소요될 수 있습니다',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
