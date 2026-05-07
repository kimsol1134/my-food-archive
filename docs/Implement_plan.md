# 📱 [마이 맛집 아카이브] MVP 구현 계획서

## 진행 체크리스트

- [x] Task 1: Flutter 프로젝트 생성 및 패키지 의존성 추가
- [x] Task 2: iOS 권한 설정
- [x] Task 3: 컬러/타이포그래피 상수 및 앱 테마 설정
- [x] Task 4: ArchiveItem 데이터 모델 및 Hive 로컬 DB 서비스
- [x] Task 5: Provider 상태 관리 계층
- [x] Task 6: HomeScreen UI (갤러리 그리드 + Empty State + FAB)
- [x] Task 7: DetailScreen UI
- [x] Task 8: AddEditRecordScreen UI (폼 레이아웃)
- [x] Task 9: 3개 화면 간 네비게이션 연결
- [x] Task 10: 사진 선택 서비스 및 EXIF 메타데이터 추출
- [x] Task 11: Gemini Vision AI 서비스 연동 (Firebase AI Logic)
- [x] Task 12: 저장 기능 완성 (Create + Update + searchKeyword 생성)
- [x] Task 13: 삭제 기능 완성
- [ ] Task 14: 실시간 키워드 검색 기능
- [ ] Task 15: 사진 재선택 기능
- [ ] Task 16: 에러 처리, 토스트 메시지 마무리
- [ ] Task 17: 전체 통합 테스트 및 UI 폴리시

## 프로젝트 개요

백엔드 없이 기기 로컬에 모든 데이터를 저장하는 개인용 맛집 아카이브 iOS 앱.
사진 업로드 시 EXIF에서 날짜/위치를 자동 추출하고, Firebase AI Logic을 통해 Gemini Vision API로 메뉴/카테고리를 자동 태깅하며, 사용자는 식당명만 입력하면 된다. API 키는 Firebase가 자체 보관하여 앱에 노출되지 않는다.

## PRD 핵심 기능 5가지 (구현 범위)

| # | 기능 | 설명 |
|---|------|------|
| ① | 사진 업로드 + EXIF 추출 | 촬영 날짜, GPS 기반 지역명 자동 저장 |
| ② | Vision AI 자동 태깅 | Firebase AI Logic을 통해 Gemini Vision API로 메뉴명/카테고리 자동 분류 (키 노출 없음) |
| ③ | 최소 수동 입력 | 식당 이름만 직접 타이핑 |
| ④ | 키워드 검색 | 지역+메뉴+식당명 조합 실시간 필터링 |
| ⑤ | 갤러리 뷰 | Grid 형태 사진 썸네일 나열 + 상세 보기 |

> **범위 외 기능:** 알림, 지도 연동, SNS 공유, 다크모드, 백엔드 서버 등은 MVP에 포함하지 않는다.

## 태스크 의존성 다이어그램

```
Task 1 (프로젝트 생성)
 └─> Task 2 (iOS 권한)
 └─> Task 3 (상수 + 테마)
      └─> Task 4 (데이터 모델 + Hive)
           └─> Task 5 (Provider 상태 관리)
                ├─> Task 6 (HomeScreen UI)
                ├─> Task 7 (DetailScreen UI)
                └─> Task 8 (AddEditRecordScreen UI)
                     └─> Task 9 (네비게이션 연결) ← Task 6, 7도 필요
                          └─> Task 10 (사진 선택 + EXIF)
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
```

---

## Task 1: Flutter 프로젝트 생성 및 패키지 의존성 추가

**목표:** Flutter 프로젝트를 생성하고 MVP에 필요한 모든 패키지를 설치한다.

**구현할 기능:**
- `flutter create --platforms ios` 로 프로젝트 생성
- `pubspec.yaml`에 필수 패키지 추가:
  - `provider` (상태 관리)
  - `hive`, `hive_flutter` (로컬 DB)
  - `image_picker` (갤러리 사진 선택)
  - `exif` (EXIF 메타데이터 추출)
  - `geocoding` (역지오코딩)
  - `firebase_core`, `firebase_ai`, `firebase_app_check` (Firebase AI Logic을 통한 Gemini Vision; 키는 Firebase 서버 보관)
  - `uuid` (고유 ID 생성)
  - `path_provider` (로컬 파일 경로)
- `dev_dependencies`에 추가:
  - `hive_generator`, `build_runner` (Hive TypeAdapter 코드 생성)

**예상 수정 파일:**
- `pubspec.yaml`

**완료 확인 방법:**
- `flutter pub get` 에러 없이 완료
- `flutter build ios --no-codesign` 빌드 성공

---

## Task 2: iOS 권한 설정

**목표:** iOS에서 갤러리 접근과 위치 정보 사용에 필요한 권한 문구를 설정한다.

**구현할 기능:**
- `ios/Runner/Info.plist`에 권한 추가:
  - `NSPhotoLibraryUsageDescription`: "음식 사진을 불러오고 저장하기 위해 갤러리 접근 권한이 필요합니다."
  - `NSLocationWhenInUseUsageDescription`: "사진의 촬영 위치(EXIF)를 기반으로 맛집의 지역 정보를 자동으로 입력하기 위해 권한이 필요합니다."

**예상 수정 파일:**
- `ios/Runner/Info.plist`

**완료 확인 방법:**
- iOS 시뮬레이터에서 앱 실행 시 권한 요청 팝업이 한국어 문구로 표시됨

---

## Task 3: 컬러/타이포그래피 상수 및 앱 테마 설정

**목표:** 디자인 가이드에 정의된 컬러 시스템과 타이포그래피를 상수로 정의하고, 라이트 모드를 강제 적용한다.

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
  - `ScrollConfiguration` 래핑으로 전역 `BouncingScrollPhysics` 적용
  - 커스텀 폰트 없음 (시스템 기본 폰트 사용)

**예상 수정 파일:**
- `lib/constants/app_colors.dart` (신규)
- `lib/constants/app_text_styles.dart` (신규)
- `lib/main.dart`

**완료 확인 방법:**
- iOS 시뮬레이터에서 흰색 배경의 빈 화면 표시
- 기기 다크모드 설정 상태에서도 앱은 라이트 모드 유지

---

## Task 4: ArchiveItem 데이터 모델 및 Hive 로컬 DB 서비스

**목표:** 맛집 기록 데이터 모델을 정의하고, Hive 기반 CRUD 서비스를 구현한다.

**구현할 기능:**
- `lib/models/archive_item.dart` 생성:
  - 필드: `id`(String/UUID), `imagePath`(String), `restaurantName`(String), `menuName`(String), `category`(String), `location`(String), `date`(DateTime?), `searchKeyword`(String)
  - Hive TypeAdapter 어노테이션 (`@HiveType`, `@HiveField`)
  - `generateSearchKeyword()` 메서드: 모든 텍스트 필드를 공백 없이 병합 (예: `"연남동오스테리아크림파스타양식"`)
- `build_runner`로 `archive_item.g.dart` 자동 생성
- `lib/services/local_db_service.dart` 생성:
  - `initDB()`: Hive 초기화 및 Box 열기
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
- `flutter pub run build_runner build` 에러 없이 `archive_item.g.dart` 생성
- 컴파일 에러 없음

---

## Task 5: Provider 상태 관리 계층

**목표:** UI와 LocalDBService 사이의 상태 관리 계층을 구축한다.

**구현할 기능:**
- `lib/providers/archive_provider.dart` 생성:
  - `ChangeNotifier` 상속
  - 내부 상태: `List<ArchiveItem> _items`, `List<ArchiveItem> _filteredItems`, `String _searchQuery`, `bool _isLoading`
  - `loadItems()`: DB 전체 조회 → `_items` 갱신 → `notifyListeners()`
  - `addItem(ArchiveItem)`: DB insert → `loadItems()` 재호출
  - `updateItem(ArchiveItem)`: DB update → `loadItems()` 재호출
  - `deleteItem(String id)`: DB delete → `loadItems()` 재호출
  - `search(String query)`: 검색어로 `_filteredItems` 필터링 → `notifyListeners()`
  - getter `items`: 검색어 있으면 `_filteredItems`, 없으면 `_items` 반환
- `main.dart`에 `ChangeNotifierProvider<ArchiveProvider>` 등록
- `main()` 함수에서 Hive 초기화 + TypeAdapter 등록

**예상 수정 파일:**
- `lib/providers/archive_provider.dart` (신규)
- `lib/main.dart` (Provider 등록, Hive 초기화)

**완료 확인 방법:**
- 앱 실행 시 Hive 초기화 에러 없음
- `ArchiveProvider`가 위젯 트리에서 접근 가능한 상태
- 컴파일 및 빌드 성공

---

## Task 6: HomeScreen UI (갤러리 그리드 + Empty State + FAB)

**목표:** 홈 화면의 기본 레이아웃을 구현한다.

**구현할 기능:**
- `lib/screens/home_screen.dart` 생성:
  - 상단 검색 `TextField`: Surface 배경, borderRadius 10, 좌측 돋보기 아이콘, 높이 36px, 밑줄 없음
  - 본문: `Consumer<ArchiveProvider>`로 데이터 상태 분기
    - Empty State (0개): 중앙에 `CupertinoIcons.photo_on_rectangle`(64px) + "아직 저장된 맛집이 없어요." (TextSub 컬러)
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
- 시뮬레이터에서 Empty State 화면 정상 표시
- 검색창이 iOS 스타일로 렌더링 (Surface 배경, 밑줄 없음)
- FAB 버튼이 우측 하단에 파란색으로 표시

---

## Task 7: DetailScreen UI

**목표:** 맛집 상세 보기 화면을 구현한다.

**구현할 기능:**
- `lib/screens/detail_screen.dart` 생성:
  - 파라미터: `ArchiveItem` 객체
  - AppBar: 좌측 뒤로가기, 우측 수정(`CupertinoIcons.pencil`) + 삭제(`CupertinoIcons.trash`, Destructive 컬러) 아이콘
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
- 삭제 버튼 탭 시 CupertinoAlertDialog 표시

---

## Task 8: AddEditRecordScreen UI (폼 레이아웃)

**목표:** 기록 추가/수정 통합 화면의 UI를 구현한다. 생성 모드와 수정 모드를 하나의 화면에서 처리한다.

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
    - 식당명 비어있으면: 배경 TextSub, onPressed null (비활성화)
    - 식당명 입력됨: 배경 Primary (활성화)
  - 수정 모드: 기존 데이터로 모든 TextField 초기값 설정
  - `GestureDetector` 래핑: 빈 영역 터치 시 `FocusScope.of(context).unfocus()` (키보드 숨김)

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart` (신규)

**완료 확인 방법:**
- 식당명 비어있을 때 저장 버튼 회색 비활성화
- 식당명 입력 시 저장 버튼 파란색 활성화
- 빈 영역 터치 시 키보드 숨김 동작

---

## Task 9: 3개 화면 간 네비게이션 연결

**목표:** HomeScreen, DetailScreen, AddEditRecordScreen 간의 모든 네비게이션 경로를 연결한다.

**구현할 기능:**
- HomeScreen:
  - 갤러리 카드 탭 → `Navigator.push` → DetailScreen(item)
  - FAB 탭 → AddEditRecordScreen(null) (사진 선택은 Task 10에서 연결)
- DetailScreen:
  - 수정 아이콘 탭 → `Navigator.push` → AddEditRecordScreen(existingItem)
  - 삭제 확인 후 → `Navigator.pop()` → 홈 복귀
- AddEditRecordScreen:
  - 취소 버튼 → `Navigator.pop()`
  - 저장 완료 후 → `Navigator.popUntil` → 홈 화면까지 복귀

**예상 수정 파일:**
- `lib/screens/home_screen.dart` (네비게이션 추가)
- `lib/screens/detail_screen.dart` (수정 버튼 네비게이션 연결)
- `lib/screens/add_edit_record_screen.dart` (저장 후 네비게이션)

**완료 확인 방법:**
- 홈 → 카드 탭 → 상세 화면 이동
- 상세 → 수정 → 수정 화면 이동 (기존 데이터 pre-fill)
- 수정 화면 → 취소 → 이전 화면 복귀
- 상세 → 삭제 → 확인 팝업 → 승인 → 홈 복귀

---

## Task 10: 사진 선택 서비스 및 EXIF 메타데이터 추출

**목표:** 갤러리에서 사진을 선택하고, EXIF에서 촬영 날짜와 GPS 좌표를 추출한 뒤, 역지오코딩으로 동/구 텍스트로 변환한다.

**구현할 기능:**
- `lib/services/photo_service.dart` 생성:
  - `pickImage()`: `ImagePicker.pickImage(source: ImageSource.gallery)` 호출
  - 선택된 이미지를 앱 로컬 디렉토리(`getApplicationDocumentsDirectory`)로 복사
  - 권한 거부 시 null 반환
- `lib/services/exif_service.dart` 생성:
  - `extractMetadata(String filePath)`: EXIF 파싱
  - 촬영 날짜(`DateTime`) 추출: `DateTimeOriginal` 태그
  - GPS 좌표(위도/경도) 추출: `GPSLatitude`, `GPSLongitude` 태그
  - **Fail-Safe**: EXIF 데이터 없거나 GPS 없으면 null 반환 (크래시 금지)
- `lib/models/exif_result.dart` 생성:
  - `DateTime? date`, `double? latitude`, `double? longitude`
- `lib/services/location_service.dart` 생성:
  - `getAddressFromCoordinates(double lat, double lng)`: `geocoding` 패키지 `placemarkFromCoordinates()` 호출
  - 반환: 동/구 단위 텍스트 (예: "연남동")
  - **Fail-Safe**: 실패 시 빈 문자열 반환
- HomeScreen FAB 연결:
  - FAB 탭 → `PhotoService.pickImage()` → 이미지 선택됨 → AddEditRecordScreen(생성 모드) 이동
  - 이미지 미선택(취소) → 홈 화면 유지

**예상 수정 파일:**
- `lib/services/photo_service.dart` (신규)
- `lib/services/exif_service.dart` (신규)
- `lib/services/location_service.dart` (신규)
- `lib/models/exif_result.dart` (신규)
- `lib/screens/home_screen.dart` (FAB에 사진 선택 로직 연결)
- `lib/screens/add_edit_record_screen.dart` (이미지 경로 수신 및 EXIF 추출)

**완료 확인 방법:**
- FAB 탭 시 iOS 갤러리 호출 (권한 팝업 정상 표시)
- 사진 선택 후 AddEditRecordScreen 진입, 사진 미리보기 표시
- EXIF 있는 사진: 날짜/지역 필드에 값 자동 채움
- EXIF 없는 사진(스크린샷 등): 날짜/지역 필드 비어있되 앱 크래시 없음
- 사진 선택 취소 시 홈 화면 유지

---

## Task 11: Gemini Vision AI 서비스 연동 (Firebase AI Logic)

**목표:** Firebase AI Logic을 통해 Gemini Vision 모델을 호출하여 음식 사진에서 메뉴명과 카테고리를 자동 추출하고, 폼에 결과를 채운다. **API 키는 Firebase가 보관하므로 앱 코드/번들에 노출되지 않는다.**

**전제 조건 (10.1 절에서 완료):**
- Firebase 프로젝트 생성 + iOS 앱 등록
- `GoogleService-Info.plist`를 `ios/Runner/`에 추가
- `flutterfire configure` 실행 → `lib/firebase_options.dart` 자동 생성
- App Check 활성화 (iOS = App Attest 우선 / DeviceCheck fallback)
- Firebase 콘솔에서 Firebase AI Logic + Gemini API 활성화

**구현할 기능:**
- `lib/main.dart` 초기화:
  - `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  - `await FirebaseAppCheck.instance.activate(appleProvider: AppleProvider.appAttest)`
- `lib/services/vision_ai_service.dart` 생성:
  - `firebase_ai` SDK로 Gemini Vision 모델 인스턴스 생성: `FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash')`
  - `analyzeImage(String imagePath)`:
    - 이미지 파일을 바이트로 읽어 `Content.multi([TextPart(prompt), InlineDataPart('image/jpeg', bytes)])` 형태로 호출
    - 프롬프트: "제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. 응답은 반드시 `{"menu": "메뉴이름", "category": "카테고리명"}` 형태의 순수 JSON 포맷으로만 반환하라."
    - 응답 JSON 파싱 → `AiResult` 모델 반환
  - **Fail-Safe**: 타임아웃 15초, 네트워크 오류/Firebase AI 실패/JSON 파싱 실패/App Check 토큰 거부 시 null 반환
- `lib/models/ai_result.dart` 생성:
  - `String menuName`, `String category`
- AddEditRecordScreen 생성 모드 로직 통합:
  - 화면 진입 시:
    1. 로딩 오버레이 표시 (반투명 검정 `black.withOpacity(0.3)` + `CupertinoActivityIndicator` + "AI가 사진을 분석하고 있어요..." + `IgnorePointer` 터치 차단)
    2. EXIF 추출 + 역지오코딩과 Firebase AI 호출을 `Future.wait`으로 병렬 실행
    3. 완료 시 로딩 제거, 결과를 각 TextField controller에 설정
  - 실패 시: 로딩 제거 + "정보를 직접 입력해 주세요" 토스트 + 빈 TextField 제공

**예상 수정 파일:**
- `lib/main.dart` (Firebase + App Check 초기화)
- `lib/firebase_options.dart` (`flutterfire configure`로 자동 생성)
- `lib/services/vision_ai_service.dart` (신규)
- `lib/models/ai_result.dart` (신규)
- `lib/screens/add_edit_record_screen.dart` (로딩 오버레이 + AI/EXIF 병렬 호출)

**완료 확인 방법:**
- 음식 사진 선택 시 로딩 오버레이 → AI 분석 완료 후 메뉴명/카테고리 자동 채움
- 로딩 중 화면 터치 차단 동작 확인
- 네트워크 끊긴 상태: 타임아웃 후 빈 폼 + 안내 메시지 표시
- App Check 토큰 발급 실패 시에도 빈 폼 + 안내 토스트로 정상 처리
- 앱 코드 어디에도 Gemini API 키가 들어가지 않음 (`grep -r "AIza" lib/` 결과 0건)
- 앱 크래시 없이 모든 실패 케이스 정상 처리

---

## Task 12: 저장 기능 완성 (Create + Update + searchKeyword 생성)

**목표:** 저장 버튼을 눌렀을 때 ArchiveItem을 생성/수정하고 searchKeyword를 자동 생성하여 Hive에 저장한다.

**구현할 기능:**
- AddEditRecordScreen 저장 로직 (생성 모드):
  1. 각 TextField에서 값 수집
  2. `searchKeyword` 생성: 모든 텍스트 필드를 공백 제거 후 병합 (예: `"연남동오스테리아크림파스타양식"`)
  3. `ArchiveItem` 객체 생성 (`uuid`로 id 생성)
  4. `ArchiveProvider.addItem()` 호출
  5. `Navigator.popUntil`로 홈 복귀
- 수정 모드 저장 로직:
  1. 기존 `id`와 `imagePath` 유지, 나머지 TextField에서 수집
  2. `searchKeyword` 재생성
  3. `ArchiveProvider.updateItem()` 호출
  4. 홈 화면까지 `popUntil`

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart` (저장 로직 완성)
- `lib/models/archive_item.dart` (`generateSearchKeyword()` 확인/보강)

**완료 확인 방법:**
- 사진 선택 → AI 분석 → 식당명 입력 → 저장 → 홈 화면에 새 카드 표시
- 상세 → 수정 → 식당명 변경 → 저장 → 홈에서 변경된 이름 확인
- 앱 종료 후 재실행 시 저장된 데이터 유지 (Hive 영속성)

---

## Task 13: 삭제 기능 완성

**목표:** DetailScreen에서 삭제 시 DB 레코드와 로컬 이미지 파일을 함께 삭제한다.

**구현할 기능:**
- DetailScreen 삭제 로직:
  - `CupertinoAlertDialog` "정말 삭제하시겠습니까?" 확인
  - 승인 시:
    1. `ArchiveProvider.deleteItem(id)` 호출
    2. `File(imagePath).delete()` 로 로컬 이미지 파일 삭제 (파일 없어도 에러 무시)
    3. `Navigator.pop()` → 홈 복귀
  - 취소 시: 다이얼로그 닫고 DetailScreen 유지

**예상 수정 파일:**
- `lib/screens/detail_screen.dart` (삭제 로직 보강)
- `lib/providers/archive_provider.dart` (이미지 파일 삭제 추가 가능)

**완료 확인 방법:**
- 삭제 확인 다이얼로그가 CupertinoAlertDialog 스타일
- 삭제 승인 → 홈 복귀 → 해당 카드 사라짐
- 앱 재실행 시 삭제된 레코드 미표시

---

## Task 14: 실시간 키워드 검색 기능

**목표:** HomeScreen 검색창에 텍스트 입력 시 searchKeyword 기반으로 갤러리를 실시간 필터링한다.

**구현할 기능:**
- HomeScreen 검색창 연결:
  - `TextEditingController` + `onChanged` 콜백
  - 입력 텍스트에서 공백 제거 후 `ArchiveProvider.search(query)` 호출
  - 검색어 비어있으면 전체 목록 복원
- ArchiveProvider 검색 로직:
  - `search(String query)`: 공백 제거된 query로 `item.searchKeyword.contains(query)` 필터링
  - 빈 query 시 전체 목록 반환
- 검색 결과 없을 때: "검색 결과가 없습니다" 텍스트 표시

**예상 수정 파일:**
- `lib/screens/home_screen.dart` (검색창 onChanged 연결)
- `lib/providers/archive_provider.dart` (search 로직 보강)

**완료 확인 방법:**
- 여러 레코드 저장 후 "파스타" 입력 → 파스타 관련 레코드만 필터링
- "연남동 한식" 입력 → "연남동한식"으로 변환되어 검색
- 검색어 전체 삭제 → 전체 목록 복원
- 매칭 결과 없을 때 안내 텍스트 표시

---

## Task 15: 사진 재선택 기능

**목표:** AddEditRecordScreen 생성 모드에서 사진을 다시 선택하고 AI 분석을 재실행하는 기능을 구현한다.

**구현할 기능:**
- 사진 미리보기 영역에 `GestureDetector` 또는 '사진 변경' 버튼 추가
- 탭 시:
  1. `PhotoService.pickImage()` 재호출
  2. 새 이미지 선택됨 → 이전 복사 이미지 삭제
  3. 로딩 오버레이 재표시
  4. EXIF 추출 + AI 분석 재실행
  5. 결과로 폼 TextField 값 덮어쓰기 (식당명은 유지)
- 재선택 취소 → 기존 상태 유지

**예상 수정 파일:**
- `lib/screens/add_edit_record_screen.dart` (사진 재선택 로직)

**완료 확인 방법:**
- 생성 모드에서 사진 미리보기 탭 → 갤러리 재호출
- 새 사진 선택 → 로딩 → 새 AI 분석 결과로 폼 갱신
- 이미 입력한 식당명은 그대로 유지
- 재선택 취소 시 기존 상태 유지

---

## Task 16: 에러 처리, 토스트 메시지 마무리

**목표:** 모든 Fail-Safe 요구사항을 최종 점검하고, 토스트 메시지와 엣지 케이스를 보강한다.

**구현할 기능:**
- `lib/widgets/toast_message.dart` 생성:
  - iOS 스타일 플로팅 토스트 (둥근 모서리, 반투명 배경)
  - 메시지 종류:
    - "정보를 직접 입력해 주세요" (AI 실패)
    - "설정에서 사진 권한을 허용해 주세요" (권한 거부)
    - "저장되었습니다" (저장 완료)
    - "삭제되었습니다" (삭제 완료)
- 권한 거부 처리: FAB 탭 시 권한 거부 → 토스트 노출, 홈 유지
- AI 실패 토스트 통합
- 이미지 파일 로드 실패 시 기본 플레이스홀더 표시
- null 안전성 전반 점검

**예상 수정 파일:**
- `lib/widgets/toast_message.dart` (신규)
- `lib/screens/home_screen.dart` (권한 거부 토스트)
- `lib/screens/add_edit_record_screen.dart` (AI 실패 토스트)
- `lib/screens/detail_screen.dart` (이미지 로드 실패 처리)

**완료 확인 방법:**
- 권한 거부 시 토스트 표시 + 크래시 없음
- 비행기 모드에서 AI 분석 → 타임아웃 후 토스트 + 빈 폼
- EXIF 없는 사진 저장 → 위치/날짜 비어도 정상 저장
- 식당명 비어있으면 저장 버튼 절대 활성화 안 됨

---

## Task 17: 전체 통합 테스트 및 UI 폴리시

**목표:** 전체 유스케이스(UC-01 ~ UC-06)를 시뮬레이터에서 검증하고, 디자인 가이드 준수 여부를 최종 확인한다.

**구현할 기능:**
- 유스케이스 검증:
  - UC-01: 앱 실행 → Empty State → 데이터 추가 후 갤러리 최신순 정렬
  - UC-02: 검색 "연남동 파스타" → 필터링 → 검색어 삭제 → 전체 복원
  - UC-03: FAB → 사진 선택 → AI 로딩 → 폼 채움 → 식당명 입력 → 저장 → 홈 갱신
  - UC-04: 카드 탭 → 상세 화면 → 원본 사진 + 메타데이터
  - UC-05: 상세 → 수정 → 텍스트 변경 → 저장 → 홈에서 변경 확인
  - UC-06: 상세 → 삭제 → 확인 팝업 → 삭제 → 홈 복귀
- 디자인 가이드 체크리스트:
  - 모든 컬러가 `AppColors` 상수 사용 (하드코딩 제거)
  - 타이포그래피가 `AppTextStyles` 상수 사용
  - `CupertinoAlertDialog` 사용 (Material Dialog 아님)
  - `BouncingScrollPhysics` 전역 적용
  - 화면 좌우 여백 20px 통일
  - TextField Surface 배경 + borderRadius 10 통일

**예상 수정 파일:**
- 전체 화면 파일 (미세 수정)

**완료 확인 방법:**
- 6개 유스케이스 모두 정상 동작
- 디자인 가이드 체크리스트 전항목 통과
- 앱 종료 후 재실행 시 데이터 영속성 확인
- 엣지 케이스(EXIF 없는 사진, 네트워크 끊김, 권한 거부) 모두 크래시 없이 처리
