import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/datasources/local_storage.dart';
import 'data/repositories/exercise_repository.dart';
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

  // 버전 확인 후 필요시에만 운동 데이터 갱신
  final exerciseRepository = ExerciseRepository(LocalStorage.instance);
  final storedVersion = LocalStorage.instance.dataVersion;

  if (storedVersion < currentDataVersion) {
    await exerciseRepository.resetExercises();
    await LocalStorage.instance.setDataVersion(currentDataVersion);
  } else if (!exerciseRepository.hasExercises()) {
    await exerciseRepository.loadInitialExercises();
  }
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
            ],
          ),
        ),
      ),
    );
  }
}
