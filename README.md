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

## 구현 기능 
- 화면 

<img width="720" height="1280" alt="Screenshot_20260424_013530" src="https://github.com/user-attachments/assets/ad752319-dc6b-4a0d-8671-07b70893ccde" />

<img width="720" height="1280" alt="Screenshot_20260424_013510" src="https://github.com/user-attachments/assets/472ca4db-4c2c-42aa-ba07-fb433d23736d" />

<img width="720" height="1280" alt="Screenshot_20260424_013543" src="https://github.com/user-attachments/assets/ef1aef40-6368-4126-9e41-4f3e51ceb44e" />

<img width="720" height="1280" alt="Screenshot_20260424_013558" src="https://github.com/user-attachments/assets/ed860a43-8339-4877-bc3c-e20687fb4a9c" />

<img width="720" height="1280" alt="Screenshot_20260424_013608" src="https://github.com/user-attachments/assets/cacdbedf-b131-4e53-9c56-0b5b9badeafd" />

<img width="720" height="1280" alt="Screenshot_20260424_013625" src="https://github.com/user-attachments/assets/57ea2264-9d2a-4b72-8d28-c93b37ad67d4" />

<img width="720" height="1280" alt="Screenshot_20260424_013633" src="https://github.com/user-attachments/assets/3897e8bb-481f-4134-aba6-66d8359b6146" />

<img width="720" height="1280" alt="Screenshot_20260424_013654" src="https://github.com/user-attachments/assets/722d8296-ebca-47e6-bed1-9431c561cb9c" />

<img width="720" height="1280" alt="Screenshot_20260424_013809" src="https://github.com/user-attachments/assets/fce2c028-d8e1-402e-a5a5-c0065b16f533" />

<img width="720" height="1280" alt="Screenshot_20260424_013815" src="https://github.com/user-attachments/assets/51796b6f-417e-4e2c-b9a9-7cc0d58746ae" />

<img width="720" height="1280" alt="Screenshot_20260424_013820" src="https://github.com/user-attachments/assets/9b5c8e99-6b1a-4448-bfc5-7746c8c3261f" />

<img width="720" height="1280" alt="Screenshot_20260424_013943" src="https://github.com/user-attachments/assets/8c819cab-7546-4825-9481-e4403706935e" />

<img width="720" height="1280" alt="Screenshot_20260424_013955" src="https://github.com/user-attachments/assets/db868e0e-3c03-4627-9640-26ac16723000" />
