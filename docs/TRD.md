# 📱 [마이 맛집 아카이브] MVP 기술 설계 문서 (TRD) - 최종본

> **문서 상태:** 책에 실린 iPhone 앱의 최종 코드와 동기화한 저자 예시본입니다. 현재 위치를 실시간으로 조회하지 않으며, 사용자가 고른 사진 안의 EXIF 위치 정보만 읽습니다.

## 1. 아키텍처 개요 (Architecture Overview)
본 앱은 별도 백엔드 서버를 운영하지 않는 **클라이언트 전용(Client-Side Only) 아키텍처**로 설계되었습니다. 모든 데이터는 기기 내부에 저장되며, 이미지 분석을 위한 Vision AI 통신은 **Firebase AI Logic**을 통해 Gemini Vision API를 호출합니다. Firebase가 API 키를 자체 서버에 보관하므로 클라이언트(앱)에는 키가 노출되지 않으며, App Check로 정상 앱의 요청만 허용합니다.

* **데이터 흐름 (Data Flow):**
    1. **사진 선택 및 EXIF 추출:** 사용자가 기기 갤러리에서 사진을 선택하면, 앱이 사진의 메타데이터(EXIF)에서 촬영 날짜와 GPS 좌표(위도/경도)를 추출합니다.
    2. **지오코딩 (역방향):** 추출된 GPS 좌표를 기기의 OS 기본 기능을 활용해 텍스트 형태의 주소(예: 연남동, 역삼동)로 변환합니다.
    3. **AI Vision 분석:** 원본 이미지를 Firebase AI Logic을 통해 Gemini Vision 모델로 전송하여 '메뉴명'과 '카테고리'를 JSON 형태로 반환받습니다. App Check 토큰이 함께 전송되어 정상 앱의 요청임이 검증됩니다.
    4. **데이터 검증 및 수동 입력:** AI가 추출한 데이터와 위치 정보를 UI(TextField)에 뿌려주어 사용자가 확인 및 수정할 수 있게 하고, '식당명'을 추가로 입력받습니다.
    5. **로컬 저장 및 검색 최적화:** 모든 데이터를 NoSQL 로컬 데이터베이스에 저장합니다. 입력된 모든 텍스트를 공백 없이 합친 `searchKeyword` 필드를 함께 생성하고, 검색어가 여러 단어면 각 단어가 모두 포함된 기록만 보여 줍니다.

## 2. 주요 모듈 및 컴포넌트 (Core Modules & Components)

### A. 데이터 모델 (Data Model)
* **`ArchiveItem` 클래스:**
    * `id`: 고유 식별자 (UUID 등)
    * `imagePath`: 기기 내부의 사진 저장 경로
    * `restaurantName`: 식당명 (사용자 직접 입력)
    * `menuName`: 메뉴명 (AI 자동 추출 및 사용자 수정 가능)
    * `category`: 분류 (AI 자동 추출 및 사용자 수정 가능, 예: 한식, 카페)
    * `location`: 지역명 (EXIF 기반 지오코딩 및 사용자 수정 가능)
    * `date`: 방문 일자 (EXIF 기반)
    * `searchKeyword`: 검색용 통합 문자열 (예: "연남동오스테리아크림파스타양식")

### B. 서비스 계층 (Service Layer)
* **`PhotoService`:** iOS 환경에서 사진 원본과 메타데이터(위치 정보)가 유실되지 않도록 갤러리에 접근하고, 선택된 사진을 앱의 안전한 로컬 디렉토리로 복사합니다.
* **`LocationService`:** 사진의 EXIF 데이터에서 추출한 좌표를 `geocoding` 패키지를 사용해 동/구 단위의 텍스트로 변환합니다. (실패 시 빈 문자열 반환)
* **`VisionAIService`:** Firebase AI Logic의 `firebase_ai` SDK로 Gemini Vision 모델을 호출합니다. API 키는 Firebase가 보관하므로 앱 코드/번들에 키가 들어가지 않습니다.
    * **[중요 프롬프트 지시]:** "제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. 응답은 반드시 `{"menu": "메뉴이름", "category": "카테고리명"}` 형태의 순수 JSON 포맷으로만 반환하라."
* **`LocalDBService`:** 로컬 DB(Hive)를 초기화하고, `ArchiveItem`의 CRUD(생성, 읽기, 수정, 삭제)를 담당합니다. 검색어를 공백 기준으로 나눈 뒤 각 단어가 `searchKeyword`에 모두 포함되는지 확인합니다. 예를 들어 "연남동 파스타"는 두 단어가 모두 들어 있는 기록만 보여 줍니다.

### C. UI 화면 (UI Screens)
* **`HomeScreen` (메인 갤러리 뷰):**
    * 상단: 검색창 (`TextField`). 텍스트 입력 시 하단 그리드가 실시간으로 필터링됨.
    * 우측 상단: 정보 아이콘. 앱 정보와 개인정보처리방침 화면으로 이동.
    * 기록 없음: "아직 저장된 맛집이 없어요"와 "사진 한 장을 골라 첫 맛집 기록을 만들어보세요" 문구, `첫 기록 추가` 버튼 표시.
    * 검색 결과 없음: "검색 결과가 없습니다" 안내 표시.
    * 본문: `GridView.builder`를 사용한 사진 썸네일 바둑판 배열.
    * 하단: Floating Action Button (사진 추가).
* **`AddEditRecordScreen` (입력 및 AI 분석 화면):**
    * 진입 즉시 로딩 스피너 표시 (AI 분석 및 위치 추출 대기).
    * 완료 시: 사진 썸네일과 함께 식당명, 위치, 메뉴명, 카테고리를 입력/수정할 수 있는 `TextField` 목록 표시. (데이터가 누락되거나 틀려도 사용자가 직접 수정 가능하도록 예외 처리).
    * 하단: '저장' 버튼.
* **`DetailScreen` (상세 보기 화면):**
    * 사진 원본과 함께 저장된 텍스트 정보를 깔끔하게 나열하는 읽기 전용 뷰.
* **`PrivacyPolicyScreen` (앱 정보 및 개인정보처리방침):**
    * 기기에 저장되는 정보, AI 분석을 위해 전송되는 정보, App Check 안내를 표시.
    * 온라인 개인정보처리방침과 지원 문의 링크 제공.

## 3. 기술 스택 및 선택 근거 (Tech Stack)

| 구분 | 추천 패키지 | 선택 근거 |
| :--- | :--- | :--- |
| **프레임워크** | `Flutter` | 단일 코드베이스로 iOS 앱을 가장 빠르게 구축. |
| **상태 관리** | `Provider` | MVP의 복잡도에 가장 적합하고 에이전트가 보일러플레이트 없이 깔끔하게 짤 수 있는 표준 상태 관리. |
| **로컬 DB** | `Hive` | NoSQL 방식으로 SQL 테이블 생성(Schema) 없이 객체를 바로 저장하여 개발 속도를 2배 이상 단축. 검색(`contains`) 처리에도 매우 빠름. |
| **사진 및 메타데이터** | `image_picker` + `exif` | 사용자가 고른 사진을 가져오고, 사진 파일의 EXIF에서 촬영 날짜와 GPS 메타데이터를 읽기 위함. |
| **위치 변환** | `geocoding` | OS에 내장된 무료 역지오코딩 기능을 사용하여 Google Maps API 등의 추가 비용을 방지. |
| **AI 비전** | `firebase_core` + `firebase_ai` + `firebase_app_check` | Firebase AI Logic 공식 SDK. API 키를 클라이언트에 노출하지 않고 Gemini Vision을 호출. App Check로 정상 앱(iOS App Attest / DeviceCheck) 요청만 허용. |

## 4. [코딩 에이전트 필수 지시 사항] iOS 권한 및 예외 처리
코딩을 시작할 때 다음 사항을 반드시 `pubspec.yaml` 및 `ios/Runner/Info.plist`에 최우선으로 반영할 것.

* **iOS 권한 설정 (`Info.plist`):**
  * `NSPhotoLibraryUsageDescription`: "음식 사진을 불러오고 저장하기 위해 갤러리 접근 권한이 필요합니다."
  * `NSLocationWhenInUseUsageDescription`는 추가하지 않음. 이 앱은 사용자의 현재 위치를 조회하지 않고, 사용자가 고른 사진에 포함된 EXIF GPS만 읽음.
* **예외 처리 강제 (Fail-Safe):**
  * 캡처된 사진이거나 EXIF GPS 데이터가 없는 경우, 앱이 크래시되지 않고 위치 필드를 비워둔 상태로 UI를 렌더링해야 함.
  * 네트워크 오류나 API Limit으로 Gemini 응답이 실패할 경우, 무한 로딩에 빠지지 않고 타임아웃 처리 후 사용자에게 "정보를 직접 입력해 주세요"라는 알림표시와 함께 빈 `TextField`를 제공해야 함.
  * App Check 토큰 발급 실패 또는 거부 시에도 동일하게 처리(타임아웃 + 빈 폼 + 안내 토스트).

## 5. 보안 (Security)
* **API 키 노출 방지:** Gemini API 키는 Firebase AI Logic이 Google 서버에 보관함. 앱 번들·소스코드·`.env` 어디에도 키가 들어가지 않으므로 디컴파일로도 추출 불가.
* **App Check:** iOS에서는 App Attest를 우선 사용하고 DeviceCheck로 대체합니다. Firebase 콘솔에서 Firebase AI Logic의 기본 보호가 `Enforced`인지 배포 전에 확인합니다. 2026년 7월 초 이후 안내 마법사에서는 기본 보호가 자동 적용될 수 있지만, 기존 프로젝트는 직접 켜야 할 수 있습니다. 재전송 공격을 막는 replay protection은 별도 기능이며, 현재 앱에 적용됐다고 가정하지 않습니다. 현재 절차는 [Firebase AI Logic App Check 공식 문서](https://firebase.google.com/docs/ai-logic/app-check)를 기준으로 확인합니다.
* **최소 지원 버전:** `firebase_ai 3.13.1`의 요구사항에 맞춰 iOS 15.0 이상을 지원합니다. `ios/Podfile`과 Xcode 프로젝트의 Deployment Target을 모두 15.0으로 유지합니다.
* **클라이언트 코드 원칙:** Gemini 서버 자격 증명, 서비스 계정 키, 비밀번호와 토큰을 코드/`.env`/주석에 두지 않음. `firebase_options.dart`에 보이는 Firebase 클라이언트 `apiKey`는 프로젝트 식별 설정이며 Gemini 서버 키와는 다름. 실제 호출은 App Check와 Firebase AI Logic 적용으로 보호함.
