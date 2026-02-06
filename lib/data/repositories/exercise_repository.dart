import '../models/exercise.dart';
import '../datasources/local_storage.dart';

/// 운동 데이터 Repository
class ExerciseRepository {
  final LocalStorage _localStorage;

  ExerciseRepository(this._localStorage);

  /// 모든 운동 가져오기
  List<Exercise> getAllExercises() {
    return _localStorage.getAllExercises();
  }

  /// 특정 운동 가져오기
  Exercise? getExercise(String id) {
    return _localStorage.getExercise(id);
  }

  /// 카테고리별 운동 가져오기
  List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return _localStorage
        .getAllExercises()
        .where((e) => e.category == category)
        .toList();
  }

  /// 난이도별 운동 가져오기
  List<Exercise> getExercisesByDifficulty(Difficulty difficulty) {
    return _localStorage
        .getAllExercises()
        .where((e) => e.difficulty.index <= difficulty.index)
        .toList();
  }

  /// 난이도 및 카테고리별 운동 가져오기
  List<Exercise> getExercises({
    Difficulty? maxDifficulty,
    ExerciseCategory? category,
    List<String>? equipment,
  }) {
    var exercises = _localStorage.getAllExercises();

    if (maxDifficulty != null) {
      exercises = exercises
          .where((e) => e.difficulty.index <= maxDifficulty.index)
          .toList();
    }

    if (category != null) {
      exercises = exercises.where((e) => e.category == category).toList();
    }

    if (equipment != null && equipment.isNotEmpty) {
      exercises = exercises
          .where((e) =>
              e.equipment.isEmpty ||
              e.equipment.any((eq) => equipment.contains(eq)))
          .toList();
    }

    return exercises;
  }

  /// 홈트레이닝 전용 운동 ID 목록
  static const List<String> _homeTrainingExerciseIds = [
    'mountain_climber',
    'jumping_jack',
    'plank_hold',
    'high_knees',
    'butt_kicks',
    'superman',
    'flutter_kicks',
    'bicycle_crunch',
    'inchworm',
    'bear_crawl',
    'crab_walk',
    'glute_bridge',
    'donkey_kick',
    'fire_hydrant',
    'star_jump',
    'broad_jump',
    'calf_raise',
    'hollow_hold',
    'tuck_jump',
    'wall_sit',
    'leg_raise',
    'hollow_rock',
  ];

  /// 홈트레이닝용 운동 가져오기 (장비 없는 모든 운동)
  List<Exercise> getHomeTrainingExercises() {
    final allExercises = _localStorage.getAllExercises();
    return allExercises
        .where((e) => e.equipment.isEmpty)
        .toList();
  }

  /// 일반 모드용 운동 가져오기 (홈트 전용 20개 제외)
  List<Exercise> getNormalModeExercises() {
    final allExercises = _localStorage.getAllExercises();
    return allExercises
        .where((e) => !_homeTrainingExerciseIds.contains(e.id))
        .toList();
  }

  /// 운동 저장
  Future<void> saveExercise(Exercise exercise) async {
    await _localStorage.saveExercise(exercise);
  }

  /// 여러 운동 저장
  Future<void> saveAllExercises(List<Exercise> exercises) async {
    await _localStorage.saveAllExercises(exercises);
  }

  /// 초기 운동 데이터가 있는지 확인
  bool hasExercises() {
    return _localStorage.getAllExercises().isNotEmpty;
  }

  /// 초기 운동 데이터 로드
  Future<void> loadInitialExercises() async {
    if (hasExercises()) return;

    final exercises = _getDefaultExercises();
    await saveAllExercises(exercises);
  }

  /// 운동 데이터 강제 초기화 및 재로드
  Future<void> resetExercises() async {
    await _localStorage.clearExercises();
    final exercises = _getDefaultExercises();
    await saveAllExercises(exercises);
  }

  /// 기본 운동 데이터
  List<Exercise> _getDefaultExercises() {
    return [
      // ===== GYMNASTICS - Beginner =====
      Exercise(
        id: 'air_squat',
        name: 'Air Squat',
        description: '발을 어깨 너비로 벌리고 엉덩이를 뒤로 빼며 앉았다 일어납니다. 무릎이 발끝을 넘지 않도록 합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'burpee',
        name: 'Burpee',
        description: '서있는 자세에서 손을 땅에 짚고 점프하여 플랭크 자세를 만든 후, 가슴이 바닥에 닿게 하고 다시 일어나 점프합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'sit_up',
        name: 'Sit Up',
        description: '등을 대고 누운 상태에서 무릎을 구부리고 상체를 일으켜 손으로 발끝을 터치합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'push_up',
        name: 'Push Up',
        description: '플랭크 자세에서 팔꿈치를 구부려 가슴이 바닥에 닿을 때까지 내려갔다가 올라옵니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'lunge',
        name: 'Lunge',
        description: '한 발을 앞으로 내딛어 양쪽 무릎이 90도가 되도록 앉았다 일어납니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'mountain_climber',
        name: 'Mountain Climber',
        description: '플랭크 자세에서 교대로 무릎을 가슴 쪽으로 당깁니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'jumping_jack',
        name: 'Jumping Jack',
        description: '제자리에서 점프하며 팔과 다리를 벌렸다 모읍니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'plank_hold',
        name: 'Plank Hold',
        description: '팔꿈치를 바닥에 대고 몸을 일직선으로 유지합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'high_knees',
        name: 'High Knees',
        description: '제자리에서 무릎을 높이 올리며 빠르게 달립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'butt_kicks',
        name: 'Butt Kicks',
        description: '제자리에서 뒤꿈치가 엉덩이에 닿도록 빠르게 달립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'squat_jump',
        name: 'Squat Jump',
        description: '스쿼트 자세에서 폭발적으로 점프하고 부드럽게 착지합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'jumping_lunge',
        name: 'Jumping Lunge',
        description: '런지 자세에서 점프하며 다리를 바꿉니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'superman',
        name: 'Superman',
        description: '엎드린 자세에서 팔과 다리를 동시에 들어올립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'flutter_kicks',
        name: 'Flutter Kicks',
        description: '누운 자세에서 다리를 번갈아 위아래로 움직입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'bicycle_crunch',
        name: 'Bicycle Crunch',
        description: '누운 자세에서 자전거 페달을 밟듯이 다리와 상체를 움직입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'inchworm',
        name: 'Inchworm',
        description: '서서 손을 바닥에 짚고 플랭크까지 걸어간 후 다시 돌아옵니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'bear_crawl',
        name: 'Bear Crawl',
        description: '네 발로 기어가는 동작입니다. 무릎이 바닥에 닿지 않도록 합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'crab_walk',
        name: 'Crab Walk',
        description: '뒤로 손을 짚고 엉덩이를 들어 게처럼 옆으로 이동합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'glute_bridge',
        name: 'Glute Bridge',
        description: '누운 자세에서 엉덩이를 들어올려 브릿지 자세를 만듭니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'wall_sit',
        name: 'Wall Sit',
        description: '벽에 등을 대고 의자에 앉은 자세를 유지합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'donkey_kick',
        name: 'Donkey Kick',
        description: '네 발 자세에서 한 다리씩 뒤로 차올립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'fire_hydrant',
        name: 'Fire Hydrant',
        description: '네 발 자세에서 한 다리씩 옆으로 들어올립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'star_jump',
        name: 'Star Jump',
        description: '점프하면서 팔과 다리를 별 모양으로 벌립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'broad_jump',
        name: 'Broad Jump',
        description: '제자리에서 최대한 멀리 앞으로 점프합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'calf_raise',
        name: 'Calf Raise',
        description: '발끝으로 서서 종아리 근육을 수축합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'side_lunge',
        name: 'Side Lunge',
        description: '옆으로 크게 발을 내딛어 런지 자세를 만듭니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'reverse_lunge',
        name: 'Reverse Lunge',
        description: '뒤로 발을 내딛어 런지 자세를 만듭니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'wide_push_up',
        name: 'Wide Push Up',
        description: '손을 어깨보다 넓게 벌리고 푸시업을 합니다. 가슴 강화에 효과적입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),

      // ===== GYMNASTICS - Intermediate =====
      Exercise(
        id: 'pull_up',
        name: 'Pull Up',
        description: '바를 잡고 매달린 상태에서 턱이 바 위로 올라올 때까지 몸을 당깁니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Pull-up Bar'],
      ),
      Exercise(
        id: 'box_jump',
        name: 'Box Jump',
        description: '박스 위로 두 발로 점프하여 올라간 후 완전히 일어선 다음 내려옵니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Box'],
      ),
      Exercise(
        id: 'box_jump_over',
        name: 'Box Jump Over',
        description: '박스를 점프하여 넘어간 후 돌아서 반복합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Box'],
      ),
      Exercise(
        id: 'box_step_over',
        name: 'Box Step Over',
        description: '박스 위로 올라가 반대편으로 내려옵니다. 양 다리를 번갈아 사용합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Box'],
      ),
      Exercise(
        id: 'toes_to_bar',
        name: 'Toes to Bar',
        description: '바에 매달려 발끝이 바에 닿을 때까지 다리를 올립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Pull-up Bar'],
      ),
      Exercise(
        id: 'chest_to_bar',
        name: 'Chest to Bar Pull Up',
        description: '턱이 아닌 가슴이 바에 닿을 때까지 풀업을 수행합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Pull-up Bar'],
      ),
      Exercise(
        id: 'ring_dip',
        name: 'Ring Dip',
        description: '링을 잡고 팔꿈치를 구부려 내려갔다 다시 밀어 올립니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Rings'],
      ),
      Exercise(
        id: 'ring_push_up',
        name: 'Ring Push Up',
        description: '링에 손을 대고 푸시업을 수행합니다. 더 많은 안정화가 필요합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Rings'],
      ),
      Exercise(
        id: 'double_under',
        name: 'Double Under',
        description: '줄넘기를 한 번 점프할 때 줄이 두 번 돌아갑니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Jump Rope'],
      ),
      Exercise(
        id: 'v_up',
        name: 'V-Up',
        description: '누운 자세에서 상체와 다리를 동시에 들어 V자를 만듭니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'hollow_hold',
        name: 'Hollow Hold',
        description: '등을 바닥에 대고 팔과 다리를 살짝 들어 유지합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'leg_raise',
        name: 'Leg Raise',
        description: '누운 자세에서 다리를 곧게 펴고 천천히 들어올렸다 내립니다. 하복부 강화에 효과적입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'hollow_rock',
        name: 'Hollow Rock',
        description: '할로우 홀드 자세에서 몸을 앞뒤로 흔들어 코어 안정성을 강화합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'tuck_jump',
        name: 'Tuck Jump',
        description: '점프하면서 무릎을 가슴으로 끌어당깁니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'diamond_push_up',
        name: 'Diamond Push Up',
        description: '양손으로 다이아몬드 모양을 만들고 푸시업을 합니다. 삼두근 강화에 효과적입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'pike_push_up',
        name: 'Pike Push Up',
        description: '엉덩이를 높이 들고 머리 방향으로 푸시업을 합니다. 어깨 강화에 효과적입니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'spiderman_push_up',
        name: 'Spiderman Push Up',
        description: '푸시업 시 무릎을 옆으로 당겨 팔꿈치에 갖다댑니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: [],
      ),
      Exercise(
        id: 'bar_facing_burpee',
        name: 'Bar Facing Burpee',
        description: '바벨을 마주보고 버피를 수행한 후 바를 점프하여 넘습니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'bar_lateral_burpee',
        name: 'Bar Lateral Burpee',
        description: '바벨 옆에서 버피를 수행한 후 바를 옆으로 점프하여 넘습니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'db_lateral_burpee',
        name: 'DB Lateral Burpee',
        description: '덤벨 옆에서 버피를 수행한 후 덤벨을 옆으로 점프하여 넘습니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.intermediate,
        equipment: ['Dumbbell'],
      ),

      // ===== GYMNASTICS - Advanced =====
      Exercise(
        id: 'handstand_push_up',
        name: 'Handstand Push Up',
        description: '물구나무 자세에서 머리가 바닥에 닿을 때까지 내려갔다 올라옵니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.advanced,
        equipment: [],
      ),
      Exercise(
        id: 'handstand_walk',
        name: 'Handstand Walk',
        description: '물구나무 자세를 유지하며 손으로 걸어갑니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.advanced,
        equipment: [],
      ),
      Exercise(
        id: 'pistol_squat',
        name: 'Pistol Squat',
        description: '한 다리로 스쿼트를 수행합니다. 반대쪽 다리는 앞으로 뻗습니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.advanced,
        equipment: [],
      ),
      Exercise(
        id: 'muscle_up',
        name: 'Muscle Up',
        description: '바에 매달려 풀업 후 팔을 펴서 바 위로 올라갑니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.advanced,
        equipment: ['Pull-up Bar'],
      ),
      Exercise(
        id: 'ring_muscle_up',
        name: 'Ring Muscle Up',
        description: '링에서 수행하는 머슬업입니다. 더 많은 힘과 조절력이 필요합니다.',
        category: ExerciseCategory.gymnastics,
        difficulty: Difficulty.advanced,
        equipment: ['Rings'],
      ),

      // ===== WEIGHTLIFTING - Beginner =====
      Exercise(
        id: 'deadlift',
        name: 'Deadlift',
        description: '바벨을 바닥에서 엉덩이까지 들어올립니다. 등을 곧게 유지합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'front_squat',
        name: 'Front Squat',
        description: '바벨을 어깨 앞쪽에 올리고 스쿼트를 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'back_squat',
        name: 'Back Squat',
        description: '바벨을 등 위쪽/승모근에 올리고 스쿼트를 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'shoulder_press',
        name: 'Shoulder Press',
        description: '바벨을 어깨에서 머리 위로 밀어 올립니다. 다리 반동 없이 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'kb_swing',
        name: 'Russian KB Swing',
        description: '케틀벨을 다리 사이에서 가슴 높이까지 스윙합니다. 힙 드라이브를 사용합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Kettlebell'],
      ),
      Exercise(
        id: 'american_kb_swing',
        name: 'American KB Swing',
        description: '케틀벨을 다리 사이에서 머리 위까지 스윙합니다. 힙 드라이브를 사용합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Kettlebell'],
      ),
      Exercise(
        id: 'goblet_squat',
        name: 'Goblet Squat',
        description: '덤벨이나 케틀벨을 가슴 앞에 들고 스쿼트를 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Dumbbell', 'Kettlebell'],
      ),
      Exercise(
        id: 'sumo_deadlift_high_pull',
        name: 'Sumo Deadlift High Pull',
        description: '넓은 스탠스로 바벨을 턱 높이까지 당깁니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Barbell', 'Kettlebell'],
      ),
      Exercise(
        id: 'wall_ball',
        name: 'Wall Ball Shot',
        description: '메디신 볼을 들고 스쿼트 후 일어서며 벽의 목표물에 던집니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Medicine Ball'],
      ),
      Exercise(
        id: 'db_deadlift',
        name: 'Dumbbell Deadlift',
        description: '덤벨을 사용하여 데드리프트 동작을 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Dumbbell'],
      ),
      Exercise(
        id: 'db_shoulder_press',
        name: 'Dumbbell Shoulder Press',
        description: '덤벨을 어깨에서 머리 위로 밀어 올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Dumbbell'],
      ),
      Exercise(
        id: 'farmers_carry',
        name: 'Farmer\'s Carry',
        description: '무거운 중량을 양손에 들고 바른 자세로 걸어갑니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.beginner,
        equipment: ['Dumbbell', 'Kettlebell'],
      ),

      // ===== WEIGHTLIFTING - Intermediate =====
      Exercise(
        id: 'power_clean',
        name: 'Power Clean',
        description: '바벨을 바닥에서 어깨 위 프론트 랙 포지션으로 한 번에 들어올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'push_press',
        name: 'Push Press',
        description: '무릎을 살짝 구부렸다가 펴면서 바벨을 머리 위로 밀어 올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'thruster',
        name: 'Thruster',
        description: '프론트 스쿼트와 푸시 프레스를 결합한 동작입니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell', 'Dumbbell'],
      ),
      Exercise(
        id: 'db_thruster',
        name: 'Dumbbell Thruster',
        description: '덤벨을 사용하여 쓰러스터 동작을 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Dumbbell'],
      ),
      Exercise(
        id: 'hang_clean',
        name: 'Hang Clean',
        description: '바벨을 무릎 위에서 시작하여 프론트 랙 포지션으로 들어올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'db_hang_clean',
        name: 'Dumbbell Hang Clean',
        description: '덤벨을 사용하여 행 클린 동작을 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Dumbbell'],
      ),
      Exercise(
        id: 'overhead_squat',
        name: 'Overhead Squat',
        description: '바벨을 머리 위로 들고 스쿼트를 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'db_overhead_squat',
        name: 'Dumbbell Overhead Squat',
        description: '덤벨을 머리 위로 들고 스쿼트를 수행합니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Dumbbell'],
      ),
      Exercise(
        id: 'db_snatch',
        name: 'Dumbbell Snatch',
        description: '한 손으로 덤벨을 바닥에서 머리 위까지 한 동작으로 들어올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.intermediate,
        equipment: ['Dumbbell'],
      ),

      // ===== WEIGHTLIFTING - Advanced =====
      Exercise(
        id: 'snatch',
        name: 'Snatch',
        description: '바벨을 바닥에서 머리 위로 한 번에 들어올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.advanced,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'clean_and_jerk',
        name: 'Clean and Jerk',
        description: '클린으로 바벨을 어깨에 올린 후 저크로 머리 위로 밀어 올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.advanced,
        equipment: ['Barbell'],
      ),
      Exercise(
        id: 'split_jerk',
        name: 'Split Jerk',
        description: '다리를 앞뒤로 벌리며 바벨을 머리 위로 밀어 올립니다.',
        category: ExerciseCategory.weightlifting,
        difficulty: Difficulty.advanced,
        equipment: ['Barbell'],
      ),

      // ===== CARDIO =====
      Exercise(
        id: 'run',
        name: 'Run',
        description: '지정된 거리를 달립니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'row',
        name: 'Row',
        description: '로잉머신에서 노를 젓듯이 운동합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: ['Rower'],
      ),
      Exercise(
        id: 'bike',
        name: 'Assault Bike',
        description: '에어바이크를 타며 전신 유산소 운동을 합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: ['Assault Bike'],
      ),
      Exercise(
        id: 'shuttle_run',
        name: 'Shuttle Run',
        description: '지정된 거리를 왕복으로 달립니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'ski_erg',
        name: 'Ski Erg',
        description: '스키 에르그 머신에서 스키 동작을 수행합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: ['Ski Erg'],
      ),
      Exercise(
        id: 'spot_run',
        name: 'Running in Place',
        description: '제자리에서 달리기 동작을 수행합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'skater',
        name: 'Skater',
        description: '스케이트 타듯이 좌우로 점프하며 이동합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
      Exercise(
        id: 'lateral_shuffle',
        name: 'Lateral Shuffle',
        description: '낮은 자세로 빠르게 좌우로 이동합니다.',
        category: ExerciseCategory.cardio,
        difficulty: Difficulty.beginner,
        equipment: [],
      ),
    ];
  }
}
