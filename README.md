# CrossFit WOD 생성기

크로스핏 운동(WOD) 생성 및 기록 관리 앱

## 주요 기능

- 🏋️ 맞춤형 WOD 생성
- 📊 운동 기록 및 통계
- ⏱️ 타이머 기능
- 💪 개인 기록(PR) 관리
- ☁️ 클라우드 동기화

## 배포 (Render.com)

이 프로젝트는 Render.com에 배포되어 있습니다.

### Render 무료 플랜 제한 사항

- 15분간 활동이 없으면 서버가 슬립 모드로 전환됩니다
- 슬립 모드에서 첫 접속 시 30초~1분 정도 로딩이 발생합니다

### 서버 슬립 방지 설정 (권장)

서버를 항상 활성 상태로 유지하려면 **UptimeRobot** 또는 **cron-job.org**를 사용하여 주기적으로 헬스체크를 수행하세요.

#### UptimeRobot 설정 방법

1. [UptimeRobot](https://uptimerobot.com/)에 가입 (무료)
2. "Add New Monitor" 클릭
3. 다음 정보 입력:
   - **Monitor Type**: HTTP(s)
   - **Friendly Name**: CrossFit WOD Server
   - **URL**: `https://your-app-name.onrender.com/health`
   - **Monitoring Interval**: 5 minutes
4. "Create Monitor" 클릭

이제 5분마다 서버에 자동으로 핑이 전송되어 슬립 모드로 전환되지 않습니다.

#### cron-job.org 설정 방법

1. [cron-job.org](https://cron-job.org/)에 가입 (무료)
2. "Create cronjob" 클릭
3. 다음 정보 입력:
   - **Title**: CrossFit WOD Health Check
   - **URL**: `https://your-app-name.onrender.com/health`
   - **Schedule**: Every 5 minutes
4. 저장

## 로컬 개발

### 필요 사항

- Flutter SDK
- Python 3.11+
- pip

### 설치 및 실행

```bash
# 의존성 설치
pip install -r requirements.txt
flutter pub get

# Flutter 웹 빌드
flutter build web

# 서버 실행
python app.py

# 브라우저에서 열기
# http://localhost:9000
```

## API 엔드포인트

- `GET /health` - 서버 상태 확인 (헬스체크)
- `GET /api/check?nickname=<name>` - 닉네임 존재 확인
- `POST /api/user` - 사용자 생성
- `GET /api/user?nickname=<name>` - 사용자 데이터 조회
- `POST /api/sync/workouts` - 운동 기록 동기화
- `POST /api/sync/pr` - 개인 기록 동기화

## 개선 사항 (2025-02-04)

### 서버 콜드 스타트 대응

1. **헬스체크 엔드포인트 추가** (`/health`)
   - 서버 상태 확인 및 웜업 용도
   - UptimeRobot 등 외부 모니터링 서비스 연동 가능

2. **프론트엔드 개선**
   - API 요청 타임아웃 60초로 증가
   - 자동 재시도 로직 (3회, exponential backoff)
   - 앱 시작 시 서버 헬스체크 수행
   - 로딩 화면에 "서버 연결 중..." 메시지 표시

3. **사용자 경험 개선**
   - 첫 접속 시 예상 대기 시간 안내
   - 오프라인 모드 자동 감지
   - 재시도 시 진행 상황 로그 출력
