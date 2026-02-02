import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/wod.dart';
import '../../providers/wod_provider.dart';
import '../../providers/workout_history_provider.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/wod_card.dart';
import 'wod_screen.dart';

/// 홈 화면
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentWodState = ref.watch(currentWodProvider);
    final stats = ref.watch(workoutStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 앱 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appTitle,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '오늘의 운동을 시작하세요!',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // 통계 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${stats.currentStreak}일 연속',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 통계 카드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StatsRow(stats: stats),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // WOD 타입 선택
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WodTypeSelector(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 난이도 선택
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DifficultySelector(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 홈트레이닝 모드 토글
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _HomeTrainingToggle(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 생성 모드 선택 (자동/수동)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GenerationModeSelector(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // WOD 생성 버튼
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: currentWodState.isLoading
                        ? null
                        : () => _generateWod(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: currentWodState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shuffle, size: 24),
                              SizedBox(width: 12),
                              Text(
                                AppStrings.generateWod,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 생성된 WOD 표시
            if (currentWodState.wod != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: WodCard(
                    wod: currentWodState.wod!,
                    onStart: () => _startWorkout(context, currentWodState.wod!),
                    onTap: () => _viewWodDetail(context, currentWodState.wod!),
                  ),
                ),
              ),

            // 에러 표시
            if (currentWodState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentWodState.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Future<void> _generateWod(BuildContext context, WidgetRef ref) async {
    await ref.read(currentWodProvider.notifier).generateWod();
  }

  void _startWorkout(BuildContext context, Wod wod) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WodScreen(wod: wod),
      ),
    );
  }

  void _viewWodDetail(BuildContext context, Wod wod) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WodScreen(wod: wod),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WorkoutStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '이번 주',
            value: '${stats.thisWeekWorkouts}',
            icon: Icons.calendar_today,
            color: AppColors.emom,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: '이번 달',
            value: '${stats.thisMonthWorkouts}',
            icon: Icons.calendar_month,
            color: AppColors.amrap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: '총 운동',
            value: '${stats.totalWorkouts}',
            icon: Icons.fitness_center,
            color: AppColors.forTime,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WodTypeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedWodTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'WOD 타입',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _WodTypeChip(
                label: '랜덤',
                isSelected: selectedType == null,
                color: AppColors.primary,
                onTap: () {
                  ref.read(selectedWodTypeProvider.notifier).state = null;
                },
              ),
              ...WodType.values.map((type) {
                return _WodTypeChip(
                  label: type.displayName,
                  isSelected: selectedType == type,
                  color: Color(type.colorValue),
                  onTap: () {
                    ref.read(selectedWodTypeProvider.notifier).state = type;
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _WodTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _WodTypeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.secondaryLight,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// WodType colorValue extension은 wod_provider.dart에 정의됨

class _HomeTrainingToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHomeTraining = ref.watch(homeTrainingModeProvider);

    return GestureDetector(
      onTap: () {
        ref.read(homeTrainingModeProvider.notifier).state = !isHomeTraining;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHomeTraining
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHomeTraining ? AppColors.success : AppColors.secondaryLight,
            width: isHomeTraining ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isHomeTraining
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.home,
                color: isHomeTraining ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '홈트레이닝 모드',
                    style: TextStyle(
                      color: isHomeTraining
                          ? AppColors.success
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '장비 없이 맨몸으로 할 수 있는 운동만',
                    style: TextStyle(
                      color: isHomeTraining
                          ? AppColors.success.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isHomeTraining,
              onChanged: (value) {
                ref.read(homeTrainingModeProvider.notifier).state = value;
              },
              activeTrackColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerationModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generationMode = ref.watch(generationModeProvider);
    final exerciseCount = ref.watch(manualExerciseCountProvider);
    final isManual = generationMode == GenerationMode.manual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '생성 방식',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _GenerationModeChip(
                label: '자동',
                subtitle: '4개 랜덤',
                icon: Icons.auto_awesome,
                isSelected: !isManual,
                color: AppColors.primary,
                onTap: () {
                  ref.read(generationModeProvider.notifier).state = GenerationMode.auto;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenerationModeChip(
                label: '수동',
                subtitle: '$exerciseCount개 선택',
                icon: Icons.tune,
                isSelected: isManual,
                color: AppColors.warning,
                onTap: () {
                  ref.read(generationModeProvider.notifier).state = GenerationMode.manual;
                },
              ),
            ),
          ],
        ),
        // 수동 모드일 때 운동 갯수 선택
        if (isManual) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '운동 갯수',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$exerciseCount개',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(8, (index) {
                    final count = index + 1;
                    final isSelected = exerciseCount == count;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(manualExerciseCountProvider.notifier).state = count;
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: index < 7 ? 4 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.warning
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.warning
                                  : AppColors.secondaryLight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GenerationModeChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GenerationModeChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.secondaryLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.2) : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? color.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
