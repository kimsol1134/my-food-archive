# My Food Archive · 마이 맛집 아카이브

이 저장소는 길벗출판사 도서 **《클로드 코드로 앱스토어까지》**의 공식 온라인 실습 자료입니다. 책에서 만드는 마이 맛집 아카이브의 완성 코드, 저자 예시 문서, Android 독자를 위한 Google Play 보충 가이드를 제공합니다.

> 책을 따라 앱을 직접 만들고 있다면 완성 코드를 처음부터 복사하지 마세요. 먼저 책에서 자신의 문서를 만들고, 막힌 부분을 비교하거나 최종 결과를 확인할 때 이 저장소를 사용하면 됩니다.

## 처음 오셨다면

현재 읽는 장에 맞는 한 곳만 열면 됩니다.

| 지금 필요한 자료 | 열기 |
|---|---|
| 3~7장 · 저자가 만든 기획 문서와 구현계획서 예시 | [책 실습 문서 보기](#책-실습-문서) |
| 8~14장 · 완성 앱 코드와 내 프로젝트 비교 | [완성 앱 참고본 보기](#완성-앱-참고본) |
| 15~18장 · iPhone 앱의 App Store 제출 항목 확인 | [App Store 제출 체크리스트](docs/AppStore_Submission_Checklist.md) |
| 15~18장 · Android 앱을 Google Play에 배포 | [Android 온라인 실습 자료](https://kimsol1134.github.io/my-food-archive/android/) |

GitHub가 익숙하지 않고 완성 참고본을 한 번에 받고 싶다면 [출판 기준 자료 ZIP 내려받기](https://github.com/kimsol1134/my-food-archive/archive/refs/tags/book-v1.0.0.zip)를 누르세요. 내려받은 파일의 압축을 풀면 됩니다. 이 링크는 책과 맞춘 `book-v1.0.0` 버전에 고정되어 있어 이후 코드가 바뀌어도 내용이 달라지지 않습니다.

## 책 실습 문서

아래 파일은 저자가 마이 맛집 아카이브를 만들 때 사용한 **완성 예시본**입니다. 책에서 여러분이 만드는 문서의 정답지가 아니라, 결과의 구체성과 구성을 비교하는 참고 자료입니다.

### Mac + iPhone 독자

| 책에서 만드는 문서 | 저자 예시본 |
|---|---|
| 무엇을 만들지 정하는 기획서 | [PRD.md](docs/PRD.md) |
| iPhone 앱의 기술 설계서 | [TRD.md](docs/TRD.md) |
| 화면 연결 구조 | [IA.md](docs/IA.md) |
| 사용 흐름 | [Usecase.md](docs/Usecase.md) |
| 색상과 화면 디자인 | [Design_guide.md](docs/Design_guide.md) |
| Claude Code가 따르는 구현 순서 | [Implement_plan.md](docs/Implement_plan.md) |
| App Store Connect 입력 항목 | [AppStore_Submission_Checklist.md](docs/AppStore_Submission_Checklist.md) |

### Windows 또는 Android 독자

`PRD.md`, `IA.md`, `Usecase.md`, `Design_guide.md`는 위의 공통 문서를 사용합니다. 플랫폼에 따라 달라지는 두 문서만 Android 버전을 선택하세요.

- [TRD_android.md](docs/TRD_android.md) — Android 기술 설계서
- [Implement_plan_android.md](docs/Implement_plan_android.md) — Android 구현계획서
- [Android 온라인 실습 자료](https://kimsol1134.github.io/my-food-archive/android/) — 책 15~18장의 Google Play 진행 순서

문서 속 `com.solkim...` 패키지 이름, Firebase 프로젝트 이름, 개발자 이름과 이메일은 저자 앱의 값입니다. 자신의 앱을 만들 때 그대로 복사하지 말고 책의 안내에 따라 본인 값으로 바꾸세요.

## 완성 앱 참고본

이 저장소의 Flutter 코드는 책 실습 앱의 완성 상태를 보여 주는 참고본입니다.

- 음식 사진 선택
- 사진의 촬영 날짜와 위치 정보 읽기
- AI가 메뉴명과 카테고리 자동 입력
- 식당명·메뉴·지역·카테고리 수정
- 맛집 기록 저장·검색·수정·삭제
- 앱 안에서 개인정보처리방침 확인

### 내려받은 앱에서 바로 확인할 수 있는 것

로컬 저장, 검색, 수정, 삭제와 화면 구성은 저장소를 내려받아 실행하면 확인할 수 있습니다.

AI 자동 입력은 자신의 Firebase 프로젝트 연결과 App Check 설정이 추가로 필요합니다. 저장소에 포함된 Firebase 클라이언트 설정은 저자 앱의 참고값이므로, 복제한 앱에서 AI 기능까지 그대로 사용할 수 있다는 뜻은 아닙니다. 설정이 없거나 App Check 확인에 실패해도 앱의 로컬 기록 기능은 실행되고, AI 입력만 비활성화됩니다.

<details>
<summary>터미널 사용 경험이 있는 독자: 예제 앱 실행 명령 보기</summary>

Flutter 개발 환경이 이미 준비되어 있을 때만 아래 명령을 사용하세요.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Google Play에 올릴 Android App Bundle을 확인할 때는 다음 명령을 사용합니다.

```bash
flutter build appbundle --release
```

실제 업로드용 AAB에는 저장소에 포함되지 않은 `android/key.properties`와 본인의 업로드 키스토어가 필요합니다. 자세한 순서는 [Android 온라인 실습 자료](https://kimsol1134.github.io/my-food-archive/android/)를 따르세요.

</details>

## Firebase 파일과 비밀번호

`android/app/google-services.json`과 `lib/firebase_options.dart`는 앱이 Firebase 프로젝트를 찾는 **클라이언트 식별 설정**입니다. 서버 비밀번호나 업로드 키가 아닙니다.

실제 API 호출은 다음 방식으로 보호합니다.

- 개발 중 실행: Firebase App Check Debug Provider
- Google Play 설치본: App Check Play Integrity
- iPhone 배포본: App Attest와 DeviceCheck 대체 경로
- Gemini 호출: Firebase AI Logic의 App Check 적용

업로드 키스토어, `android/key.properties`, 서비스 계정 키, 비밀번호와 인증번호는 저장소에 올리지 않습니다.

## 문제가 생겼을 때

[공개 지원 페이지](https://kimsol1134.github.io/my-food-archive/support/)에서 이메일과 GitHub Issues 문의 경로를 확인할 수 있습니다. 질문에는 읽고 있는 책의 장, 사용 중인 운영체제, 화면에 표시된 오류 문장을 함께 적어 주세요.

스크린샷을 첨부할 때는 비밀번호, 인증번호, 결제 정보와 비공개 테스트 참여 링크를 제외하세요.

## 개인정보처리방침

- [My Food Archive 개인정보처리방침](https://kimsol1134.github.io/my-food-archive/privacy-policy/)
- [지원 및 개인정보 문의](https://kimsol1134.github.io/my-food-archive/support/)

## 이용 조건

앱 소스 코드는 [MIT License](LICENSE)의 적용을 받아 학습·수정·재사용할 수 있습니다. 문서와 사진·스크린샷은 책과 함께 개인 학습에 사용할 수 있으며, 복제·재배포 등 그 밖의 이용 조건은 [LICENSE](LICENSE)의 문서 및 미디어 항목을 확인하세요.

<details>
<summary>저장소 관리와 출판 검수 문서</summary>

아래 문서는 책 실습 순서가 아니라 저장소 유지보수와 출판 검수에 사용합니다.

- [Google Play 배포용 프로젝트 메모](docs/RELEASE.md)
- [Windows/Android 통합 QA 가이드](docs/windows-android-one-file-guide.md)
- [Android 온라인 실습 자료 출판 인계표](docs/android/editorial-handoff.md)
- [Android 부록 인쇄 교정 체크리스트](docs/android/print-proof-checklist.md)
- [Android 온라인 실습 자료 정량 평가](docs/android/appendix-audit.md)
- [Google Play 출시 상태 체크리스트](docs/LAUNCH_CHECKLIST.md)

</details>
