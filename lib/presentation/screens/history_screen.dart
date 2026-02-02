import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/workout_record.dart';
import '../../data/models/wod.dart';
import '../../providers/workout_history_provider.dart';

/// 운동 기록 화면
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final records = ref.watch(workoutHistoryProvider);
    final stats = ref.watch(workoutStatsProvider);
    final workoutDates = ref.watch(currentMonthWorkoutDatesProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('운동 기록'),
      ),
      body: CustomScrollView(
        slivers: [
          // 통계 요약
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _StatsSummary(stats: stats),
            ),
          ),

          // 캘린더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _MonthCalendar(
                selectedDate: selectedDate,
                workoutDates: workoutDates,
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
                onMonthChanged: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 선택된 날짜의 기록
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${selectedDate.month}월 ${selectedDate.day}일 기록',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 기록 목록
          Consumer(
            builder: (context, ref, child) {
              final selectedRecords = ref.watch(selectedDateWorkoutsProvider);

              if (selectedRecords.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '이 날의 기록이 없습니다',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: _WorkoutRecordCard(
                        record: selectedRecords[index],
                        onDelete: () => _deleteRecord(selectedRecords[index]),
                      ),
                    );
                  },
                  childCount: selectedRecords.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // 전체 기록 헤더
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '전체 기록',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 전체 기록 목록
          if (records.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    '아직 기록이 없습니다',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: _WorkoutRecordCard(
                      record: records[index],
                      onDelete: () => _deleteRecord(records[index]),
                    ),
                  );
                },
                childCount: records.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _deleteRecord(WorkoutRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          '기록 삭제',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '이 기록을 삭제하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(workoutHistoryNotifierProvider.notifier)
          .deleteWorkoutRecord(record.id);
    }
  }
}

class _StatsSummary extends StatelessWidget {
  final WorkoutStats stats;

  const _StatsSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: '연속',
            value: '${stats.currentStreak}일',
            icon: Icons.local_fire_department,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          _StatItem(
            label: '이번 주',
            value: '${stats.thisWeekWorkouts}회',
            icon: Icons.calendar_today,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          _StatItem(
            label: '총 운동',
            value: '${stats.totalWorkouts}회',
            icon: Icons.fitness_center,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Set<DateTime> workoutDates;
  final void Function(DateTime) onDateSelected;
  final void Function(DateTime) onMonthChanged;

  const _MonthCalendar({
    required this.selectedDate,
    required this.workoutDates,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 일요일 = 0

    final days = <DateTime?>[];

    // 이전 달의 빈 칸
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // 이번 달의 날짜
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(selectedDate.year, selectedDate.month, i));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                onPressed: () {
                  onMonthChanged(DateTime(selectedDate.year, selectedDate.month - 1, 1));
                },
              ),
              Text(
                '${selectedDate.year}년 ${selectedDate.month}월',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                onPressed: () {
                  onMonthChanged(DateTime(selectedDate.year, selectedDate.month + 1, 1));
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: day == '일' ? AppColors.error : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              if (date == null) {
                return const SizedBox();
              }

              final isSelected = date.day == selectedDate.day;
              final hasWorkout = workoutDates.contains(date);
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : hasWorkout
                            ? AppColors.success.withValues(alpha: 0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : hasWorkout
                                ? AppColors.success
                                : AppColors.textPrimary,
                        fontWeight: hasWorkout ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutRecordCard extends StatelessWidget {
  final WorkoutRecord record;
  final VoidCallback? onDelete;

  const _WorkoutRecordCard({
    required this.record,
    this.onDelete,
  });

  Color get _typeColor {
    switch (record.wod.type) {
      case WodType.amrap:
        return AppColors.amrap;
      case WodType.emom:
        return AppColors.emom;
      case WodType.forTime:
        return AppColors.forTime;
      case WodType.tabata:
        return AppColors.tabata;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.wod.type.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.displayDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (record.isRx)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Rx',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 결과
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                record.displayResult,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // WOD 요약
          Text(
            '${record.wod.duration}분 | ${record.wod.exercises.length}개 운동',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),

          // 메모
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
