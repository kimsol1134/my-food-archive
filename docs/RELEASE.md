# 🚀 Google Play 스토어 배포 가이드 — 맛집 아카이브 (Android)

이 문서는 **스토어 공개 배포**에 필요한 남은 절차를 정리한다. 앱 코드/아이콘/앱이름/버전/서명 배선은 이미 끝나 있고, **업로드 키스토어 생성과 Play Console 등록만 남았다.**

## 현재 상태 (완료됨)

- 기능: Task 1~17 구현 완료, `flutter analyze` 0건, UC-01~06 에뮬레이터 검증 완료.
- 앱 이름: **My Food Archive** (`android/app/src/main/res/values/strings.xml` → 매니페스트 `@string/app_name`, iOS와 동일).
- 런처 아이콘: iOS의 Liquid Glass Polaroid 1024px 원본을 `flutter_launcher_icons`로 Android 전 해상도에 생성.
- 버전: `pubspec.yaml`의 `version: 1.0.0+5` (versionName 1.0.0 / versionCode 5).
- 서명 배선: `android/app/build.gradle.kts`가 `android/key.properties`를 읽어 release 서명. **파일이 없으면 디버그 서명으로 폴백**(그래서 지금 빌드되는 AAB/APK는 디버그 서명 상태).
- AI 자동 태깅: **v1 미포함**(Firebase 미구성). `main.dart`가 try/catch로 방어하여 AI만 비활성, 나머지 정상. 이후 업데이트에서 추가 예정.

## ⚠️ 남은 필수 절차

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

### 4) Play Console 등록

1. [Play Console](https://play.google.com/console)에서 개발자 계정 생성(최초 1회, 등록비 $25).
2. 앱 만들기 → 앱 이름 "My Food Archive", 언어/무료 여부 설정.
3. **Play App Signing** 사용(기본 권장): 위 AAB를 업로드하면 Google이 앱 서명 키를 관리하고, 우리가 만든 건 "업로드 키"로 쓰인다.
4. 내부 테스트(Internal testing) 트랙에 AAB 업로드 → 테스터 등록 → 동작 확인 후 프로덕션 승격.

## 스토어 심사용 비(非)코드 준비물

- **개인정보처리방침 URL**: 앱이 사진(READ_MEDIA_IMAGES)에 접근하므로 필수. 데이터 세이프티 폼도 작성(로컬 저장, 서버 미전송임을 명시).
- **그래픽 리소스**: 512×512 앱 아이콘(스토어용), 피처 그래픽 1024×500, 스크린샷 최소 2장(에뮬레이터 캡처 활용 가능 — `build/verify/`에 참고 이미지 있음).
- **콘텐츠 등급 설문**, 대상 연령, 카테고리(음식/라이프스타일).

## AI(Firebase)를 이후 버전에 추가할 때

`docs/Implement_plan_android.md` Task 11 참조. 요약:
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=my-food-archive-dbc0c --platforms=android \
  --android-package-name=com.solkim.my_food_archive --yes
```
- **릴리스 빌드는 App Check가 Play Integrity**를 쓴다 → Firebase Console에서 **앱 서명 키의 SHA-256**(Play App Signing 사용 시 Play Console에서 확인 가능) 등록 필요.
- 추가 후 `versionCode`를 올려(예: `1.0.0+2`) 새 AAB 업로드.
