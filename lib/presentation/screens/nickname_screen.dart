import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';

/// 닉네임 입력/선택 화면
class NicknameScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const NicknameScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends ConsumerState<NicknameScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastNickname;

  @override
  void initState() {
    super.initState();
    // 마지막 로그인 닉네임 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nickname = ref.read(lastLoginNicknameProvider);
      if (nickname != null && nickname.isNotEmpty) {
        setState(() => _lastNickname = nickname);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loginWithNickname(String nickname) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(userNotifierProvider.notifier).loginOrRegister(nickname);

      if (success) {
        widget.onComplete();
      } else {
        setState(() => _errorMessage = '연결에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      setState(() => _errorMessage = '오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();

    if (nickname.isEmpty) {
      setState(() => _errorMessage = '닉네임을 입력해주세요');
      return;
    }

    if (nickname.length < 2) {
      setState(() => _errorMessage = '닉네임은 2자 이상이어야 합니다');
      return;
    }

    if (nickname.length > 20) {
      setState(() => _errorMessage = '닉네임은 20자 이하여야 합니다');
      return;
    }

    await _loginWithNickname(nickname);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
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
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              // 타이틀
              const Text(
                'CrossFit WOD',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '닉네임을 입력하여 시작하세요',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 48),

              // 닉네임 입력
              TextField(
                controller: _controller,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // 마지막 로그인 닉네임으로 빠른 로그인
              if (_lastNickname != null && _lastNickname!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _loginWithNickname(_lastNickname!),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '"$_lastNickname" 으로 계속하기',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 안내 문구
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.cloud_sync,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '닉네임으로 기록이 저장되어\n다른 기기에서도 동기화됩니다',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
