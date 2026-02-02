/// 앱 전체에서 사용되는 문자열 상수 (한국어)
class AppStrings {
  AppStrings._();

  // 앱 정보
  static const String appName = 'CrossFit WOD';
  static const String appTitle = '크로스핏 WOD 생성기';

  // 네비게이션
  static const String home = '홈';
  static const String history = '기록';
  static const String pr = '개인기록';
  static const String exercises = '운동';

  // WOD 타입
  static const String amrap = 'AMRAP';
  static const String amrapFull = 'As Many Rounds As Possible';
  static const String amrapDesc = '제한 시간 내 최대 라운드';
  static const String emom = 'EMOM';
  static const String emomFull = 'Every Minute On the Minute';
  static const String emomDesc = '매분마다 운동 수행';
  static const String forTime = 'For Time';
  static const String forTimeDesc = '최대한 빠르게 완료';
  static const String tabata = 'Tabata';
  static const String tabataDesc = '20초 운동, 10초 휴식';

  // 난이도
  static const String difficulty = '난이도';
  static const String beginner = '초급';
  static const String intermediate = '중급';
  static const String advanced = '고급';

  // 버튼
  static const String generateWod = 'WOD 생성';
  static const String startWorkout = '운동 시작';
  static const String pauseWorkout = '일시정지';
  static const String resumeWorkout = '계속하기';
  static const String finishWorkout = '운동 완료';
  static const String saveRecord = '기록 저장';
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String delete = '삭제';
  static const String edit = '수정';

  // 타이머
  static const String timer = '타이머';
  static const String timeRemaining = '남은 시간';
  static const String timeElapsed = '경과 시간';
  static const String round = '라운드';
  static const String rest = '휴식';
  static const String work = '운동';

  // 운동 기록
  static const String workoutHistory = '운동 기록';
  static const String noRecords = '기록이 없습니다';
  static const String totalRounds = '총 라운드';
  static const String completionTime = '완료 시간';
  static const String notes = '메모';
  static const String addNotes = '메모 추가';

  // 개인 기록
  static const String personalRecords = '개인 기록 (PR)';
  static const String newRecord = '새 기록';
  static const String recordHistory = '기록 히스토리';
  static const String weight = '무게';
  static const String reps = '횟수';
  static const String time = '시간';

  // 운동 카테고리
  static const String gymnastics = '체조';
  static const String weightlifting = '역도';
  static const String cardio = '유산소';
  static const String monostructural = '단일구조';

  // 장비
  static const String barbell = '바벨';
  static const String dumbbell = '덤벨';
  static const String kettlebell = '케틀벨';
  static const String pullupBar = '풀업바';
  static const String rings = '링';
  static const String box = '박스';
  static const String rope = '줄넘기';
  static const String rowingMachine = '로잉머신';
  static const String bike = '에어바이크';
  static const String noEquipment = '맨몸';

  // 메시지
  static const String wodGenerated = 'WOD가 생성되었습니다!';
  static const String workoutComplete = '운동 완료!';
  static const String recordSaved = '기록이 저장되었습니다';
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String greatJob = '수고하셨습니다!';

  // 단위
  static const String kg = 'kg';
  static const String lb = 'lb';
  static const String minutes = '분';
  static const String seconds = '초';
  static const String rounds = '라운드';
}
