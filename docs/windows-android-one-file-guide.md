---
type: online-material
topic: [길벗, Windows, Android, Claude Code, Google Play, 통합 실습]
tags: [길벗, Windows, Android, ClaudeCode, Flutter, GooglePlay, 배포]
created: 2026-06-11
updated: 2026-07-12
source_chapter: "6~15장 Windows/Android 실습 통합"
---

# Windows에서 Android 앱을 책 순서대로 끝까지 만들기

이 문서는 Windows 데스크탑에서 책의 실습 흐름을 그대로 검증하기 위한 통합 가이드입니다.

목표는 빠르게 성공하는 것이 아닙니다. **책에 나온 순서대로 진행했을 때 Windows + Android 독자가 어디서 막히는지 확인하는 것**입니다.

따라서 아래 원칙을 지킵니다.

1. Android Studio를 미리 설치하지 않습니다.
2. Flutter를 미리 설치하지 않습니다.
3. Claude Code도 6장 순서에 도착한 뒤 설치합니다.
4. 9장에서 앱 실행 도구가 필요해질 때 Android Studio와 에뮬레이터를 준비합니다.
5. 막히면 바로 우회하지 말고 QA 로그에 남깁니다.

이 문서 하나만 보고 진행하되, 중간에 GitHub에서 기획 문서와 Android 기준 설계 문서를 내려받아 `docs` 폴더에 넣습니다. 사람이 여러 문서를 직접 읽으며 오갈 필요는 없습니다. Claude Code가 읽게 합니다.

> 기준일: 2026-07-12
> 공식 설치 명령, Google Play 요구사항, Play Console 화면 이름은 바뀔 수 있습니다. 실제 진행 중 화면이 다르면 화면 캡처를 Claude Code에 보여 주고 확인합니다.

예상 시간은 도구 설치와 구현에 수 시간, 첫 Play 반영에 최대 48시간, 새 개인 개발자 계정의 비공개 테스트에 최소 14일입니다. 프로덕션 접근 심사까지 있으므로 책을 읽은 당일 정식 공개를 완료하는 일정으로 잡지 않습니다.

공식 확인 링크:

- Claude Code Windows 설치: [Claude Code setup](https://code.claude.com/docs/en/setup), [Claude Code quickstart](https://code.claude.com/docs/en/quickstart)
- Flutter Android 개발 환경: [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- Google Play target API 기준: [Target API level requirement](https://developer.android.com/google/play/requirements/target-sdk)
- Google Play 신규 개인 계정 테스트 기준: [App testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)

---

## 0. 시작 전 상태

Windows PC는 가능한 한 깨끗한 상태가 좋습니다.

설치되어 있지 않아야 하는 것:

- Claude Code
- Flutter
- Android Studio
- Android SDK
- Firebase CLI

설치되어 있어도 되는 것:

- Chrome 또는 Edge
- PowerShell
- 압축 프로그램

이미 Android Studio나 Flutter가 설치되어 있다면 삭제까지 할 필요는 없습니다. 다만 이번 검증에서는 "책을 읽는 독자가 이 시점에 무엇을 봤을까"를 기준으로 기록합니다.

---

## 1. 전체 진행표

| 책 흐름 | Windows/Android에서 하는 일 | 선설치 여부 |
|---|---|---|
| 3~5장 | GitHub에서 기획 문서만 받아 `docs`에 넣을 준비 | 개발 도구 설치 안 함 |
| 6장 | Git for Windows, Claude Code 설치 | 여기서 처음 설치 |
| 6.5절 | GitHub 자료에서 PRD, TRD_android, IA, Usecase, Design_guide 복사 | 문서만 복사 |
| 7장 | 구현계획서 작성, Task 1 진행 | Claude가 필요 도구를 안내 |
| 8장 | 권한, 디자인 상수, DB, 상태관리 | 화면 확인 전 단계 |
| 9장 | Android Studio, Android 에뮬레이터 준비 | 여기서 처음 설치 |
| 10~14장 | 사진 선택, AI 분석, 저장, 검색, 삭제, 통합 확인 | 에뮬레이터+실기기 |
| 15장 | Google Play 내부 테스트 | Play Console |
| 15장 이후 | 비공개 테스트 12명/14일, 외부 테스터 모집 운영 | 정식 공개 준비 |

---

## 2. QA 로그 파일 먼저 만들기

이 테스트의 산출물은 앱만이 아닙니다. 어디서 막혔는지가 더 중요합니다.

Windows 바탕화면에 `windows-android-qa-log.md` 파일을 만들고, 아래 템플릿을 복사합니다.

```markdown
# Windows/Android 책 따라하기 QA 로그

## 기본 정보
- 날짜:
- Windows 버전:
- Android 실기기 모델:
- Google Play 개발자 계정 생성 여부:
- Claude 구독:

## 로그

### 장/절

- 책에서 하라고 한 일:
- 실제 내가 한 일:
- 결과:
- 막힌 지점:
- 화면 캡처 파일:
- Claude Code에 물어본 프롬프트:
- 해결 방법:
- 원고/온라인 자료 보강 필요:
```

막힐 때마다 이 파일에 남깁니다.

---

## 3. 6장: Git for Windows 설치

책 6.3절의 Windows 팁에 해당합니다. Claude Code는 Windows에서 Git for Windows가 있으면 Git Bash 도구를 쓸 수 있습니다.

PowerShell을 엽니다.

```powershell
winget install --id Git.Git -e
```

설치가 끝나면 PowerShell을 닫고 다시 엽니다.

확인합니다.

```powershell
git --version
```

버전 번호가 나오면 성공입니다.

막히면 QA 로그에 남기고, Claude 웹 채팅에 에러 메시지를 붙여넣어 물어봅니다.

---

## 4. 6장: Claude Code 설치

PowerShell을 엽니다. 관리자 권한으로 열 필요는 없습니다.

```powershell
irm https://claude.ai/install.ps1 | iex
```

설치 확인:

```powershell
claude --version
```

버전 번호가 나오면 성공입니다.

처음 실행합니다.

```powershell
claude
```

브라우저 로그인 화면이 열리면 Claude 계정으로 로그인합니다. 책 기준으로는 Pro 구독부터 시작합니다.

처음 설정 화면에서는 다음 기준으로 고릅니다.

- 로그인: Claude account with subscription
- 테마: 취향대로
- 권장 설정: Yes
- 폴더 신뢰: 직접 만든 프로젝트 폴더에서만 Yes

---

## 5. 6.4절: 프로젝트 폴더 만들기

PowerShell에서 아래처럼 작업합니다.

```powershell
mkdir C:\Dev
cd C:\Dev
mkdir my-food-archive
cd my-food-archive
mkdir docs
```

이제 `C:\Dev\my-food-archive`가 앱 프로젝트 폴더입니다.

여기서 Claude Code를 실행합니다.

```powershell
claude
```

폴더를 신뢰할지 물으면, 직접 만든 폴더이므로 신뢰합니다.

---

## 6. 6.5절: GitHub에서 기획 문서만 받아오기

책에서는 3~5장에서 직접 만든 문서 5개를 `docs` 폴더에 넣습니다.

이번 검증에서는 이미 작성해 둔 문서를 GitHub에서 받아 씁니다. 단, 앱 코드 전체를 받으면 안 됩니다. **문서만 받습니다.**

새 PowerShell 창을 열고 아래 명령을 실행합니다.

```powershell
cd C:\Dev
git clone --depth 1 --filter=blob:none --sparse https://github.com/kimsol1134/my-food-archive.git gilbut-materials
cd C:\Dev\gilbut-materials
git sparse-checkout set docs
```

이제 필요한 문서를 프로젝트 폴더로 복사합니다.

```powershell
Copy-Item "C:\Dev\gilbut-materials\docs\PRD.md" "C:\Dev\my-food-archive\docs\PRD.md"
Copy-Item "C:\Dev\gilbut-materials\docs\IA.md" "C:\Dev\my-food-archive\docs\IA.md"
Copy-Item "C:\Dev\gilbut-materials\docs\Usecase.md" "C:\Dev\my-food-archive\docs\Usecase.md"
Copy-Item "C:\Dev\gilbut-materials\docs\Design_guide.md" "C:\Dev\my-food-archive\docs\Design_guide.md"
Copy-Item "C:\Dev\gilbut-materials\docs\TRD_android.md" "C:\Dev\my-food-archive\docs\TRD_android.md"
```

중요합니다.

아직 `Implement_plan_android.md`는 `docs` 폴더에 넣지 않습니다. 7장에서 책처럼 Claude Code에게 직접 만들게 할 겁니다.

다만 정답지처럼 비교할 원본은 GitHub 자료 안에 있습니다.

```text
C:\Dev\gilbut-materials\docs\Implement_plan_android.md
```

이 파일은 직접 열어보지 말고, 나중에 Claude Code에게 비교용으로만 쓰게 합니다.

---

## 7. 6.5절: Claude Code에게 문서 읽히기

`C:\Dev\my-food-archive`에서 Claude Code를 실행합니다.

```powershell
cd C:\Dev\my-food-archive
claude
```

아래 프롬프트를 입력합니다.

```text
docs 폴더에 있는 기획 문서를 전부 읽고, 이 앱이 뭔지 설명해줘.

나는 Windows 데스크탑에서 Android 앱을 만들고 있다.
따라서 기술 설계서는 TRD.md가 아니라 TRD_android.md를 기준으로 읽어줘.

아직 코드는 만들지 말고, 문서 요약만 해줘.
```

확인할 것:

- 앱 이름과 목적을 이해했는가
- Android 앱이라고 인식했는가
- `TRD_android.md`를 기준으로 읽었는가
- iOS 전용 표현만 반복하지 않는가

결과가 이상하면 이렇게 묻습니다.

```text
방금 답변에 iOS 기준 설명이 섞인 것 같아.
다시 docs/TRD_android.md를 기준으로 Android 앱 흐름만 요약해줘.
```

---

## 8. 7장: 구현계획서 만들기

새 대화를 시작합니다.

```text
/clear
```

플랜 모드를 켭니다.

```text
/plan
```

아래 프롬프트를 넣습니다.

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md를 모두 읽고,
Windows에서 Android 앱을 만드는 기준으로 구현계획서를 작성해줘.

구현계획서는 docs/Implement_plan_android.md 파일로 저장해줘.

아래 규칙을 지켜줘.
1. 작업을 Task 1, Task 2처럼 작은 단위로 나눌 것.
2. 각 Task마다 목표, 구현할 기능, 예상 수정 파일, 완료 확인 방법을 적을 것.
3. 처음 출시 가능한 최소 기능(MVP)부터 배치할 것.
4. PRD에 정의된 핵심 기능에 집중할 것.
5. iOS 전용 설정은 넣지 말 것.
6. Windows + Android 환경을 기준으로 할 것.
7. Android Studio와 Flutter가 아직 설치되어 있지 않을 수 있다는 점을 반영할 것.
```

계획이 나오면 바로 승인하지 않습니다.

먼저 이렇게 검토시킵니다.

```text
이 구현계획서를 비판적으로 검토해줘.

특히 아래를 확인해줘.
1. iOS 전용 내용이 섞였는가?
2. Windows에서 실행 불가능한 명령이 있는가?
3. Android Studio를 너무 일찍 설치하라고 하는가?
4. Task 하나에 여러 일이 과하게 묶였는가?
5. PRD 핵심 기능이 빠졌는가?
```

수정이 필요하면 대화로 고칩니다.

공식 Android 구현계획서와 비교하고 싶을 때만 아래 프롬프트를 사용합니다.

```text
C:\Dev\gilbut-materials\docs\Implement_plan_android.md 파일과
방금 만든 docs/Implement_plan_android.md를 비교해줘.

내가 직접 파일을 읽지 않고 판단할 수 있게,
차이가 중요한 곳만 표로 정리해줘.
그 다음 반영할 항목과 반영하지 않을 항목을 나눠서 제안해줘.
```

최종 계획이 납득되면 저장합니다.

---

## 9. 7.4절: Task 1 진행

아직 Flutter와 Android Studio를 직접 설치하지 않습니다.

책처럼 Claude Code에게 Task 1만 맡깁니다.

새 대화를 시작합니다.

```text
/clear
/plan
```

프롬프트:

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

그리고 구현계획서의 Task 1만 진행해줘.

중요:
1. 나는 Windows 데스크탑에서 진행 중이다.
2. Flutter와 Android Studio가 아직 설치되어 있지 않을 수 있다.
3. 필요한 도구가 없으면 먼저 확인하고, 설치 방법을 안내해줘.
4. 내가 직접 눌러야 하는 설치 화면은 멈춰서 설명해줘.
5. 코드나 파일을 바꾸기 전에는 계획을 먼저 보여줘.
```

이 단계에서 Claude Code가 Flutter 설치를 안내할 수 있습니다. 책 흐름상 허용됩니다. Task 1을 진행하다가 필요한 도구로 드러났기 때문입니다.

하지만 Android Studio 에뮬레이터 준비까지 길게 넘어가려 하면 멈춥니다.

```text
지금은 7장 Task 1 단계야.
Android Studio 에뮬레이터 준비는 9장에서 진행할 예정이니,
지금은 Flutter 프로젝트 생성과 패키지 의존성 추가에 필요한 최소 작업만 진행해줘.
```

Task 1 완료 후 확인:

```powershell
flutter --version
flutter doctor
```

완료되면 커밋합니다.

```text
지금까지 만든 프로젝트를 Git으로 커밋해줘.
커밋 메시지는 "Task 1: Android Flutter project setup"으로 해줘.
```

---

## 10. 8장: Task 2~5 진행

8장은 아직 화면이 잘 보이지 않는 구간입니다. 텍스트 검증이 많습니다.

각 Task는 새 대화로 시작합니다.

공통 프롬프트 형식:

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

구현계획서의 Task [번호]만 진행해줘.

조건:
1. Windows + Android 앱 기준으로 진행한다.
2. iOS 전용 설정은 추가하지 않는다.
3. 먼저 구현 계획을 보여주고, 내가 승인하면 수정한다.
4. 수정 후 가능한 검증 명령을 실행한다.
5. 마지막에 내가 확인할 체크리스트를 짧게 정리한다.
```

진행 순서:

| Task | 내용 | 완료 후 확인 |
|---|---|---|
| Task 2 | Android 권한 설정 | AndroidManifest 권한, 위치 권한 미포함 |
| Task 3 | 컬러/타이포그래피/테마 | 라이트 모드 강제 |
| Task 4 | ArchiveItem 모델 + Hive DB | build_runner 성공 |
| Task 5 | Provider 상태관리 | 테스트 또는 analyze |

각 Task가 끝날 때마다 커밋합니다.

```text
커밋해줘. 메시지는 "Task [번호]: [작업 요약]"으로 해줘.
```

8장까지는 앱 화면이 안 보여도 정상입니다. "눈에 안 보이지만 앱 내부 구조를 만드는 단계"라고 QA 로그에 기록합니다.

---

## 11. 9장: Android Studio와 에뮬레이터 준비

이제 책에서 처음으로 앱을 실행할 도구가 필요해지는 지점입니다.

여기서 Android Studio를 설치합니다.

Claude Code에 먼저 묻습니다.

```text
Android 에뮬레이터에서 이 Flutter 앱을 실행할 수 있게 환경을 준비해줘.

조건:
1. Windows 데스크탑 기준이다.
2. Android Studio가 없으면 설치 안내부터 해줘.
3. Android SDK, command-line tools, platform-tools, emulator 설치 여부를 확인해줘.
4. SDK Platform은 현재 Flutter 공식 문서 기준으로 필요한 최신 API를 확인해서 안내해줘.
5. 에뮬레이터 기기가 없으면 Pixel 계열 기기를 만드는 방법을 단계별로 알려줘.
6. 내가 직접 눌러야 하는 Android Studio 화면에서는 멈춰서 설명해줘.
```

Android Studio 설치 중 확인할 것:

- SDK Platform에서 API 36 설치
- SDK Tools에서 아래 항목 설치
  - Android SDK Build-Tools
  - Android SDK Command-line Tools
  - Android Emulator
  - Android SDK Platform-Tools
  - CMake
  - NDK
- Android 라이선스 승인

PowerShell에서 확인:

```powershell
flutter doctor --android-licenses
flutter doctor
flutter devices
```

에뮬레이터가 보이면 앱 실행 준비가 끝난 것입니다.

---

## 12. 9장: Task 6~9 진행

이제 화면을 만듭니다.

공통 프롬프트:

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

구현계획서의 Task [번호]만 진행해줘.

조건:
1. Android 에뮬레이터에서 확인한다.
2. 먼저 계획을 보여주고 내가 승인하면 수정한다.
3. 구현 후 flutter analyze를 실행한다.
4. 가능하면 Android 에뮬레이터에서 앱을 실행한다.
5. 내가 눈으로 확인할 체크리스트를 만들어준다.
```

진행 순서:

| Task | 내용 | 눈으로 확인할 것 |
|---|---|---|
| Task 6 | HomeScreen | 제목, 검색창, 빈 화면, 추가 버튼 |
| Task 7 | DetailScreen | 아직 직접 열리지 않아도 정상 |
| Task 8 | Add/Edit 화면 | 아직 직접 열리지 않아도 정상 |
| Task 9 | 네비게이션 연결 | 버튼 탭 시 화면 전환 |

화면이 이상하면 스크린샷을 Claude Code에 붙여넣습니다.

```text
첨부한 Android 에뮬레이터 스크린샷을 보고 UI가 디자인 가이드와 다른 곳을 찾아줘.
코드는 바로 고치지 말고, 먼저 문제와 수정 계획을 설명해줘.
```

각 Task 후 커밋합니다.

---

## 13. 10장: 사진 선택과 EXIF

이 장부터는 Android 실기기 확인이 중요해집니다. 에뮬레이터는 사진 EXIF나 갤러리 동작이 실제 기기와 다를 수 있습니다.

먼저 Android폰을 연결합니다.

Android폰에서:

1. 설정 앱을 엽니다.
2. 휴대전화 정보로 들어갑니다.
3. 빌드 번호를 7번 누릅니다.
4. 개발자 옵션을 엽니다.
5. USB 디버깅을 켭니다.
6. PC와 USB 케이블로 연결합니다.
7. RSA 허용 팝업이 뜨면 허용합니다.

PowerShell:

```powershell
flutter devices
```

기기가 보이면 Task 10을 진행합니다.

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

구현계획서의 Task 10만 진행해줘.

조건:
1. Android Photo Picker 기준으로 진행한다.
2. Android 13 이상에서는 사진 권한 팝업이 안 뜰 수 있음을 반영한다.
3. READ_MEDIA_IMAGES, READ_MEDIA_VISUAL_USER_SELECTED, READ_EXTERNAL_STORAGE 같은 광범위한 사진 권한은 선언하지 않는다.
4. EXIF에서 날짜와 GPS를 추출한다.
5. GPS가 없는 사진도 앱이 멈추지 않게 처리한다.
6. 에뮬레이터와 실제 Android폰에서 각각 확인할 체크리스트를 알려줘.
```

확인:

- 사진 선택 화면이 열리는가
- 권한 팝업이 안 떠도 정상임을 이해했는가
- GPS 없는 사진도 선택 가능한가
- 앱이 멈추지 않는가

---

## 14. 11장: Firebase AI Logic과 Gemini Vision

이 장은 보안이 가장 중요합니다.

원칙:

- API 키를 앱 코드에 직접 넣지 않습니다.
- Claude Code에 비밀키를 그대로 붙여넣지 않습니다.
- Firebase AI Logic + App Check 흐름을 사용합니다.
- 사람이 콘솔에서 직접 해야 하는 일은 Claude Code가 멈춰서 안내하게 합니다.

프롬프트:

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

구현계획서의 Task 11만 진행해줘.

조건:
1. Firebase AI Logic을 통해 Gemini Vision을 호출한다.
2. API 키나 secret을 앱 코드에 직접 넣지 않는다.
3. Firebase 콘솔에서 사람이 직접 해야 하는 작업은 단계별로 안내한다.
4. Android App Check는 debug에서는 debug provider, release에서는 Play Integrity 기준으로 설명한다.
5. flutterfire configure로 Android 앱 등록, google-services.json, firebase_options.dart, Gradle 플러그인을 함께 확인한다.
6. Play Console의 Cloud 프로젝트 연결과 Play App Signing 앱 서명 SHA-256 등록을 안내한다.
7. Firebase AI Logic의 App Check 적용 상태를 확인한다.
8. 내가 직접 입력해야 하는 값은 placeholder로 두고 멈춰서 알려준다.
9. 구현 후 디버그뿐 아니라 내부 테스트 설치본에서 실제 사진 한 장으로 메뉴명/카테고리 자동 채움까지 확인한다.
```

주의:

- `google_generative_ai`를 새로 넣으려 하면 이유를 묻습니다.
- `.env`에 API 키를 넣자고 하면 중단합니다.
- `google-services.json`과 `firebase_options.dart`의 Firebase 클라이언트 설정은 서버 비밀키가 아닙니다. 재현 가능한 예제 저장소에서는 함께 커밋할 수 있지만, 백엔드 접근은 Security Rules와 App Check로 보호하고 서비스 계정 키·키스토어·비밀번호는 절대 커밋하지 않습니다.
- 2026년 7월 이후 AI Logic 설정 마법사는 App Check 적용을 자동으로 켤 수 있습니다. 내부 테스트에서 Google Play로 설치한 출시본의 AI 자동 채움이 성공하기 전에는 다음 트랙으로 올리지 않습니다.

---

## 15. 12~14장: 저장, 삭제, 검색, 재선택, 통합 확인

각 Task는 새 대화로 진행합니다.

공통 프롬프트:

```text
@docs 폴더의 PRD.md, TRD_android.md, IA.md, Usecase.md, Design_guide.md, Implement_plan_android.md를 모두 읽어줘.

구현계획서의 Task [번호]만 진행해줘.

조건:
1. 이전 Task에서 만든 구조를 유지한다.
2. Android 에뮬레이터와 실제 Android폰에서 확인 가능한 기준을 나눠서 알려준다.
3. 코드 수정 전 계획을 먼저 보여준다.
4. 수정 후 flutter analyze를 실행한다.
5. 가능하면 내가 직접 눌러볼 통합 체크리스트를 준다.
```

진행 순서:

| Task | 내용 |
|---|---|
| Task 12 | 저장 기능 |
| Task 13 | 삭제 기능 |
| Task 14 | 실시간 검색 |
| Task 15 | 사진 재선택 |
| Task 16 | 에러 처리와 토스트 |
| Task 17 | 전체 통합 테스트 |

14장 끝 통합 체크리스트:

- 앱 실행
- 사진 선택
- AI 자동 채움
- 식당명 입력
- 저장
- 홈 화면 카드 표시
- 검색
- 상세 화면 이동
- 삭제
- 앱 재실행 후 데이터 유지 확인

이 흐름을 실제 Android폰에서 한 번 더 확인합니다.

---

## 16. 15장: Google Play 내부 테스트 준비

15장 본문은 iPhone/TestFlight 기준입니다. Android 앱은 Google Play Console로 갑니다.

먼저 Claude Code에게 배포용 점검을 맡깁니다.

```text
Google Play 내부 테스트에 올릴 준비를 해줘.

조건:
1. 현재 앱이 Android App Bundle(.aab)로 빌드 가능한지 확인한다.
2. 패키지 이름(applicationId)을 확인한다.
3. versionCode와 versionName을 확인한다.
4. keystore와 key.properties가 Git에 올라가지 않게 확인한다.
5. Google Play의 최신 target API 요구사항을 공식 문서 기준으로 확인한다.
6. keystore 비밀번호는 채팅에 붙여넣지 않고 터미널의 숨김 입력란에 내가 직접 입력하도록 멈춰서 알려준다.
7. 마지막에는 Play Console에 업로드할 .aab 파일 경로를 알려준다.
```

빌드 명령은 보통 아래처럼 끝납니다.

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

결과 파일:

```text
build\app\outputs\bundle\release\app-release.aab
```

현재 공식 기준으로 Google Play 새 앱/업데이트는 Android 15, API 35 이상 target이 필요합니다. 빌드 전 Claude Code가 공식 문서 기준으로 다시 확인하게 합니다.

AAB 업로드 전에는 Firebase Android 등록, `google-services.json`, Gradle 플러그인, App Check Play Integrity, Play App Signing의 앱 서명 SHA-256, 내부 테스트 설치본의 AI 자동 채움까지 확인합니다. 상세 순서는 [17~18장 Android 공개 로드맵](android/release-roadmap.md)의 5단계를 따릅니다.

---

## 17. Play Console 내부 테스트

Google Play Console:

[https://play.google.com/console](https://play.google.com/console)

진행 순서:

1. Google Play 개발자 계정 만들기
2. 새 앱 만들기
3. 앱 이름, 기본 언어, 앱/게임, 무료/유료 입력
4. 내부 테스트 트랙 만들기
5. `.aab` 업로드
6. 앱 서명 안내 확인
7. 테스터 이메일 목록 만들기
8. 참여 링크 받기
9. 내 Android폰에서 링크 열기
10. Google Play로 앱 설치

막히는 화면이 나오면 캡처 후 Claude Code에 묻습니다.

```text
Google Play Console 내부 테스트 설정 중이야.
첨부한 화면에서 다음에 무엇을 눌러야 하는지 알려줘.
개인정보, 이메일, 결제 정보, 링크 전체 주소는 가렸어.
```

공개용 캡처를 남길 때 가릴 것:

- Google 계정 이메일
- 개발자 실명
- 주소
- 전화번호
- 결제 정보
- 테스터 이메일
- opt-in 링크 전체 주소
- 인증서 지문
- keystore 경로

---

## 18. 비공개 테스트와 외부 테스터 모집

17~18장의 실제 작업은 [Android 공개 로드맵](android/release-roadmap.md)을 먼저 따라갑니다. 아래 내용은 테스터 모집을 위한 상세 참고입니다.

새 개인 개발자 계정은 정식 공개 전에 비공개 테스트 요구사항이 있을 수 있습니다. 현재 공식 기준은 **최소 12명, 14일 연속 opt-in**입니다.

12명 딱 맞추면 위험합니다. 외부에서 테스터를 모집한다면 15명 이상으로 모집하는 편이 안전합니다.

외부 모집 서비스를 고를 때의 확인 기준과 정책 리스크는 [android/google-play-internal-test-guide.md](android/google-play-internal-test-guide.md)의 11절에 정리되어 있습니다. 결제 전에 그 기준부터 확인하세요.

외부 모집 요청 문구 예시:

```text
Google Play 비공개 테스트 참여자를 모집합니다.

조건:
- Android폰 보유
- Google Play 사용 가능
- 테스트 링크 opt-in 후 14일 동안 참여 상태 유지
- 앱 설치 후 최소 3회 사용
- Day 1 / Day 7 / Day 14에 간단한 피드백 제출
- 설치 화면 또는 앱 실행 화면 캡처 제출

테스트할 기능:
1. 앱 설치
2. 맛집 기록 추가
3. 음식 사진 선택
4. AI 자동 채움 확인
5. 저장
6. 검색
7. 삭제

주의:
- Google 계정 비밀번호는 요구하지 않습니다.
- 공개 리뷰 작성은 요청하지 않습니다.
- Play Console 접근 권한은 제공하지 않습니다.
```

테스터에게 보낼 안내:

```text
테스트 참여 감사합니다.

1. 보내드린 Google Play 테스트 링크를 엽니다.
2. 테스트 참여를 누릅니다.
3. Google Play에서 앱을 설치합니다.
4. 앱을 열고 맛집 기록을 2개 이상 추가합니다.
5. 가능하면 음식 사진을 선택해 AI 자동 채움을 확인합니다.
6. 검색 기능을 써 봅니다.
7. 기록 하나를 삭제해 봅니다.
8. 14일 동안 테스트 참여 상태를 유지해 주세요.

피드백으로 아래 내용을 보내 주세요.
- 사용 기기:
- Android 버전:
- 설치가 잘 되었나요?
- 앱이 꺼진 적이 있나요?
- 사진 선택이 잘 되었나요?
- AI 자동 채움 결과가 자연스러웠나요?
- 가장 헷갈린 화면:
- 고쳤으면 하는 점:
```

외부 모집 테스터의 지급 조건은 3단계로 나누는 것을 권장합니다.

| 지급 | 조건 |
|---|---|
| 1차 | opt-in + 설치 확인 |
| 2차 | Day 7 피드백 |
| 3차 | Day 14 유지 + 최종 피드백 |

---

## 19. Production access 신청 준비

14일 조건을 채우면 Play Console Dashboard에서 production access를 신청합니다.

신청 전에 정리할 것:

- 테스터 수
- 14일 유지 여부
- 받은 피드백 요약
- 실제 수정한 항목
- 앱이 정식 공개 준비가 되었다고 판단한 이유

Claude Code에 이렇게 정리시킵니다.

```text
Google Play production access 신청 답변을 준비하려고 해.

아래 자료를 바탕으로 답변 초안을 만들어줘.
1. 비공개 테스트 기간:
2. 테스터 수:
3. 주요 피드백:
4. 수정한 항목:
5. 아직 남은 한계:
6. 정식 공개 준비가 되었다고 판단한 이유:

답변은 과장하지 말고, 실제 테스트한 내용 중심으로 작성해줘.
```

---

## 20. 절대 하지 말 것

- Android Studio를 9장 전에 미리 설치하지 않습니다.
- Flutter를 7장 Task 1 전에 미리 설치하지 않습니다.
- 앱 코드 전체를 GitHub에서 받아 시작하지 않습니다.
- `lib/`, `android/`, `pubspec.yaml`이 이미 들어 있는 완성 앱을 복사하지 않습니다.
- API 키를 앱 코드에 직접 넣지 않습니다.
- keystore, `key.properties`, `.env`를 Git에 커밋하지 않습니다.
- 외부 모집 테스터에게 Google 계정 비밀번호를 요구하지 않습니다.
- Play Console 관리자 권한을 외부 테스터에게 주지 않습니다.
- 공개 리뷰 작성을 요구하지 않습니다.

---

## 21. 막혔을 때 Claude Code에 던질 공통 프롬프트

설치 오류:

```text
Windows에서 책 실습을 따라 하는 중이고, 아래 오류가 나왔어.

[오류 메시지 붙여넣기]

현재 단계는 [장/Task]야.
책 순서를 유지해야 하므로, Android Studio나 Flutter를 먼저 설치하는 식의 우회는 하지 말고
이 단계에서 필요한 해결 방법만 알려줘.
```

화면 선택:

```text
첨부한 화면에서 다음에 무엇을 눌러야 할지 모르겠어.
나는 Windows에서 Android 앱을 책 순서대로 실습 중이야.
개인정보는 가렸어.

1. 지금 화면이 어떤 단계인지
2. 눌러야 할 버튼
3. 누르면 안 되는 선택지
4. 이 내용을 QA 로그에 어떻게 남기면 좋을지
알려줘.
```

책 순서 이탈 감지:

```text
지금 네 제안이 책 순서와 맞는지 다시 확인해줘.

현재 단계는 [장/절/Task]야.
아직 미리 설치하면 안 되는 도구를 설치하라고 하고 있지는 않은지,
Android 기준 문서가 아니라 iOS 기준 문서를 읽고 있지는 않은지 점검해줘.
```

---

## 22. 마지막 확인

이 문서를 끝까지 따르면 아래 결과가 남아야 합니다.

- `C:\Dev\my-food-archive` 프로젝트 폴더
- `docs` 폴더의 기획 문서 5개
- `docs/Implement_plan_android.md`
- Task별 Git 커밋
- Android 에뮬레이터 실행 기록
- 실제 Android폰 설치/사용 기록
- Google Play 내부 테스트 업로드 기록
- 외부 테스터 비공개 테스트 운영 기록
- `windows-android-qa-log.md`

이 중 가장 중요한 것은 마지막 QA 로그입니다. 이 로그가 있어야 원고와 온라인 자료를 고칠 수 있습니다.
