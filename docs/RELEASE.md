# Google Play 배포용 프로젝트 메모 — 맛집 아카이브 (Android)

이 문서는 저장소 관리자가 서명과 빌드 설정을 재현할 때 사용하는 프로젝트 메모다. 책 독자가 따라갈 Play Console 절차의 정본은 [Android 온라인 실습 자료](android/README.md)다.

## 현재 상태 (완료됨)

- 기능: Task 1~17 구현 완료, `flutter analyze` 0건, UC-01~06 에뮬레이터 검증 완료.
- 앱 이름: **My Food Archive** (`android/app/src/main/res/values/strings.xml` → 매니페스트 `@string/app_name`, iOS와 동일).
- 런처 아이콘: iOS의 Liquid Glass Polaroid 1024px 원본을 `flutter_launcher_icons`로 Android 전 해상도에 생성.
- 버전: `pubspec.yaml`의 `version: 1.0.0+5` (versionName 1.0.0 / versionCode 5).
- 서명 배선: `android/app/build.gradle.kts`가 저장소 밖의 업로드 키와 `android/key.properties`를 읽어 release 서명. 파일이 없으면 로컬 빌드 편의를 위해 디버그 서명으로 폴백하지만, Play Console에는 업로드하지 않는다.
- AI 자동 태깅: Firebase Android 앱, Google Services, Firebase AI Logic, App Check(릴리스는 Play Integrity) 연결 완료. 2026-07-12에 Firebase AI Logic 강제 적용(`ENFORCED`)과 에뮬레이터 호출을 다시 확인함.

상세 검증 근거: [`docs/android/release-verification-2026-07-12.md`](android/release-verification-2026-07-12.md)

## 새 환경에서 다시 준비할 절차

### 1) 업로드 키스토어 생성 (한 번만, 분실 주의)

> **경고:** 이 키를 잃어버리면 같은 앱으로 업데이트를 못 올린다(Play App Signing 사용 시 업로드 키는 재설정 가능하나 번거로움). **키스토어 파일과 비밀번호를 비밀번호 관리자 등 안전한 곳에 백업**할 것. 저장소(repo)에는 절대 커밋하지 말 것 — 이미 `.gitignore` 처리됨.

레포 **바깥**의 안전한 폴더에 생성하는 것을 권장한다(예: `C:\Users\sol\keys\`). JDK의 `keytool` 사용:

```powershell
# JDK 21 keytool (PATH에 없으면 절대경로로)
& "E:\Java\jdk-21.0.11.10-hotspot\bin\keytool.exe" -genkeypair -v `
  -keystore "C:\Users\sol\keys\upload-keystore.jks" `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

실행하면 **키스토어 비밀번호**와 이름/조직 등(dname)을 물어본다. 키 비밀번호는 스토어 비밀번호와 같게 두어도 된다.

### 2) `android/key.properties` 작성

`android/` 폴더 바로 아래에 다음 내용으로 `key.properties`를 만든다(이미 `.gitignore` 처리됨):

```properties
storePassword=<1)에서 정한 키스토어 비밀번호>
keyPassword=<1)에서 정한 키 비밀번호>
keyAlias=upload
storeFile=C:\\Users\\sol\\keys\\upload-keystore.jks
```

> `storeFile`은 **절대경로**를 권장(백슬래시는 `\\`로 이스케이프). 상대경로를 쓸 경우 기준은 `android/app/` 이다.

### 3) 서명된 AAB 빌드

`key.properties`가 있으면 자동으로 업로드 키로 서명된다:

```bash
# PATH에 flutter 없으면: export PATH="/e/dev/flutter/bin:$PATH"
flutter build appbundle --release
# 산출물: build/app/outputs/bundle/release/app-release.aab
```

서명 확인(선택):
```bash
& "E:\Java\jdk-21.0.11.10-hotspot\bin\keytool.exe" -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```
→ 출력의 소유자/발급자가 debug(`CN=Android Debug`)가 **아니어야** 한다.

### 4) Play Console로 이동

개발자 계정 생성부터 내부 테스트, 비공개 테스트, 프로덕션 접근 신청과 공개까지의 화면 작업은 [Android 온라인 실습 자료](android/README.md)에서 현재 책 장과 계정 상태에 맞는 경로를 따른다. 내부 테스트 뒤 바로 프로덕션으로 승격하지 않는다.

## 스토어 심사용 비(非)코드 준비물

- **개인정보처리방침 URL**: `docs/privacy-policy.md`를 공개된 읽기 전용 URL로 제공하고 앱 내부의 개인정보처리방침 화면과 내용이 일치하게 유지한다.
- **데이터 보안**: 기록과 사진은 로컬 저장되지만, 사용자가 고른 사진은 AI 분석을 위해 Firebase AI Logic/Gemini로 전송된다. "서버 미전송"으로 답하면 안 된다.
- **그래픽 리소스**: 512×512 앱 아이콘, 기능 그래픽 1024×500, 독자의 실제 Android 설치본에서 촬영한 원본 스크린샷 2장 이상. `docs/book-screenshots/android-app/`은 저자 앱의 출판 참고본이며 독자의 제출 이미지가 아니다.
- **콘텐츠 등급 설문**, 대상 연령, 카테고리(음식/라이프스타일).

## Firebase/App Check를 새 프로젝트에서 재구성할 때

`docs/Implement_plan_android.md` Task 11 참조. 요약:
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=my-food-archive-dbc0c --platforms=android \
  --android-package-name=com.solkim.my_food_archive --yes
```
- Play Console → 앱 무결성에서 Firebase/Google Cloud 프로젝트를 연결한다.
- Firebase App Check Android 앱에 Play Integrity provider를 등록한다.
- Firebase에는 업로드 키가 아니라 **Play App Signing의 앱 서명 인증서 SHA-256**을 등록한다.
- Firebase Console → App Check → API에서 Firebase AI Logic enforcement 상태를 확인한다.
- 내부 테스트 설치본에서 음식 사진 1장을 분석해 메뉴명/카테고리가 자동 입력되는지 확인한 뒤 프로덕션으로 진행한다.
