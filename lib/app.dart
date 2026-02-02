import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/pr_screen.dart';
import 'presentation/screens/nickname_screen.dart';
import 'providers/wod_provider.dart';
import 'providers/user_provider.dart';

/// 메인 앱 위젯
class CrossFitWodApp extends StatelessWidget {
  const CrossFitWodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const _AppRoot(),
    );
  }
}

/// 앱 루트 (닉네임 확인)
class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkNickname();
  }

  void _checkNickname() {
    ref.read(userNotifierProvider);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);

    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 닉네임이 없으면 닉네임 화면 표시
    if (userState.value == null) {
      return NicknameScreen(
        onComplete: () => setState(() {}),
      );
    }

    return const MainScreen();
  }
}

/// 메인 화면 (바텀 네비게이션 포함)
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    PrScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final nickname = userState.value;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return _buildDesktopLayout(nickname);
    }

    return _buildMobileLayout(nickname);
  }

  Widget _buildMobileLayout(String? nickname) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 닉네임 & 동기화 바
          if (nickname != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.secondaryLight.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    nickname,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _SyncButton(),
                  const SizedBox(width: 8),
                  _LogoutButton(),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => _onNavTap(index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: AppStrings.home,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: AppStrings.history,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events),
                  label: AppStrings.pr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onNavTap(int index) async {
    // 홈 탭을 클릭했고, 현재 홈이 아니며, WOD가 생성되어 있는 경우
    if (index == 0 && _currentIndex != 0) {
      final currentWod = ref.read(currentWodProvider).wod;
      if (currentWod != null) {
        final shouldDiscard = await _showDiscardWodDialog();
        if (shouldDiscard == true) {
          ref.read(currentWodProvider.notifier).clearWod();
          setState(() => _currentIndex = index);
        }
        return;
      }
    }

    // 다른 탭으로 이동할 때도 WOD가 있으면 확인
    if (index != 0 && _currentIndex == 0) {
      final currentWod = ref.read(currentWodProvider).wod;
      if (currentWod != null) {
        final shouldDiscard = await _showDiscardWodDialog();
        if (shouldDiscard != true) {
          return;
        }
        ref.read(currentWodProvider.notifier).clearWod();
      }
    }

    setState(() => _currentIndex = index);
  }

  Future<bool?> _showDiscardWodDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Text(
              '진행 중인 WOD',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '생성된 WOD가 있습니다.\n삭제하고 메인 화면으로 이동하시겠습니까?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('삭제하고 이동'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(String? nickname) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드 네비게이션
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => _onNavTap(index),
            backgroundColor: AppColors.surface,
            extended: MediaQuery.of(context).size.width > 1200,
            minWidth: 72,
            minExtendedWidth: 200,
            labelType: NavigationRailLabelType.none,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (nickname != null)
                    Text(
                      nickname,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  _SyncButton(),
                  const SizedBox(height: 8),
                  _LogoutButton(),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: Text(AppStrings.home),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history, color: AppColors.primary),
                label: Text(AppStrings.history),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events, color: AppColors.primary),
                label: Text(AppStrings.pr),
              ),
            ],
          ),

          const VerticalDivider(width: 1, color: AppColors.secondaryLight),

          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}

/// 동기화 버튼
class _SyncButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<_SyncButton> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    setState(() => _isSyncing = true);

    try {
      await ref.read(userNotifierProvider.notifier).syncToServer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동기화 완료'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isSyncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : const Icon(Icons.cloud_sync, color: AppColors.primary, size: 20),
      onPressed: _isSyncing ? null : _sync,
      tooltip: '동기화',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

/// 로그아웃 버튼
class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 20),
      onPressed: () => _showLogoutDialog(context, ref),
      tooltip: '로그아웃',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '로그아웃',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '로그아웃하시겠습니까?\n다른 닉네임으로 로그인할 수 있습니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userNotifierProvider.notifier).logout();
            },
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
