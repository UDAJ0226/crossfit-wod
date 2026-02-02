import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/exercise.dart';

/// 운동 동작 설명 화면
class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  Color get _categoryColor {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return AppColors.amrap;
      case ExerciseCategory.weightlifting:
        return AppColors.forTime;
      case ExerciseCategory.cardio:
        return AppColors.emom;
      case ExerciseCategory.monostructural:
        return AppColors.tabata;
    }
  }

  String get _categoryLabel {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return '체조';
      case ExerciseCategory.weightlifting:
        return '역도';
      case ExerciseCategory.cardio:
        return '유산소';
      case ExerciseCategory.monostructural:
        return '단일구조';
    }
  }

  IconData get _categoryIcon {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return Icons.accessibility_new;
      case ExerciseCategory.weightlifting:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      case ExerciseCategory.monostructural:
        return Icons.repeat;
    }
  }

  String get _difficultyLabel {
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        return '초급';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '고급';
    }
  }

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        return AppColors.beginner;
      case Difficulty.intermediate:
        return AppColors.intermediate;
      case Difficulty.advanced:
        return AppColors.advanced;
    }
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _categoryColor.withValues(alpha: 0.4),
            _categoryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: _AnimatedExerciseIcon(
          icon: _categoryIcon,
          color: _categoryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exercise.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: _buildBackground(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 태그
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Tag(
                        label: _categoryLabel,
                        color: _categoryColor,
                        icon: _categoryIcon,
                      ),
                      _Tag(
                        label: _difficultyLabel,
                        color: _difficultyColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 동작 설명
                  const _SectionHeader(title: '동작 설명', icon: Icons.description),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 필요 장비
                  if (exercise.equipment.isNotEmpty) ...[
                    const _SectionHeader(title: '필요 장비', icon: Icons.handyman),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: exercise.equipment
                          .map((e) => _EquipmentChip(label: e))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 운동 팁
                  const _SectionHeader(title: '운동 팁', icon: Icons.lightbulb),
                  const SizedBox(height: 12),
                  _buildTips(),

                  const SizedBox(height: 24),

                  // 스케일링 옵션
                  const _SectionHeader(title: '스케일링 옵션', icon: Icons.tune),
                  const SizedBox(height: 12),
                  _buildScalingOptions(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    final tips = _getTipsForExercise();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  List<String> _getTipsForExercise() {
    switch (exercise.category) {
      case ExerciseCategory.gymnastics:
        return [
          '정확한 동작 범위를 유지하세요',
          '속도보다 자세가 중요합니다',
          '호흡을 일정하게 유지하세요',
          '피로해지면 잠시 쉬고 다시 시작하세요',
        ];
      case ExerciseCategory.weightlifting:
        return [
          '적절한 무게로 시작하세요',
          '코어를 단단히 유지하세요',
          '등을 곧게 펴고 자세를 유지하세요',
          '무게를 올리기 전에 자세를 완벽히 익히세요',
        ];
      case ExerciseCategory.cardio:
        return [
          '일정한 페이스를 유지하세요',
          '호흡 리듬을 찾으세요',
          '워밍업을 충분히 하세요',
          '수분 섭취를 잊지 마세요',
        ];
      case ExerciseCategory.monostructural:
        return [
          '효율적인 움직임에 집중하세요',
          '지구력을 기르는 것이 목표입니다',
          '꾸준한 페이스가 중요합니다',
          '회복 시간을 충분히 가지세요',
        ];
    }
  }

  Widget _buildScalingOptions() {
    final options = _getScalingOptions();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: options.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(entry.key).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: _getDifficultyColor(entry.key),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case '초급':
        return AppColors.beginner;
      case '중급':
        return AppColors.intermediate;
      case '고급':
        return AppColors.advanced;
      default:
        return AppColors.textSecondary;
    }
  }

  Map<String, String> _getScalingOptions() {
    switch (exercise.id) {
      case 'pull_up':
        return {
          '초급': '밴드 풀업 또는 링 로우',
          '중급': '키핑 풀업',
          '고급': '스트릭트 풀업 또는 웨이티드 풀업',
        };
      case 'muscle_up':
        return {
          '초급': '풀업 + 딥 따로 수행',
          '중급': '바 머슬업 또는 밴드 보조',
          '고급': '스트릭트 머슬업',
        };
      case 'handstand_push_up':
        return {
          '초급': '파이크 푸시업',
          '중급': '박스 핸드스탠드 푸시업',
          '고급': '스트릭트 또는 키핑 HSPU',
        };
      case 'double_under':
        return {
          '초급': '싱글언더 3배',
          '중급': '더블언더 연습 (실패해도 OK)',
          '고급': '트리플 언더',
        };
      case 'snatch':
        return {
          '초급': '덤벨 스내치 또는 파워 스내치',
          '중급': '풀 스내치 (가벼운 무게)',
          '고급': '풀 스쿼트 스내치',
        };
      default:
        return {
          '초급': '횟수 줄이기 또는 변형 동작',
          '중급': '처방된 대로 수행',
          '고급': '횟수 늘리기 또는 무게 추가',
        };
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Tag({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentChip extends StatelessWidget {
  final String label;

  const _EquipmentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fitness_center,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// 애니메이션 운동 아이콘
class _AnimatedExerciseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _AnimatedExerciseIcon({
    required this.icon,
    required this.color,
  });

  @override
  State<_AnimatedExerciseIcon> createState() => _AnimatedExerciseIconState();
}

class _AnimatedExerciseIconState extends State<_AnimatedExerciseIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 80,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
