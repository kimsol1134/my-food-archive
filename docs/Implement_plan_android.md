# 📱 [마이 맛집 아카이브] MVP 구현 계획서 — Android 앱 버전

> **이 문서의 위치**: iOS 완성본의 `docs/Implement_plan.md`를 ground truth로 삼아, **Task 1·2·10만 Android 기준으로 변환**하고 나머지(Task 3~9, 11~17)는 Flutter 공통이므로 원본을 그대로 유지합니다.
> **완료 확인 환경**: 모든 "완료 확인 방법"은 **Android Studio 에뮬레이터(Pixel 7 / API 34, Pixel 5 / API 30 2종)** 기준으로 재서술했습니다.
> **호스트 예시**: Windows 11 + Android Studio Hedgehog+ + JDK 17 + Flutter SDK ^3.11.4. Mac에서도 Android Studio와 Android 에뮬레이터를 쓰면 같은 Android 앱 흐름으로 진행할 수 있습니다.

## 진행 체크리스트

- [ ] Task 1: Flutter 프로젝트 생성 및 패키지 의존성 추가 (Android 플랫폼 포함)
- [ ] Task 2: **Android 권한 설정 (AndroidManifest + Photo Picker)**
- [ ] Task 3: 컬러/타이포그래피 상수 및 앱 테마 설정
- [ ] Task 4: ArchiveItem 데이터 모델 및 Hive 로컬 DB 서비스
- [ ] Task 5: Provider 상태 관리 계층
- [ ] Task 6: HomeScreen UI (갤러리 그리드 + Empty State + FAB)
- [ ] Task 7: DetailScreen UI
- [ ] Task 8: AddEditRecordScreen UI (폼 레이아웃)
- [ ] Task 9: 3개 화면 간 네비게이션 연결
- [ ] Task 10: **사진 선택 서비스 및 EXIF 메타데이터 추출 (Android Photo Picker)**
- [ ] Task 11: Gemini Vision AI 서비스 연동 (Firebase AI Logic)
- [ ] Task 12: 저장 기능 완성 (Create + Update + searchKeyword 생성)
- [ ] Task 13: 삭제 기능 완성
- [ ] Task 14: 실시간 키워드 검색 기능
- [ ] Task 15: 사진 재선택 기능
- [ ] Task 16: 에러 처리, 토스트 메시지 마무리
- [ ] Task 17: 전체 통합 테스트 및 UI 폴리시

## 프로젝트 개요

백엔드 없이 기기 로컬에 모든 데이터를 저장하는 개인용 맛집 아카이브 Android 앱.
사진 업로드 시 EXIF에서 날짜/위치를 자동 추출하고, Firebase AI Logic을 통해 Gemini Vision API로 메뉴/카테고리를 자동 태깅하며, 사용자는 식당명만 입력하면 된다. API 키는 Firebase가 자체 보관하여 앱에 노출되지 않는다. UI는 iOS 빌드와 동일하게 "Pure Native(애플 순정)" 스타일을 강제한다.

## PRD 핵심 기능 5가지 (구현 범위)

| # | 기능 | 설명 |
|---|------|------|
| ① | 사진 업로드 + EXIF 추출 | Android Photo Picker로 사진 선택, EXIF에서 날짜/GPS 자동 추출 |
| ② | Vision AI 자동 태깅 | Firebase AI Logic을 통해 Gemini Vision API로 메뉴명/카테고리 자동 분류 (키 노출 없음) |
| ③ | 최소 수동 입력 | 식당 이름만 직접 타이핑 |
| ④ | 키워드 검색 | 지역+메뉴+식당명 조합 실시간 필터링 |
| ⑤ | 갤러리 뷰 | Grid 형태 사진 썸네일 나열 + 상세 보기 |

> **범위 외 기능:** 알림, 지도 연동, SNS 공유, 다크모드, 백엔드 서버 등은 MVP에 포함하지 않는다.

## 태스크 의존성 다이어그램

```
Task 1 (프로젝트 생성 + Android 빌드 설정)
 └─> Task 2 (Android 권한 + Photo Picker)
 └─> Task 3 (상수 + 테마)
      └─> Task 4 (데이터 모델 + Hive)
           └─> Task 5 (Provider 상태 관리)
                ├─> Task 6 (HomeScreen UI)
                ├─> Task 7 (DetailScreen UI)
                └─> Task 8 (AddEditRecordScreen UI)
                     └─> Task 9 (네비게이션 연결) ← Task 6, 7도 필요
                          └─> Task 10 (사진 선택 + EXIF, Android 폴백 포함)
                               └─> Task 11 (Firebase AI Logic + Gemini)
                                    └─> Task 12 (저장 기능)
                                         ├─> Task 13 (삭제 기능)
                                         ├─> Task 14 (검색 기능)
                                         └─> Task 15 (사진 재선택)
                                              └─> Task 16 (에러 처리 마무리)
                                                   └─> Task 17 (통합 테스트)
```

## 예상 디렉토리 구조

```
lib/
├── main.dart
├── constants/
│   ├── app_colors.dart
│   └── app_text_styles.dart
├── models/
│   ├── archive_item.dart
│   ├── archive_item.g.dart (자동 생성)
│   ├── exif_result.dart
│   └── ai_result.dart
├── services/
│   ├── local_db_service.dart
│   ├── photo_service.dart
│   ├── exif_service.dart
│   ├── location_service.dart
│   └── vision_ai_service.dart
├── providers/
│   └── archive_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── add_edit_record_screen.dart
└── widgets/
    ├── archive_grid_card.dart
    └── toast_message.dart

android/
├── app/
│   ├── google-services.json  ← Firebase 콘솔에서 다운로드
│   ├── build.gradle.kts      ← Google Services 플러그인 적용
│   └── src/main/AndroidManifest.xml  ← 권한 선언
└── settings.gradle.kts   ← Google Services 플러그인 (Flutter 3.41+ plugins{} 블록)
```

---

## Task 1: Flutter 프로젝트 생성 및 패키지 의존성 추가

**목표:** Flutter 프로젝트를 Android 플랫폼 포함으로 생성하고 MVP에 필요한 모든 패키지를 설치한다.

**구현할 기능:**
- Windows 명령 프롬프트(또는 PowerShell)에서:
  - `flutter create --platforms android my_food_archive`
  - 또는 기존 iOS 프로젝트에 Android 플랫폼 추가: `flutter create --platforms android .`
- `pubspec.yaml`에 필수 패키지 추가 (iOS 버전과 거의 동일, **단 1종 제외**):
  - `provider` (상태 관리)
  - `hive`, `hive_flutter` (로컬 DB)
  - `image_picker` (Android 13+ Photo Picker 자동 사용)
  - `exif` (EXIF 메타데이터 추출)
  - `geocoding` (역지오코딩 — Android Geocoder)
  - `firebase_core`, `firebase_ai`, `firebase_app_check`
  - `uuid` (고유 ID 생성)
  - `path_provider` (앱 전용 저장 경로)
- **명시적 제외**: `google_generative_ai`는 iOS 원본 `pubspec.yaml:41`에 잔재로 남아있으나 실제 코드(`lib/services/vision_ai_service.dart`)는 `firebase_ai` SDK만 사용한다. Android 빌드에는 추가하지 말 것 — APK 크기 + 빌드 시간만 늘어남.
- `dev_dependencies`에 추가: `hive_generator`, `build_runner`
- **`android/app/build.gradle.kts` 핵심 설정**:
  - `compileSdk = 36`
    > **사유**: `firebase_app_check`가 끌어오는 `androidx.core:core-ktx:1.18.0` / `androidx.core:core:1.18.0`가 **compileSdk 36 이상을 강제**한다. 35로 두면 `Dependency 'androidx.core:core-ktx:1.18.0' requires libraries and applications that depend on it to compile against version 36 or later of the Android APIs.` 에러로 두 번째 빌드에서 실패. (AVD 검증 2026-05-21 확정)
  - `minSdk` = **Flutter 기본값 유지 (현재 `flutter.minSdkVersion` = 24)** — `flutter create` 템플릿이 자동으로 채우므로 명시 숫자로 덮어쓰지 않아도 됨. Firebase·image_picker 모두 24에서 정상 동작.
  - `targetSdk = flutter.targetSdkVersion` — 2026년 7월 기준 Google Play 제출 최소값(API 35 이상)을 만족하는지 배포 직전에 확인
  - `applicationId = "com.solkim.my_food_archive"` (Firebase Android 등록과 일치)
  - Java 17 source/target compatibility (Flutter 3.41 템플릿이 기본 설정)
- **`android/settings.gradle.kts`의 `plugins {}` 블록에 Google Services classpath 선언만 추가** (Firebase 적용은 Task 11에서):
  ```kotlin
  plugins {
      // ...flutter, android, kotlin 기본 항목 그대로 두고 한 줄 추가
      id("com.google.gms.google-services") version "4.4.2" apply false
  }
  ```
  > **⚠️ Flutter 3.41 신 템플릿 변경 — 위치 주의**: 과거에는 `android/build.gradle.kts`(프로젝트 레벨)에 classpath를 적었으나, Flutter 3.41 이후 신 템플릿은 **`android/settings.gradle.kts`의 `plugins {}` 블록**으로 모인다. 옛 경로에 넣으면 Gradle Sync 실패. (AVD 검증 2026-05-21 확정)
- **iOS 전용 오버라이드**: `pubspec.yaml`의 `dependency_overrides`에 있던 `path_provider_foundation: 2.5.1`은 iOS 전용 픽스. Android 단독 빌드에서는 처음부터 넣지 않아도 무방.

**예상 수정 파일:**
- `pubspec.yaml`
- `android/app/build.gradle.kts`
- `android/settings.gradle.kts`

**완료 확인 방법:**
- Windows에서 `flutter pub get` 에러 없이 완료
- `flutter pub deps | findstr image_picker_android` 결과에 `image_picker_android 0.8.13` 이상(=Photo Picker 기본 활성 버전, transitive 의존)이 잡힘 *(macOS/Linux에서는 `grep image_picker_android`)*
- `flutter build apk --debug` 빌드 성공 *(AVD 검증 실측: 첫 빌드 1m 31s, incremental 3~9초)*
- Android Studio에서 프로젝트 import 시 Gradle Sync 정상 완료

---

## Task 2: Android 권한 설정

**목표:** 광범위한 사진 권한 없이 Android Photo Picker로 사용자가 고른 사진 한 장에만 접근하도록 보장한다.

**구현할 기능:**
- `android/app/src/main/AndroidManifest.xml`의 `<manifest>` 루트 아래(`<application>` 태그 바깥)에 권한 선언:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```
- **사진·위치 권한 미선언**: `READ_MEDIA_IMAGES`, `READ_MEDIA_VISUAL_USER_SELECTED`, `READ_EXTERNAL_STORAGE`, `ACCESS_FINE_LOCATION`을 포함하지 않는다. Photo Picker가 선택된 파일의 임시 접근 권한을 전달한다.
- (선택) `main()`에서 `ImagePickerPlatform.instance`가 `ImagePickerAndroid`인 경우 `useAndroidPhotoPicker = true`를 강제. 기본값이 true지만 명시적으로 두면 향후 패키지 업데이트에도 안전.
- **권한 거부 시 안내**: `PhotoService`에서 `PlatformException`의 `code`에 `denied`/`access`가 포함되면 `PhotoPickStatus.permissionDenied`로 매핑(iOS 원본 코드와 동일 분기).

**예상 수정 파일:**
- `android/app/src/main/AndroidManifest.xml`
- (선택) `lib/main.dart` (Photo Picker 강제 활성화)

**완료 확인 방법:**
- **Pixel 7 / API 34 에뮬레이터**: FAB 탭 시 권한 다이얼로그 없이 Photo Picker 시트가 바로 올라옴(상단에 "사진 및 동영상" 헤더).
- **구형 기기 확인**: Google Play 서비스가 제공하는 Photo Picker 백포트 또는 `image_picker`의 시스템 선택기 폴백이 열리는지 확인한다. 앱 자체의 광범위한 저장소 권한 팝업은 요구하지 않는다.
- Logcat에 위치 권한 관련 오류 메시지가 출력되지 않음.

---

## Task 3: 컬러/타이포그래피 상수 및 앱 테마 설정

**목표:** 디자인 가이드에 정의된 컬러 시스템과 타이포그래피를 상수로 정의하고, 라이트 모드를 강제 적용한다. (Android에서도 iOS 원본과 동일하게 Pure Native 룩 유지)

**구현할 기능:**
- `lib/constants/app_colors.dart` 생성:
  - Primary `#007AFF`, Background `#FFFFFF`, Surface `#F2F2F7`
  - TextMain `#000000`, TextSub `#8E8E93`, Divider `#C6C6C8`, Destructive `#FF3B30`
- `lib/constants/app_text_styles.dart` 생성:
  - Large Title: fontSize 28, bold, letterSpacing -0.5
  - Title: fontSize 22, bold
  - Body: fontSize 17, w400
  - Label: fontSize 15, w600
  - Caption: fontSize 13, w400, TextSub 컬러
- `lib/main.dart` 설정:
  - `ThemeData.light()` 기반 테마, `themeMode: ThemeMode.light` 강제
  - `ScrollConfiguration` 래핑으로 전역 `BouncingScrollPhysics` 적용 (Android 기본 ClampingScrollPhysics를 덮어씀)
  - **글자 크기 확대 상한 적용**: `MaterialApp.builder`에서 `MediaQuery`로 감싸 `textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.2)` 설정. Android는 시스템 설정 → 디스플레이 → 글꼴 크기를 최대 200%까지 키울 수 있어 레이아웃이 깨지므로 iOS 원본(`lib/main.dart:62-71`)과 동일하게 1.2배 상한 강제.
  - 커스텀 폰트 없음 (시스템 기본 폰트 — Android는 Roboto, iOS는 SF Pro)

**예상 수정 파일:**
- `lib/constants/app_colors.dart` (신규)
- `lib/constants/app_text_styles.dart` (신규)
- `lib/main.dart`

**완료 확인 방법:**
- Android 에뮬레이터에서 흰색 배경의 빈 화면 표시
- 에뮬레이터를 다크모드로 전환해도 앱은 라이트 모드 유지
- 스크롤 시 iOS식 바운스 효과 확인(Android 기본 글로우 이펙트 X)
- 에뮬레이터 설정 → 디스플레이 → 글꼴 크기를 "가장 크게(200%)"로 변경 후 앱 재진입 → 글자가 약 1.2배까지만 커지고 레이아웃이 깨지지 않음

---

## Task 4: ArchiveItem 데이터 모델 및 Hive 로컬 DB 서비스

**목표:** 맛집 기록 데이터 모델을 정의하고, Hive 기반 CRUD 서비스를 구현한다.

**구현할 기능:**
- `lib/models/archive_item.dart` 생성:
  - 필드: `id`(String/UUID), `imagePath`(String), `restaurantName`(String), `menuName`(String), `category`(String), `location`(String), `date`(DateTime?), `searchKeyword`(String)
  - Hive TypeAdapter 어노테이션: `@HiveType(typeId: 0)` + `@HiveField(0)` ~ `@HiveField(7)` (필드 8개)
  - `generateSearchKeyword()` 메서드: 모든 텍스트 필드를 공백 없이 병합
- `build_runner`로 `archive_item.g.dart` 자동 생성
- `lib/services/local_db_service.dart` 생성:
  - Box 이름 상수: `static const String _boxName = 'archiveItems';` (iOS 원본 `lib/services/local_db_service.dart:6`과 동일 — camelCase 유지, snake_case로 바꾸면 기존 데이터 호환 깨짐)
  - `initDB()`: Hive 초기화 및 `Hive.openBox<ArchiveItem>('archiveItems')`
  - `addItem(ArchiveItem)`: Insert
  - `updateItem(ArchiveItem)`: Update
  - `deleteItem(String id)`: Delete
  - `getAllItems()`: 전체 조회 (최신순 정렬)
  - `searchItems(String query)`: `searchKeyword.contains(query)` 필터링

**예상 수정 파일:**
- `lib/models/archive_item.dart` (신규)
- `lib/models/archive_item.g.dart` (자동 생성)
- `lib/services/local_db_service.dart` (신규)
- `pubspec.yaml` (dev_dependencies 확인)

**완료 확인 방법:**
- Windows에서 `dart run build_runner build` 에러 없이 `archive_item.g.dart` 생성
- 생성된 `archive_item.g.dart`에 `class ArchiveItemAdapter extends TypeAdapter<ArchiveItem>` + `final int typeId = 0;`이 포함됨
- 컴파일 에러 없음
- (다음 Task 5에서 검증) 앱 첫 실행 후 `adb shell run-as com.solkim.my_food_archive ls app_flutter/`에 Hive 파일 `archiveItems.hive` + `archiveItems.lock` 생성 확인

---

## Task 5: Provider 상태 관리 계층

**목표:** UI와 LocalDBService 사이의 상태 관리 계층을 구축한다.

**구현할 기능:**
- `lib/providers/archive_provider.dart` 생성:
  - `ChangeNotifier` 상속
  - 내부 상태: `List<ArchiveItem> _items`, `List<ArchiveItem> _filteredItems`, `String _searchQuery`, `bool _isLoading`
  - `loadItems()`: DB 전체 조회 → `_items` 갱신 → `notifyListeners()`
  - `addItem(ArchiveItem)`, `updateItem(ArchiveItem)`, `deleteItem(String id)`: DB 작업 후 `loadItems()` 재호출
  - `search(String query)`: 검색어로 `_filteredItems` 필터링 → `notifyListeners()`
  - getter `items`: 검색어 있으면 `_filteredItems`, 없으면 `_items` 반환
- `main.dart`에 `ChangeNotifierProvider<ArchiveProvider>` 등록
- `main()` 함수에서 **다음 순서로 초기화** (iOS 원본 `lib/main.dart:14-29`과 동일):
  1. `WidgetsFlutterBinding.ensureInitialized()`
  2. `await AppPaths.init()` — `lib/utils/app_paths.dart`의 정적 헬퍼. `getApplicationDocumentsDirectory()` 결과를 한 번만 캐싱하여 `imagePath`(상대 경로) → 절대 경로 변환에 사용. **이 호출이 빠지면 `Image.file`이 LateInitializationError로 크래시**.
  3. `await Firebase.initializeApp(...)` (Task 11에서 추가)
  4. `await FirebaseAppCheck.instance.activate(...)` (Task 11에서 추가)
  5. `LocalDBService().initDB()` — Hive 초기화 + TypeAdapter 등록 + Box 열기
  6. `runApp(MyApp(dbService: dbService))`
- `lib/utils/app_paths.dart` 신규 생성 (iOS 원본과 100% 동일 — 플랫폼 무관):
  ```dart
  class AppPaths {
    static late final String documentsDir;
    static Future<void> init() async {
      final dir = await getApplicationDocumentsDirectory();
      documentsDir = dir.path;
    }
    static String resolve(String relativePath) => '$documentsDir/$relativePath';
  }
  ```

**예상 수정 파일:**
- `lib/providers/archive_provider.dart` (신규)
- `lib/utils/app_paths.dart` (신규)
- `lib/main.dart` (Provider 등록, AppPaths.init, Hive 초기화)

**완료 확인 방법:**
- 앱 실행 시 Hive 초기화 에러 없음 (Logcat 확인)
- Logcat에 `LateInitializationError: Field 'documentsDir' has not been initialized` 메시지가 출력되지 않음 — 출력되면 `AppPaths.init()` 호출 순서가 잘못된 것
- `ArchiveProvider`가 위젯 트리에서 접근 가능
- `flutter run` 빌드 및 실행 성공

---

## Task 6: HomeScreen UI (갤러리 그리드 + Empty State + FAB)

**목표:** 홈 화면의 기본 레이아웃을 구현한다.

**구현할 기능:**
- `lib/screens/home_screen.dart` 생성:
  - 상단 검색 `TextField`: Surface 배경, borderRadius 10, 좌측 돋보기 아이콘, 높이 36px, 밑줄 없음 (Material `InputDecoration.collapsed` 또는 `border: InputBorder.none` 사용)
  - 본문: `Consumer<ArchiveProvider>`로 데이터 상태 분기
    - Empty State (0개): 중앙 `CupertinoIcons.photo_on_rectangle`(64px) + "아직 저장된 맛집이 없어요." (TextSub 컬러)
    - Data State: `GridView.builder` (crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 16)
  - FAB: 우측 하단, 56x56, Primary 배경, 그림자 `blurRadius: 10`
  - 전역 `BouncingScrollPhysics`
- `lib/widgets/archive_grid_card.dart` 생성:
  - 사진 썸네일 (`BoxFit.cover`, borderRadius 8)
  - 식당명 (Label 스타일, maxLines 1, ellipsis)
  - 지역명 (Caption 스타일)

**예상 수정 파일:**
- `lib/screens/home_screen.dart` (신규)
- `lib/widgets/archive_grid_card.dart` (신규)
- `lib/main.dart` (home 화면 지정)

**완료 확인 방법:**
- Android 에뮬레이터에서 Empty State 화면 정상 표시
- 검색창이 iOS 스타일로 렌더링 (Surface 배경, Material 언더라인 없음)
- FAB 버튼이 우측 하단에 파란색으로 표시

---

## Task 7: DetailScreen UI

**목표:** 맛집 상세 보기 화면을 구현한다.

**구현할 기능:**
- `lib/screens/detail_screen.dart` 생성:
  - 파라미터: `ArchiveItem` 객체
  - AppBar: 좌측 뒤로가기, 우측 수정(`CupertinoIcons.pencil`) + 삭제(`CupertinoIcons.trash`, Destructive 컬러)
  - Body (`SingleChildScrollView` + `BouncingScrollPhysics`):
    - 원본 이미지: `Image.file`, 최대 높이 화면 40%
    - 식당명: Title 스타일 (22px bold)
    - 메뉴명, 카테고리, 지역, 날짜: Body 스타일, 수직 나열, 간격 8px
  - 삭제 탭: `CupertinoAlertDialog` "정말 삭제하시겠습니까?" 확인
  - 수정 탭: AddEditRecordScreen 수정 모드로 이동 (Task 9에서 연결)

**예상 수정 파일:**
- `lib/screens/detail_screen.dart` (신규)

**완료 확인 방법:**
- 하드코딩 테스트 데이터로 DetailScreen 진입 시 사진 + 텍스트 정보 렌더링
- 삭제 버튼 탭 시 `CupertinoAlertDialog` 표시 (Material `AlertDialog`가 아님)

---

## Task 8: AddEditRecordScreen UI (폼 레이아웃)

**목표:** 기록 추가/수정 통합 화면의 UI를 구현한다.

**구현할 기능:**
- `lib/screens/add_edit_record_screen.dart` 생성:
  - 파라미터: `ArchiveItem?` (null = 생성 모드, 값 있음 = 수정 모드)
  - AppBar: 좌측 '취소' 버튼 (`Navigator.pop`)
  - Body (`SingleChildScrollView` + `BouncingScrollPhysics`):
    - 사진 미리보기 영역 (선택된 사진 또는 빈 플레이스홀더)
    - 식당명 TextField (필수 입력): CupertinoTextField 스타일, Surface 배경, borderRadius 10, padding 가로12 세로12, 밑줄/테두리 없음
    - 지역 TextField (EXIF 값 pre-fill 예정)
    - 메뉴명 TextField (AI 값 pre-fill 예정)
    - 카테고리 TextField (AI 값 pre-fill 예정)
    - 날짜 표시 (읽기 전용)
  - 하단 '저장' 버튼:
    - 식당명 비어있으면: 배경 TextSub, onPressed null
    - 식당명 입력됨: 배경 Primary
  - 수정 모드: 기존 데이터로 모든 TextField 초기값 설정
  - `GestureDetector` 래핑: 빈 영역 터치 시 `FocusScope.of(context).unfocus()`

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart` (신규)

**완료 확인 방법:**
- 식당명 비어있을 때 저장 버튼 회색 비활성화
- 식당명 입력 시 저장 버튼 파란색 활성화
- 빈 영역 터치 시 Android 소프트 키보드 숨김 동작

---

## Task 9: 3개 화면 간 네비게이션 연결

**목표:** HomeScreen, DetailScreen, AddEditRecordScreen 간의 모든 네비게이션 경로를 연결한다.

**구현할 기능:**
- HomeScreen:
  - 갤러리 카드 탭 → `Navigator.push` → DetailScreen(item)
  - FAB 탭 → AddEditRecordScreen(null) (사진 선택은 Task 10)
- DetailScreen:
  - 수정 아이콘 탭 → `Navigator.push` → AddEditRecordScreen(existingItem)
  - 삭제 확인 후 → `Navigator.pop()` → 홈 복귀
- AddEditRecordScreen:
  - 취소 버튼 → `Navigator.pop()`
  - 저장 완료 후 → `Navigator.popUntil` → 홈 화면까지 복귀

**예상 수정 파일:**
- `lib/screens/home_screen.dart`
- `lib/screens/detail_screen.dart`
- `lib/screens/add_edit_record_screen.dart`

**완료 확인 방법:**
- 홈 → 카드 탭 → 상세 화면 이동
- 상세 → 수정 → 수정 화면 이동 (기존 데이터 pre-fill)
- 수정 화면 → 취소 → 이전 화면 복귀
- 상세 → 삭제 → 확인 팝업 → 승인 → 홈 복귀

---

## Task 10: 사진 선택 서비스 및 EXIF 메타데이터 추출

**목표:** Android Photo Picker에서 사진을 선택하고, EXIF에서 촬영 날짜와 GPS 좌표를 추출한 뒤, 역지오코딩으로 동/구 텍스트로 변환한다.

**구현할 기능:**
- `lib/services/photo_service.dart` 생성:
  - `pickImage()`: `ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90)` 호출
  - Android 13+에서는 자동으로 Photo Picker 사용 → 권한 다이얼로그 미발생
  - 호환 기기에서는 시스템 또는 라이브러리의 선택 UI를 사용하며 광범위한 저장소 권한은 요청하지 않음
  - 선택된 이미지를 `getApplicationDocumentsDirectory()` 하위 `images/`로 복사 (UUID 파일명 + 확장자 보존)
  - `PlatformException` 발생 시 취소/일시 오류/접근 실패를 구분해 사용자에게 재시도 안내
  - 취소 → `PhotoPickStatus.cancelled`, 기타 예외 → `PhotoPickStatus.error`
  - 허용 확장자: `.jpg, .jpeg, .png, .webp`를 우선 처리. HEIC/HEIF 원본은 `image_picker`가 갤러리에서 가져올 때 Android의 미디어 디코더가 알아서 JPEG로 변환해주므로 별도 처리 불필요 (iOS 원본 `lib/services/photo_service.dart:18-25`의 확장자 화이트리스트는 그대로 유지 — 변환 실패 시 폴백용)
- `lib/services/exif_service.dart` 생성:
  - `extractMetadata(String filePath)`: `package:exif`의 `readExifFromBytes()` 사용
  - 촬영 날짜(`DateTime`) 추출: `EXIF DateTimeOriginal` 또는 `Image DateTime`
  - GPS 좌표(위도/경도) 추출: `GPS GPSLatitude/Longitude` + `Ref`, DMS → 십진수 변환
  - **Fail-Safe**: 태그 없음/파싱 실패 → `ExifResult()` 빈 결과
- `lib/models/exif_result.dart` 생성: `DateTime? date`, `double? latitude`, `double? longitude`
- `lib/services/location_service.dart` 생성:
  - `reverseGeocode({lat, lng})`: 첫 호출 시 `setLocaleIdentifier('ko_KR')` 적용 후 `placemarkFromCoordinates(lat, lng)` 호출
  - 반환 우선순위: `subLocality > thoroughfare > locality > subAdministrativeArea`
  - **Fail-Safe**: `Geocoder` 미가용/실패 → 빈 문자열
- HomeScreen FAB 연결:
  - FAB 탭 → `PhotoService.pickAndPersistImage()` → `success` → AddEditRecordScreen(생성 모드, imagePath 전달)
  - `cancelled` → 홈 유지
  - `permissionDenied` → "설정에서 사진 권한을 허용해 주세요" 토스트

**예상 수정 파일:**
- `lib/services/photo_service.dart` (신규)
- `lib/services/exif_service.dart` (신규)
- `lib/services/location_service.dart` (신규)
- `lib/models/exif_result.dart` (신규)
- `lib/screens/home_screen.dart`
- `lib/screens/add_edit_record_screen.dart`

**완료 확인 방법:**
- **Pixel 7 / API 34 에뮬레이터**:
  - FAB 탭 시 권한 다이얼로그 없이 Photo Picker 시트가 표시됨
  - GPS 정보가 있는 샘플 사진 선택 → AddEditRecord 진입 시 날짜/지역 필드 자동 채움
  - 스크린샷(EXIF 없음) 선택 → 날짜/지역 필드 비어있되 앱 크래시 없음
- **Pixel 5 / API 30 에뮬레이터**:
  - FAB 탭 시 광범위한 저장소 권한 없이 시스템 또는 호환 사진 선택 UI 표시
  - 사진 선택 취소 → 홈 유지
  - 사진 선택 → 동일한 저장·EXIF 처리 흐름 확인
- 사진 선택 취소(뒤로가기) 시 홈 화면 유지
- `adb shell run-as com.solkim.my_food_archive ls app_flutter/images/`로 복사된 파일 확인 가능

---

## Task 11: Gemini Vision AI 서비스 연동 (Firebase AI Logic)

**목표:** Firebase AI Logic을 통해 Gemini Vision 모델을 호출하여 음식 사진에서 메뉴명과 카테고리를 자동 추출한다. API 키는 Firebase가 보관하므로 앱 코드/번들에 노출되지 않는다.

### 📦 자동 vs 수동 (AVD 검증 2026-05-21 실측)

| 단계 | 자동/수동 | 명령·도구 | 실측 시간 |
|---|---|---|---|
| ① Firebase 콘솔 Android 앱 등록 | 🤖 자동 | `flutterfire configure ...` 가 Firebase Management API로 자동 생성 | 단일 명령 11초에 포함 |
| ② `google-services.json` 다운로드·배치 | 🤖 자동 | 위 명령이 내부적으로 `apps:sdkconfig` 호출 → `android/app/google-services.json` 자동 배치 | (위에 포함) |
| ③ `lib/firebase_options.dart` Android case 채움 | 🤖 자동 | 위 명령 산출물 | (위에 포함) |
| ④ `android/app/build.gradle.kts` plugins에 `com.google.gms.google-services` 적용 | 🤖 자동 | 위 명령이 `// START: FlutterFire Configuration` 주석 동봉해서 자동 주입 | (위에 포함) |
| ⑤ SHA-1 / SHA-256 디버그 키 등록 | 🤖 자동 | `keytool` 추출 + `firebase apps:android:sha:create <appId> <hash>` (CLI 2회) | 3초 |
| ⑥ Firebase AI Logic + Gemini API 활성화 | ✋ 사람 수동 🌐 콘솔 | Firebase Console → AI Logic 활성화 (iOS 빌드 단계에서 이미 했다면 추가 작업 없음) | (이전에 활성화돼 있으면 0초) |
| ⑦ App Check Debug 토큰 등록 | ✋ **사람 수동 🌐 콘솔** | `adb logcat`으로 토큰 추출은 자동 가능, **등록은 반드시 Firebase Console → App Check → Android 앱 → "Manage debug tokens"** | 1~2분 (브라우저 작업) |
| ⑧ Play Integrity 연결 | ✋ **사람 수동 🌐 콘솔** | Play Console 앱 무결성에서 Cloud 프로젝트 연결 → Firebase App Check Android 앱에 Play Integrity 등록 | 2~5분 |
| ⑨ 앱 서명 SHA-256 등록 | 🤖+✋ | Play App Signing의 앱 서명 인증서 SHA-256을 Firebase Android 앱에 등록 | 1~2분 |
| ⑩ AI Logic enforcement 실기기 확인 | ✋ | 내부 테스트 설치본에서 음식 사진 1장 분석 성공 확인. 2026년 7월 이후 안내 마법사는 enforcement를 자동 적용할 수 있음 | 2분 |

> **핵심 메시지**: `flutterfire configure --project=my-food-archive-dbc0c --platforms=android --android-package-name=com.solkim.my_food_archive --yes` **한 줄이 ①~④ 네 단계를 한꺼번에 처리**한다. 사람이 브라우저로 Firebase 콘솔에서 "Android 앱 추가" 버튼을 누르거나 `google-services.json`을 수동으로 다운로드해 폴더에 옮길 필요가 없다.
>
> 사람 손이 들어가는 단계는 AI Logic 활성화, Debug 토큰 등록, Play Integrity/Cloud 프로젝트 연결, 내부 테스트 설치본 검증이다. 파일 생성은 자동화할 수 있지만 콘솔 보안 연결과 실제 기기 검증은 생략할 수 없다.

### 사전 준비 (한 번만)

```bash
# FlutterFire CLI 설치 (이미 설치돼 있으면 생략)
dart pub global activate flutterfire_cli

# Firebase CLI 로그인 (이미 로그인돼 있으면 생략)
firebase login
```

### 자동화 단계 (Claude Code가 실행)

```bash
# 1. flutterfire configure 한 줄로 ①~④ 일괄 처리
flutterfire configure \
  --project=my-food-archive-dbc0c \
  --platforms=android \
  --android-package-name=com.solkim.my_food_archive \
  --yes

# 2. 디버그 SHA-1 / SHA-256 추출
#    Windows: keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
#    macOS/Linux:
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep -E "SHA[12]"

# 3. SHA 등록 (Android appId는 flutterfire configure 출력에 표시됨)
firebase apps:android:sha:create <ANDROID_APP_ID> <SHA-1> --project=my-food-archive-dbc0c
firebase apps:android:sha:create <ANDROID_APP_ID> <SHA-256> --project=my-food-archive-dbc0c
```

### 사람 직접 단계 (브라우저 콘솔 + 실제 기기)

1. AVD에서 디버그 빌드 첫 실행 후 Logcat에서 토큰 추출:
   ```bash
   adb logcat | grep -i "DebugAppCheckProvider"
   # 출력 예: Enter this debug secret into the allow list in the Firebase Console for your project: <UUID 토큰>
   ```
2. **브라우저에서 Firebase Console 접속** → 프로젝트 `my-food-archive-dbc0c` → **App Check** → Android 앱 → 더보기(⋮) → **"Manage debug tokens"** → 추출한 UUID + 이름(예: `pixel7_api34`) 입력 → 저장.
3. 앱 재실행 → AI 호출이 정상 응답을 받음.
4. **Play Console → 앱 무결성 → Play Integrity API**에서 Firebase/Google Cloud 프로젝트를 연결한다.
5. **Play App Signing의 앱 서명 인증서 SHA-256**을 Firebase Android 앱에 등록한다.
6. Firebase Console → App Check → API에서 **Firebase AI Logic enforcement** 상태를 확인한다.
7. 내부 테스트 링크로 설치한 릴리스 앱에서 음식 사진 1장을 분석해 메뉴명/카테고리 자동 채움이 성공하는지 확인한다.

### 구현할 기능 (앱 코드)

- `lib/main.dart` 초기화:
  - `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  - `await FirebaseAppCheck.instance.activate(androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity, appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttestWithDeviceCheckFallback)`
- `lib/services/vision_ai_service.dart` 생성:
  - `firebase_ai` SDK로 Gemini Vision: `FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash', generationConfig: GenerationConfig(responseMimeType: 'application/json', temperature: 0.2))`
  - `analyzeImage(String imagePath)`:
    - 이미지 파일을 바이트로 읽어 `Content.multi([TextPart(prompt), InlineDataPart(mimeType, bytes)])` 호출
    - 프롬프트: "제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. 응답은 반드시 `{"menu": "메뉴이름", "category": "카테고리명"}` 형태의 순수 JSON 포맷으로만 반환하라."
    - 응답 JSON 파싱 → `AiResult` 모델 반환
  - **Fail-Safe**: 타임아웃 15초, 네트워크 오류/Firebase AI 실패/JSON 파싱 실패/App Check 토큰 거부 시 null 반환
- `lib/models/ai_result.dart` 생성: `String menuName`, `String category`, `tryParse()` 팩토리
- AddEditRecordScreen 생성 모드 로직 통합:
  - 진입 시 로딩 오버레이 표시 (반투명 검정 + `CupertinoActivityIndicator` + "AI가 사진을 분석하고 있어요..." + `IgnorePointer`)
  - EXIF 추출 + 역지오코딩 + Firebase AI를 `Future.wait`으로 병렬 실행
  - 완료 시 로딩 제거, 각 controller에 결과 설정
  - 실패 시: 로딩 제거 + "정보를 직접 입력해 주세요" 토스트 + 빈 TextField

**예상 수정 파일:**
- `lib/main.dart`
- `lib/firebase_options.dart` (`flutterfire configure`가 자동 생성)
- `lib/services/vision_ai_service.dart` (신규)
- `lib/models/ai_result.dart` (신규)
- `lib/screens/add_edit_record_screen.dart`
- `android/app/google-services.json` (`flutterfire configure`가 자동 다운로드/배치)
- `android/app/build.gradle.kts` (`flutterfire configure`가 plugins에 `com.google.gms.google-services` 자동 주입)

**완료 확인 방법:**
- Android 에뮬레이터에서 음식 사진 선택 → 로딩 오버레이 → AI 분석 완료 후 메뉴명/카테고리 자동 채움
- 로딩 중 화면 터치 차단 동작 확인
- 에뮬레이터 비행기 모드: 타임아웃 후 빈 폼 + 안내 메시지 표시
- 디버그 빌드 첫 실행 시 Logcat에 App Check Debug 토큰 출력 → Firebase 콘솔에 등록 후 정상 동작
- App Check Debug 토큰 미등록 상태에서는 AI 호출 실패 → 빈 폼 + 안내 토스트로 정상 처리
- `grep -r "AIza[0-9A-Za-z_-]" lib/` 결과 1건(공개 Firebase identifier) — Gemini API 키는 0건

---

## Task 12: 저장 기능 완성 (Create + Update + searchKeyword 생성)

**목표:** 저장 버튼을 눌렀을 때 ArchiveItem을 생성/수정하고 searchKeyword를 자동 생성하여 Hive에 저장한다.

**구현할 기능:**
- AddEditRecordScreen 저장 로직 (생성 모드):
  1. 각 TextField에서 값 수집
  2. `searchKeyword` 생성: 모든 텍스트 필드를 공백 제거 후 병합
  3. `ArchiveItem` 객체 생성 (`uuid`로 id 생성)
  4. `ArchiveProvider.addItem()` 호출
  5. `Navigator.popUntil`로 홈 복귀
- 수정 모드 저장 로직:
  1. 기존 `id`와 `imagePath` 유지, 나머지 수집
  2. `searchKeyword` 재생성
  3. `ArchiveProvider.updateItem()` 호출
  4. 홈 화면까지 `popUntil`

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart`
- `lib/models/archive_item.dart` (`generateSearchKeyword()` 확인)

**완료 확인 방법:**
- Android 에뮬레이터: 사진 선택 → AI 분석 → 식당명 입력 → 저장 → 홈에 새 카드 표시
- 상세 → 수정 → 식당명 변경 → 저장 → 홈에서 변경 확인
- 앱 강제 종료(Recent Apps에서 swipe) 후 재실행 시 데이터 유지 (Hive 영속성)

---

## Task 13: 삭제 기능 완성

**목표:** DetailScreen에서 삭제 시 DB 레코드와 로컬 이미지 파일을 함께 삭제한다.

**구현할 기능:**
- DetailScreen 삭제 로직:
  - `CupertinoAlertDialog` "정말 삭제하시겠습니까?"
  - 승인 시:
    1. `ArchiveProvider.deleteItem(id)`
    2. `File(absoluteImagePath).delete()` (파일 없어도 에러 무시)
    3. `Navigator.pop()` → 홈 복귀
  - 취소 시: 다이얼로그 닫고 유지

**예상 수정 파일:**
- `lib/screens/detail_screen.dart`
- `lib/providers/archive_provider.dart`

**완료 확인 방법:**
- 삭제 다이얼로그가 `CupertinoAlertDialog` 스타일 (Material `AlertDialog` 아님)
- 삭제 승인 → 홈 복귀 → 카드 사라짐
- 앱 재실행 시 삭제된 레코드 미표시
- `adb shell run-as com.solkim.my_food_archive ls app_flutter/images/`로 파일 삭제 확인

---

## Task 14: 실시간 키워드 검색 기능

**목표:** HomeScreen 검색창에 텍스트 입력 시 searchKeyword 기반으로 갤러리를 실시간 필터링한다.

**구현할 기능:**
- HomeScreen 검색창 연결:
  - `TextEditingController` + `onChanged`
  - 입력 텍스트 공백 제거 후 `ArchiveProvider.search(query)`
  - 검색어 비어있으면 전체 목록 복원
- ArchiveProvider 검색 로직:
  - `search(String query)`: `item.searchKeyword.contains(공백제거된 query)`
  - 빈 query 시 전체 목록 반환
- 검색 결과 없을 때: "검색 결과가 없습니다" 텍스트 표시

**예상 수정 파일:**
- `lib/screens/home_screen.dart`
- `lib/providers/archive_provider.dart`

**완료 확인 방법:**
- 여러 레코드 저장 후 Android 에뮬레이터에서 "파스타" 입력 → 파스타 관련만 필터링
- "연남동 한식" 입력 → "연남동한식"으로 변환되어 검색
- 검색어 전체 삭제 → 전체 목록 복원
- 매칭 결과 없을 때 안내 텍스트 표시

---

## Task 15: 사진 재선택 기능

**목표:** AddEditRecordScreen 생성 모드에서 사진을 다시 선택하고 AI 분석을 재실행한다.

**구현할 기능:**
- 사진 미리보기 영역에 `GestureDetector` 또는 '사진 변경' 버튼 추가
- 탭 시:
  1. `PhotoService.pickAndPersistImage()` 재호출
  2. 새 이미지 선택됨 → 이전 복사 이미지 삭제
  3. 로딩 오버레이 재표시
  4. EXIF 추출 + AI 분석 재실행
  5. 결과로 폼 덮어쓰기 (식당명은 유지)
- 재선택 취소 → 기존 상태 유지

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart`

**완료 확인 방법:**
- Android 에뮬레이터에서 생성 모드 → 사진 미리보기 탭 → Photo Picker 재호출
- 새 사진 선택 → 로딩 → 새 AI 분석 결과로 폼 갱신
- 입력한 식당명 유지
- 재선택 취소 시 기존 상태 유지

---

## Task 16: 에러 처리, 토스트 메시지 마무리

**목표:** 모든 Fail-Safe 요구사항을 최종 점검하고, 토스트 메시지와 엣지 케이스를 보강한다.

**구현할 기능:**
- `lib/widgets/toast_message.dart` 생성: iOS 스타일 둥근 플로팅 토스트
  - "정보를 직접 입력해 주세요" (AI 실패)
  - "설정에서 사진 권한을 허용해 주세요" (Android 권한 거부)
  - "저장되었습니다" (저장 완료)
  - "삭제되었습니다" (삭제 완료)
- 권한 거부 처리: FAB 탭 시 권한 거부 → 토스트, 홈 유지
- AI 실패 토스트 통합
- 이미지 파일 로드 실패 시 기본 플레이스홀더 표시
- null 안전성 전반 점검

**예상 수정 파일:**
- `lib/widgets/toast_message.dart` (신규)
- `lib/screens/home_screen.dart`
- `lib/screens/add_edit_record_screen.dart`
- `lib/screens/detail_screen.dart`

**완료 확인 방법:**
- Pixel 5 / API 30에서 권한 거부 시 토스트 표시 + 크래시 없음
- 에뮬레이터 비행기 모드에서 AI 분석 → 타임아웃 후 토스트 + 빈 폼
- EXIF 없는 사진 저장 → 위치/날짜 비어도 정상 저장
- 식당명 비어있으면 저장 버튼 절대 활성화 안 됨

---

## Task 17: 전체 통합 테스트 및 UI 폴리시

**목표:** 전체 유스케이스(UC-01 ~ UC-06)를 Android 에뮬레이터에서 검증하고, 디자인 가이드 준수 여부를 최종 확인한다.

**구현할 기능:**
- 유스케이스 검증 (Pixel 7 / API 34, Pixel 5 / API 30 양쪽):
  - UC-01: 앱 실행 → Empty State → 데이터 추가 후 갤러리 최신순 정렬
  - UC-02: 검색 "연남동 파스타" → 필터링 → 검색어 삭제 → 전체 복원
  - UC-03: FAB → 사진 선택 → AI 로딩 → 폼 채움 → 식당명 입력 → 저장 → 홈 갱신
  - UC-04: 카드 탭 → 상세 화면 → 원본 사진 + 메타데이터
  - UC-05: 상세 → 수정 → 텍스트 변경 → 저장 → 홈에서 변경 확인
  - UC-06: 상세 → 삭제 → 확인 팝업 → 삭제 → 홈 복귀
- 디자인 가이드 체크리스트 (Pure Native 강제 확인):
  - 모든 컬러가 `AppColors` 상수 사용
  - 타이포그래피가 `AppTextStyles` 상수 사용
  - `CupertinoAlertDialog` 사용 (Material Dialog 아님)
  - `BouncingScrollPhysics` 전역 적용 (Android 글로우 이펙트 X)
  - 화면 좌우 여백 20px 통일
  - TextField Surface 배경 + borderRadius 10 통일
  - 다크모드 에뮬레이터에서도 앱은 라이트 모드 유지

**예상 수정 파일:**
- 전체 화면 파일 (미세 수정)

**완료 확인 방법:**
- 6개 유스케이스 모두 정상 동작 (양쪽 에뮬레이터)
- 디자인 가이드 체크리스트 전항목 통과
- 앱 강제 종료 후 재실행 시 데이터 영속성 확인
- 엣지 케이스(EXIF 없는 사진, 네트워크 끊김, 권한 거부, App Check Debug 토큰 미등록) 모두 크래시 없이 처리
- `flutter build apk --release` 성공 및 릴리스 APK 에뮬레이터 설치 후 동작 확인
