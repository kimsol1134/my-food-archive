# 📱 [마이 맛집 아카이브] MVP 기술 설계 문서 (TRD) — Android 앱 버전

> **이 문서의 위치**: iOS 완성본(`/Users/solkim/Dev/my-food-archive`)의 `docs/TRD.md`를 ground truth로 삼아, Android 앱 빌드 환경(Android Studio + Android 에뮬레이터)에 맞게 변환한 사본입니다.
> **변환 원칙**: 목차·패키지 선택·서비스 계층 구조는 원본과 동일. 플랫폼 의존적인 항목(권한 매니페스트, Photo Picker, Firebase Android 설정, App Check Provider, 빌드 환경)만 Android 기준으로 재작성.
> **디자인 가이드(`Design_guide.md`)는 양 플랫폼 공통**: iOS "Pure Native" 룩앤필을 Android에도 그대로 적용한다. `ThemeData.light()` 강제, `CupertinoAlertDialog`, `BouncingScrollPhysics`, `CupertinoIcons` 사용 — Material 다이얼로그/스낵바로 갈아끼우지 않는다.

## 1. 아키텍처 개요 (Architecture Overview)
본 앱은 별도 백엔드 서버를 운영하지 않는 **클라이언트 전용(Client-Side Only) 아키텍처**로 설계되었습니다. 모든 데이터는 기기 내부에 저장되며, 이미지 분석을 위한 Vision AI 통신은 **Firebase AI Logic**을 통해 Gemini Vision API를 호출합니다. Firebase가 API 키를 자체 서버에 보관하므로 클라이언트(앱)에는 키가 노출되지 않으며, App Check로 정상 앱의 요청만 허용합니다.

* **데이터 흐름 (Data Flow):**
    1. **사진 선택 및 EXIF 추출:** 사용자가 기기 갤러리에서 사진을 선택하면(Android 13+ Photo Picker 우선), 앱이 사진의 메타데이터(EXIF)에서 촬영 날짜와 GPS 좌표(위도/경도)를 추출합니다.
    2. **지오코딩 (역방향):** 추출된 GPS 좌표를 Android OS에 내장된 `Geocoder`(`geocoding` 패키지 경유)를 통해 텍스트 형태의 주소(예: 연남동, 역삼동)로 변환합니다.
    3. **AI Vision 분석:** 원본 이미지를 Firebase AI Logic을 통해 Gemini Vision 모델로 전송하여 '메뉴명'과 '카테고리'를 JSON 형태로 반환받습니다. App Check 토큰(Play Integrity 기반)이 함께 전송되어 정상 앱의 요청임이 검증됩니다.
    4. **데이터 검증 및 수동 입력:** AI가 추출한 데이터와 위치 정보를 UI(TextField)에 뿌려주어 사용자가 확인 및 수정할 수 있게 하고, '식당명'을 추가로 입력받습니다.
    5. **로컬 저장 및 검색 최적화:** 모든 데이터를 NoSQL 로컬 데이터베이스에 저장합니다. 이때 빠른 검색을 위해 입력된 모든 텍스트를 공백 없이 합친 `searchKeyword` 필드를 함께 생성하여 저장합니다.

## 2. 주요 모듈 및 컴포넌트 (Core Modules & Components)

### A. 데이터 모델 (Data Model)
* **`ArchiveItem` 클래스:**
    * `id`: 고유 식별자 (UUID 등)
    * `imagePath`: 기기 내부의 사진 저장 경로 (앱 전용 디렉토리 기준 상대 경로)
    * `restaurantName`: 식당명 (사용자 직접 입력)
    * `menuName`: 메뉴명 (AI 자동 추출 및 사용자 수정 가능)
    * `category`: 분류 (AI 자동 추출 및 사용자 수정 가능, 예: 한식, 카페)
    * `location`: 지역명 (EXIF 기반 지오코딩 및 사용자 수정 가능)
    * `date`: 방문 일자 (EXIF 기반)
    * `searchKeyword`: 검색용 통합 문자열 (예: "연남동오스테리아크림파스타양식")

### B. 서비스 계층 (Service Layer)
* **`PhotoService`:** Android 갤러리에 접근하여 선택된 사진을 앱 전용 디렉토리(`getApplicationDocumentsDirectory()` → `/data/data/<package>/app_flutter/images/`)로 복사합니다. Android 13(API 33)+에서는 `image_picker`가 **Android Photo Picker**(`PickVisualMedia`)를 사용하므로 별도의 저장소 권한 없이도 사진 EXIF가 보존된 채 접근됩니다. 구버전(API ≤ 32)에서는 `READ_EXTERNAL_STORAGE` 권한 다이얼로그가 표시됩니다.
* **`LocationService`:** 사진의 EXIF 데이터에서 추출한 좌표를 `geocoding` 패키지의 `placemarkFromCoordinates()`로 변환합니다. Android에서는 내부적으로 `android.location.Geocoder`가 호출되며 **별도 위치 권한이 필요 없습니다**(좌표 → 지명 변환이지 기기 GPS 조회가 아님). (실패 시 빈 문자열 반환)
* **`VisionAIService`:** Firebase AI Logic의 `firebase_ai` SDK로 Gemini Vision 모델을 호출합니다. API 키는 Firebase가 보관하므로 앱 코드/번들에 키가 들어가지 않습니다.
    * **[중요 프롬프트 지시]:** "제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. 응답은 반드시 `{"menu": "메뉴이름", "category": "카테고리명"}` 형태의 순수 JSON 포맷으로만 반환하라."
* **`LocalDBService`:** 로컬 DB(Hive)를 초기화하고, `ArchiveItem`의 CRUD(생성, 읽기, 수정, 삭제)를 담당합니다. 검색 시 `searchKeyword.contains(검색어)` 로직을 사용하여 쿼리 속도를 극대화합니다.

### C. UI 화면 (UI Screens)
> UI 스펙은 iOS 원본과 100% 동일합니다. 디자인 가이드의 "Pure Native(애플 순정 스타일)"를 Android 빌드에도 강제 적용합니다.

* **`HomeScreen` (메인 갤러리 뷰):**
    * 상단: 검색창 (`TextField`). 텍스트 입력 시 하단 그리드가 실시간으로 필터링됨. 안드로이드식 밑줄(Underline) 절대 금지.
    * 본문: `GridView.builder`를 사용한 사진 썸네일 바둑판 배열.
    * 하단: Floating Action Button (사진 추가). 56x56, Primary `#007AFF`.
* **`AddRecordScreen` (입력 및 AI 분석 화면):**
    * 진입 즉시 로딩 스피너(`CupertinoActivityIndicator`) 표시 (AI 분석 및 위치 추출 대기).
    * 완료 시: 사진 썸네일과 함께 식당명, 위치, 메뉴명, 카테고리를 입력/수정할 수 있는 `TextField` 목록 표시.
    * 하단: '저장' 버튼.
* **`DetailScreen` (상세 보기 화면):**
    * 사진 원본과 함께 저장된 텍스트 정보를 깔끔하게 나열하는 읽기 전용 뷰.
    * 삭제 확인은 Material `AlertDialog`가 아닌 **`CupertinoAlertDialog`** 사용.

## 3. 기술 스택 및 선택 근거 (Tech Stack)

| 구분 | 추천 패키지 | 선택 근거 |
| :--- | :--- | :--- |
| **프레임워크** | `Flutter` (SDK ^3.11.4) | 단일 코드베이스 — iOS 완성본의 Dart 코드를 그대로 재사용. |
| **상태 관리** | `Provider` | MVP 복잡도에 가장 적합. iOS 버전과 동일. |
| **로컬 DB** | `Hive` + `hive_flutter` | NoSQL. `getApplicationDocumentsDirectory()`가 Android에서도 동일하게 작동(앱 전용 영역). |
| **사진 및 메타데이터** | `image_picker` + `exif` | `image_picker` 1.1.x는 Android 13+에서 **Photo Picker**를 자동 사용하여 권한 없이 EXIF 보존된 원본 접근 가능. |
| **위치 변환** | `geocoding` | Android 내장 `Geocoder` 사용. 추가 비용/권한 없음. |
| **AI 비전** | `firebase_core` + `firebase_ai` + `firebase_app_check` | Firebase AI Logic 공식 SDK. App Check는 **Play Integrity**(release) / **Debug Provider**(debug) 사용. |
| **고유 ID** | `uuid` | iOS와 동일. |
| **로컬 경로** | `path_provider` | iOS와 동일. (Android에는 `path_provider_foundation` 오버라이드 불필요 — iOS 전용 픽스) |

## 4. [코딩 에이전트 필수 지시 사항] Android 권한 및 빌드 환경 설정

### 4.1 AndroidManifest 권한 설정
경로: `android/app/src/main/AndroidManifest.xml`
`<manifest>` 루트 아래, `<application>` 태그 바깥에 다음을 선언한다.

```xml
<!-- 인터넷: Firebase AI Logic / Gemini 호출용 -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Android 13 (API 33) 이상: Photo Picker가 기본 — 정식 미디어 권한은 폴백용 -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Android 14 (API 34) 이상: 사용자가 일부 사진만 선택 허용했을 때 -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />

<!-- Android 12 (API 32) 이하: 레거시 외부 저장소 권한 (Photo Picker 미지원 디바이스용) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

> **위치 권한 미포함**: 사진의 EXIF GPS 좌표를 디코딩한 뒤 `Geocoder`로 지명으로 변환하는 흐름이므로 `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`은 필요하지 않다. iOS 빌드에서 `NSLocationWhenInUseUsageDescription`을 추가하지 않은 것과 동일한 결정. (원본 코드 기준 `Info.plist`에 위치 권한 키가 실제로 존재하지 않음 — `mapping-report.md` 참조)

### 4.2 Photo Picker 동작 보장
`image_picker_android` 2.7+는 기본적으로 Photo Picker(`ACTION_PICK_IMAGES`)를 사용한다. 명시적으로 강제하려면 앱 시작 시점에 다음을 호출한다(선택 사항).

```dart
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void enforceAndroidPhotoPicker() {
  final picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }
}
```

### 4.3 빌드 환경 (Windows 호스트)
- **JDK**: 17 (Android Gradle Plugin 8+ 필수). `JAVA_HOME`을 JDK 17 경로로 설정.
- **Android Studio**: Hedgehog (2023.1.1) 이상.
- **Android SDK**:
  - `compileSdk = 36` — **Firebase 호환성 강제**. `firebase_app_check`가 끌어오는 `androidx.core:core-ktx:1.18.0` / `androidx.core:core:1.18.0`이 compileSdk 36 이상을 요구하므로 35로 두면 빌드 실패. (AVD 검증 2026-05-21 확정)
  - `minSdk` = **Flutter 기본값 유지 (현재 `flutter.minSdkVersion` = 24)**. 명시 숫자로 덮어쓰지 않아도 Firebase·image_picker 모두 정상 작동.
  - `targetSdk = 34` (Photo Picker 행동 확정)
- **Gradle 파일 위치**: `android/app/build.gradle.kts` (Kotlin DSL — Flutter 3.41 신 템플릿 기본). 플러그인 버전 선언은 `android/settings.gradle.kts`의 `plugins {}` 블록에 모인다(§4.4 참조).
- **Flutter SDK**: `^3.11.4` (iOS 빌드와 동일)
- **Windows 환경 변수**:
  - `ANDROID_HOME = %LOCALAPPDATA%\Android\Sdk`
  - `Path`에 `%ANDROID_HOME%\platform-tools`, `%ANDROID_HOME%\emulator` 추가
- **에뮬레이터 권장 디바이스**: Pixel 7 / API 34 (Android 14, Photo Picker 최신 동작 확인용) + Pixel 5 / API 30 (레거시 권한 다이얼로그 확인용) 2종.

### 4.3.1 화면 방향 (Orientation)
iOS 원본 `ios/Runner/Info.plist:58-63`의 `UISupportedInterfaceOrientations`는 **Portrait + LandscapeLeft + LandscapeRight** 3종을 허용한다(PortraitUpsideDown은 제외). Android에서는 매니페스트 단에서 동일한 정책을 강제하지 않고 **OS 기본 동작(센서 회전 허용)을 그대로 사용**한다.

- **권장 설정**: `android/app/src/main/AndroidManifest.xml`의 `<activity android:name=".MainActivity">`에 `android:screenOrientation`을 **선언하지 않는다**. Android 기본값(`unspecified`)이 iOS의 3종 허용과 사실상 동일한 사용자 경험을 제공한다.
- **위쪽 거꾸로(Upside Down) 금지를 엄격히 맞추고 싶다면**: `android:screenOrientation="userPortrait"`로 Portrait만 잠그거나 `android:screenOrientation="sensor"`(가속도계 4방향 허용)로 명시. 본 MVP는 iOS와 동일한 자유 회전 경험을 위해 기본값 유지를 권장.

### 4.3.2 디스플레이 주사율 (ProMotion / High Refresh Rate)
iOS 원본 `Info.plist:5`의 `CADisableMinimumFrameDurationOnPhone = true`는 iPhone 13 Pro 이상의 ProMotion 디스플레이에서 120Hz 렌더링을 허용하는 키다. **Android에는 1:1 대응 키가 없으며 OS가 자동 처리한다**.

- Android는 디스플레이가 지원하는 최대 주사율(60/90/120Hz)에 맞춰 Flutter 엔진이 자동으로 vsync를 잡는다. 매니페스트·Gradle·코드 어디에도 별도 설정 불필요.
- 고주사율 디스플레이를 가진 Pixel 6 Pro / Pixel 7 Pro 등에서도 Flutter 3.0+ 엔진은 기본적으로 90Hz/120Hz로 동작.
- 확인 방법: 에뮬레이터에서는 60Hz 고정이라 검증 불가. 실기기(고주사율 디바이스)에서 `adb shell dumpsys SurfaceFlinger | grep refresh-rate`로 확인 가능.

### 4.3.3 버전 코드 / 버전 네임
iOS 원본 `pubspec.yaml:19`의 `version: 1.0.0+5`는 Flutter 빌드 시 다음과 같이 **자동 매핑**된다(별도 Android 설정 불필요).

| pubspec | Android 매핑 | iOS 매핑 |
|---|---|---|
| `1.0.0` (build-name) | `versionName = "1.0.0"` (`android/app/build.gradle.kts`의 `flutter.versionName`) | `CFBundleShortVersionString` |
| `+5` (build-number) | `versionCode = 5` (`flutter.versionCode`) | `CFBundleVersion` |

- **수동 오버라이드 금지**: `android/app/build.gradle.kts`에 `versionCode`/`versionName` 하드코딩하면 pubspec 값이 무시된다. Flutter 표준대로 `flutter.versionCode`, `flutter.versionName`을 그대로 두고 pubspec만 갱신할 것.
- 출시 업데이트 시 `pubspec.yaml`의 `+숫자`를 단조 증가시켜야 Play Console 업로드가 통과한다(이미 1~5번이 iOS TestFlight에 사용됐다면 Android 초기 업로드는 `+6`부터 권장 — 두 스토어가 versionCode를 공유하지 않으므로 분리 채번도 가능).

### 4.4 Firebase Android 설정

**AVD 검증 결과(2026-05-21): `flutterfire configure` 명령 한 줄이 아래 5단계를 한꺼번에 자동 처리한다.** 과거 docs에 있던 "Android 앱 추가 → json 다운로드 → 폴더 배치 → Gradle classpath → app 모듈 plugin apply → flutterfire configure"의 6단계 분리 서술은 더 이상 정확하지 않다.

#### 4.4.1 한 줄 자동화 (Windows / macOS 동일)

```bash
flutterfire configure \
  --project=my-food-archive-dbc0c \
  --platforms=android \
  --android-package-name=com.solkim.my_food_archive \
  --yes
```

이 한 줄이 처리하는 것:

| # | 작업 | 산출물 / 변경 |
|---|---|---|
| 1 | Firebase 콘솔에 Android 앱 자동 등록 (Firebase Management API 호출) | `appId: 1:460952543906:android:...` 발급 |
| 2 | `google-services.json` 자동 다운로드 + 배치 | `android/app/google-services.json` (project_id, package_name 포함) |
| 3 | `lib/firebase_options.dart` Android case 자동 채움 | 기존 `throw UnsupportedError` 자리에 `apiKey/appId/projectId/messagingSenderId/storageBucket` 5개 필드 |
| 4 | `android/app/build.gradle.kts` plugins에 Google Services 적용 자동 주입 | `// START: FlutterFire Configuration` 주석 동봉 |
| 5 | (이미 설정돼 있을 경우) `android/settings.gradle.kts` plugins에 `com.google.gms.google-services` 버전 선언 확인 | Task 1에서 미리 `apply false`로 선언해두면 충돌 없음 |

**실측 시간**: 11초.

#### 4.4.2 SHA 등록 (CLI 자동, 3초)

```bash
# 1. SHA-1 / SHA-256 추출
#    Windows: keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
#    macOS/Linux:
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep -E "SHA[12]"

# 2. Firebase에 등록 (4.4.1 출력의 ANDROID_APP_ID 사용)
firebase apps:android:sha:create <ANDROID_APP_ID> <SHA-1>  --project=my-food-archive-dbc0c
firebase apps:android:sha:create <ANDROID_APP_ID> <SHA-256> --project=my-food-archive-dbc0c
```

Firebase CLI에 `apps:android:sha:create` / `apps:android:sha:list` / `apps:android:sha:delete`가 모두 있어 자동화가 가능하다.

#### 4.4.3 사람 직접 단계 (Firebase Console 1회 방문)

위 4.4.1 + 4.4.2가 끝난 뒤에도 사람이 브라우저로 Firebase Console을 열어야 하는 단계는 **최대 두 가지** — iOS 빌드 단계에서 AI Logic을 이미 활성화한 독자라면 사실상 **한 단계(App Check Debug 토큰 등록)뿐**이다:

1. **Firebase AI Logic + Gemini API 활성화** — 단, iOS 빌드 단계에서 이미 활성화했다면 추가 작업 없음.
2. **App Check Debug 토큰 등록** — §4.5 참조. Firebase CLI / flutterfire CLI 어디에도 App Check 토큰 등록 서브커맨드가 없으므로(2026-05 기준) 브라우저 콘솔 외 자동화 경로가 존재하지 않는다.

> **요점**: 패키지명을 `com.solkim.my_food_archive`로 잡고(iOS의 `com.solkim.myFoodArchive`와 별개) `flutterfire configure` 한 줄을 실행하면 콘솔·파일·Gradle 4개 자리를 한꺼번에 메운다. 책 본문에서는 이 자동화 수준을 분명히 강조해 독자가 "Firebase 콘솔에서 앱 추가 → json 다운로드 → 폴더에 옮기기"를 수동으로 헛수고하지 않게 안내한다.

### 4.5 App Check (Android = Play Integrity)
앱 진입점(`main.dart`)에서 디버그/릴리스 분기:
```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: kDebugMode
      ? AndroidProvider.debug
      : AndroidProvider.playIntegrity,
  // iOS 빌드도 동일 main.dart에서 함께 처리 (kDebugMode → debug, 아니면 appAttestWithDeviceCheckFallback)
);
```
- **Debug Provider 사용 절차**: 디버그 빌드 첫 실행 시 Logcat에 출력되는 토큰을 Firebase 콘솔 → App Check → Android 앱 → "관리"에서 등록.
- **Play Integrity 사용 절차**: Firebase 콘솔 → App Check → Android 앱에서 Play Integrity 활성화. Google Play Console에서 앱을 내부 테스트 트랙에 업로드해 SHA가 매칭되는지 확인.

### 4.6 예외 처리 강제 (Fail-Safe)
iOS 원본과 동일. 추가로 Android 특수 케이스:
- **Photo Picker 비지원 디바이스(API ≤ 32, GMS 미탑재 기기)**: `image_picker`가 자동 폴백 → `READ_EXTERNAL_STORAGE` 권한 다이얼로그가 뜬다. 사용자가 거부 시 `PhotoPickStatus.permissionDenied` 토스트.
- **Geocoder 서비스 미가용**: Google Play Services가 비활성화된 기기에서 `Geocoder.isPresent() == false`인 경우 빈 문자열 반환(기존 fail-safe로 이미 커버됨).
- **EXIF GPS 없음**: 위치 필드를 비워둔 상태로 UI 렌더링.
- **Firebase AI 실패 / App Check 거부 / 네트워크 끊김**: 타임아웃 15초 후 빈 폼 + "정보를 직접 입력해 주세요" 토스트.

## 5. 보안 (Security)
* **API 키 노출 방지:** Gemini API 키는 Firebase AI Logic이 Google 서버에 보관함. 앱 번들·소스코드·`.env` 어디에도 키가 들어가지 않으므로 디컴파일로도 추출 불가. (`firebase_options.dart`의 `apiKey` 필드는 Firebase 식별용 공개 키로, Gemini API 키와 별개.)
* **App Check (Android):** **Play Integrity** Provider가 Google Play 보안 검증을 통과한 앱 인스턴스만 토큰을 발급. 루팅 기기·복제 앱·디컴파일 앱의 무단 호출 차단. 디버그 빌드는 Debug Provider 토큰을 Firebase 콘솔에 사전 등록한 경우에만 허용.
* **클라이언트 코드 원칙:** API 키, 토큰, 시크릿을 코드/`.env`/주석 어디에도 두지 않음. Firebase 콘솔에서 1회 세팅 후 자동 관리. 따라서 클로드 코드 같은 AI 코딩 도구에 키 평문을 입력하는 시나리오 자체가 발생하지 않음.
* **저장 영역:** Hive Box와 복사된 이미지가 모두 앱 전용 저장소(`getApplicationDocumentsDirectory`)에 위치 → 다른 앱이 접근 불가, 앱 삭제 시 자동 제거.
