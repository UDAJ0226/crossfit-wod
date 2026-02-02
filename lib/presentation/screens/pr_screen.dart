import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/personal_record.dart';
import '../../providers/pr_provider.dart';
import '../widgets/pr_card.dart';

/// PR (개인 기록) 화면
class PrScreen extends ConsumerStatefulWidget {
  const PrScreen({super.key});

  @override
  ConsumerState<PrScreen> createState() => _PrScreenState();
}

class _PrScreenState extends ConsumerState<PrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(allPersonalRecordsProvider);
    final bestRecords = ref.watch(bestRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('개인 기록 (PR)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPrDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '최고 기록'),
            Tab(text: '전체 기록'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 최고 기록 탭
          _BestRecordsTab(bestRecords: bestRecords),

          // 전체 기록 탭
          _AllRecordsTab(allRecords: allRecords),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPrDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPrDialog(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => PrInputDialog(
        onSave: (exercise, value, unit, variation, notes) async {
          await ref.read(prNotifierProvider.notifier).savePersonalRecord(
                exerciseName: exercise,
                value: value,
                unit: unit,
                variation: variation,
                notes: notes,
              );

          if (mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('PR이 저장되었습니다!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }
}

class _BestRecordsTab extends ConsumerWidget {
  final Map<String, PersonalRecord> bestRecords;

  const _BestRecordsTab({required this.bestRecords});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bestRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16),
            Text(
              '아직 PR이 없습니다',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '첫 번째 개인 기록을 추가해보세요!',
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 운동별로 그룹화
    final groupedRecords = <String, List<PersonalRecord>>{};
    for (final entry in bestRecords.entries) {
      final exerciseName = entry.value.exerciseName;
      groupedRecords.putIfAbsent(exerciseName, () => []);
      groupedRecords[exerciseName]!.add(entry.value);
    }

    final exercises = groupedRecords.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final records = groupedRecords[exercise]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ExercisePrSection(
            exerciseName: exercise,
            records: records,
          ),
        );
      },
    );
  }
}

class _ExercisePrSection extends ConsumerWidget {
  final String exerciseName;
  final List<PersonalRecord> records;

  const _ExercisePrSection({
    required this.exerciseName,
    required this.records,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 운동 이름 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.surface,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  exerciseName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // PR 목록
          ...records.map((record) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.variation != null)
                        Text(
                          record.variation!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        record.displayDate,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        record.displayValue,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => _deletePr(context, ref, record),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _deletePr(BuildContext context, WidgetRef ref, PersonalRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'PR 삭제',
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
      await ref.read(prNotifierProvider.notifier).deletePersonalRecord(record.id);
    }
  }
}

class _AllRecordsTab extends ConsumerWidget {
  final List<PersonalRecord> allRecords;

  const _AllRecordsTab({required this.allRecords});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (allRecords.isEmpty) {
      return const Center(
        child: Text(
          '기록이 없습니다',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allRecords.length,
      itemBuilder: (context, index) {
        final record = allRecords[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PrCard(
            record: record,
            onDelete: () => _deletePr(context, ref, record),
          ),
        );
      },
    );
  }

  void _deletePr(BuildContext context, WidgetRef ref, PersonalRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'PR 삭제',
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
      await ref.read(prNotifierProvider.notifier).deletePersonalRecord(record.id);
    }
  }
}
