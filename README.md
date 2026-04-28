# Deutsch Flow

독일어 단어 수집, 복습, 발음 점검, 실전 읽기까지 한 화면 흐름으로 이어지는 Flutter 학습 앱입니다. 캡처에 보이는 홈 대시보드, 단어 컬렉션, 복습 세션, 실전 독일어, 학습 인사이트를 기준으로 현재 기능을 정리했습니다.

## 구현 기능

- 홈 대시보드에서 오늘 추천 단어, 복습 대기 카드, 학습 흐름을 한 번에 확인
- 단어 컬렉션에서 덱 필터, 검색, 북마크, TTS 재생, 예문 재생, 발음 코치 실행
- 복습 세션에서 뜻을 가렸다가 확인하고, 기억 여부에 따라 다음 복습 간격을 자동 조정
- 단어 추가 시 사전/AI 자동 채움으로 뜻, 발음, 품사, 관사, 예문, 문법 메모 저장
- 마이크 기반 발음 점검과 AI 코칭으로 저장된 발음 메모와 실제 인식 결과를 비교
- 독일어 시험 연습에서 B1 읽기/듣기/말하기 세트와 AI 생성 A1 듣기 문제 활용
- 실전 독일어 탭에서 NewsAPI 기반 독일 뉴스 검색, 기사 읽기, 공식 학습 자료 연결
- 학습 인사이트에서 최근 복습 기록, 누적 카드, 숙련도 흐름 확인
- 설정에서 안내 언어, 학습 언어, AI 제공자(Gemini/ChatGPT/자동)를 선택

## 화면

- `Home`: 오늘의 추천, 복습 대기, 빠른 학습 액션
- `Library`: 단어 카드 검색, 덱별 필터링, 즐겨찾기, 음성 재생
- `Review`: 간격 반복 복습과 기억 여부 기록
- `Immersion`: 독일 뉴스 검색, 기사 리더, DW/Goethe/Tagesschau 같은 외부 자료
- `Insights`: 학습량, 리뷰 기록, 카드 상태 요약

스크린샷 파일은 `docs/screenshots` 폴더 기준으로 연결했습니다.

| 홈/학습 흐름 | 컬렉션/복습 |
| --- | --- |
| ![Screenshot_20260424_013530](docs/screenshots/Screenshot_20260424_013530.png) | ![Screenshot_20260424_013510](docs/screenshots/Screenshot_20260424_013510.png) |
| ![Screenshot_20260424_013543](docs/screenshots/Screenshot_20260424_013543.png) | ![Screenshot_20260424_013558](docs/screenshots/Screenshot_20260424_013558.png) |
| ![Screenshot_20260424_013608](docs/screenshots/Screenshot_20260424_013608.png) | ![Screenshot_20260424_013625](docs/screenshots/Screenshot_20260424_013625.png) |

| 발음/시험/설정 | 실전 독일어/인사이트 |
| --- | --- |
| ![Screenshot_20260424_013633](docs/screenshots/Screenshot_20260424_013633.png) | ![Screenshot_20260424_013654](docs/screenshots/Screenshot_20260424_013654.png) |
| ![Screenshot_20260424_013809](docs/screenshots/Screenshot_20260424_013809.png) | ![Screenshot_20260424_013815](docs/screenshots/Screenshot_20260424_013815.png) |
| ![Screenshot_20260424_013820](docs/screenshots/Screenshot_20260424_013820.png) | ![Screenshot_20260424_013943](docs/screenshots/Screenshot_20260424_013943.png) |
| ![Screenshot_20260424_013955](docs/screenshots/Screenshot_20260424_013955.png) |  |

## 기술 스택

- Flutter와 Material 3 기반 반응형 UI
- Drift와 SQLite 기반 로컬 데이터베이스
- Flutter Web용 `WasmDatabase`, `sqlite3.wasm`, `drift_worker.js`
- `flutter_tts`를 이용한 단어/예문 음성 재생
- `speech_to_text`를 이용한 마이크 발음 점검
- Gemini 또는 OpenAI Responses API 기반 자동 채움, 코칭, 문제 생성
- NewsAPI 기반 독일 뉴스 검색과 로컬 캐시

## 실행

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

웹에서 Drift WASM을 더 안정적으로 테스트하려면 다음 헤더를 함께 사용할 수 있습니다.

```bash
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

## API 설정

AI 자동 채움, 코칭, 시험 생성, 실시간 뉴스는 API 키가 있을 때 활성화됩니다. 로컬 개발에서는 `lib/src/core/config/*_secrets.dart` 파일을 예시 파일에서 복사해 채우거나 `dart-define`으로 전달할 수 있습니다.

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your-key \
  --dart-define=OPENAI_API_KEY=your-key \
  --dart-define=NEWS_API_KEY=your-key
```

키가 없어도 로컬 단어장, 복습, 샘플 시험 세트, 기본 화면은 사용할 수 있습니다.

## 주요 폴더

- `lib/main.dart`: 앱 진입점
- `lib/src/app`: 앱 부트스트랩, 테마, 반응형 레이아웃
- `lib/src/core/database`: Drift 테이블, 마이그레이션, 시드 데이터, 플랫폼별 DB 연결
- `lib/src/core/audio`: TTS, 음성 인식, 발음 유사도 계산
- `lib/src/core/config`: Gemini, OpenAI, NewsAPI 설정
- `lib/src/core/settings`: 안내 언어, 학습 언어, AI 제공자 설정
- `lib/src/features/study`: 단어장, 복습, 추천 단어, 시험 연습, 코칭 UI
- `lib/src/features/dictionary`: 사전 조회와 AI 기반 카드 자동 채움
- `lib/src/features/immersion`: 뉴스 검색, 기사 리더, 외부 학습 자료
- `web`: Drift WASM 워커와 웹 메타데이터
