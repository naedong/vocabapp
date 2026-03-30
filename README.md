# Deutsch Flow

Flutter, Drift, and WASM 기반으로 만든 독일어 공부 앱입니다. 웹과 네이티브 앱에서 모두 같은 학습 흐름을 사용할 수 있도록 구성했고, 로컬 SQLite 데이터를 Drift로 관리합니다.

## 포함된 구성

- Drift 코드 생성 기반 로컬 데이터베이스
- `WasmDatabase`를 사용하는 Flutter Web 저장소 구성
- 홈, 컬렉션, 복습, 통계 화면
- 샘플 독일어 단어와 학습 세션 시드 데이터
- 단어 추가, 북마크, 복습 간격 갱신 흐름

## 실행

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

웹에서 Drift WASM을 조금 더 안정적으로 테스트하려면 다음 헤더를 함께 사용할 수 있습니다.

```bash
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

## 주요 폴더

- `lib/app`: 앱 부트스트랩과 테마
- `lib/data`: Drift 데이터베이스와 플랫폼별 DB 연결
- `lib/presentation`: 화면과 UI 컴포넌트
- `web`: `sqlite3.wasm`, `drift_worker.js`, 웹 메타데이터
