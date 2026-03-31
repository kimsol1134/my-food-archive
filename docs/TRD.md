# 📱 [마이 맛집 아카이브] MVP 기술 설계 문서 (TRD) - 최종본

## 1. 아키텍처 개요 (Architecture Overview)
본 앱은 백엔드 서버가 없는 **클라이언트 전용(Client-Side Only) 아키텍처**로 설계되었습니다. 모든 데이터는 기기 내부에 저장되며, 이미지 분석을 위한 Vision AI 통신만 외부(Google Gemini API)와 이루어집니다.

* **데이터 흐름 (Data Flow):**
    1. **사진 선택 및 EXIF 추출:** 사용자가 기기 갤러리에서 사진을 선택하면, 앱이 사진의 메타데이터(EXIF)에서 촬영 날짜와 GPS 좌표(위도/경도)를 추출합니다.
    2. **지오코딩 (역방향):** 추출된 GPS 좌표를 기기의 OS 기본 기능을 활용해 텍스트 형태의 주소(예: 연남동, 역삼동)로 변환합니다.
    3. **AI Vision 분석:** 원본 이미지를 Gemini API로 전송하여 '메뉴명'과 '카테고리'를 JSON 형태로 반환받습니다.
    4. **데이터 검증 및 수동 입력:** AI가 추출한 데이터와 위치 정보를 UI(TextField)에 뿌려주어 사용자가 확인 및 수정할 수 있게 하고, '식당명'을 추가로 입력받습니다.
    5. **로컬 저장 및 검색 최적화:** 모든 데이터를 NoSQL 로컬 데이터베이스에 저장합니다. 이때 빠른 검색을 위해 입력된 모든 텍스트를 공백 없이 합친 `searchKeyword` 필드를 함께 생성하여 저장합니다.

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
* **`VisionAIService`:** Google Gemini API를 호출합니다.
    * **[중요 프롬프트 지시]:** "제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. 응답은 반드시 `{"menu": "메뉴이름", "category": "카테고리명"}` 형태의 순수 JSON 포맷으로만 반환하라."
* **`LocalDBService`:** 로컬 DB(Hive)를 초기화하고, `ArchiveItem`의 CRUD(생성, 읽기, 수정, 삭제)를 담당합니다. 검색 시 `searchKeyword.contains(검색어)` 로직을 사용하여 쿼리 속도를 극대화합니다.

### C. UI 화면 (UI Screens)
* **`HomeScreen` (메인 갤러리 뷰):**
    * 상단: 검색창 (`TextField`). 텍스트 입력 시 하단 그리드가 실시간으로 필터링됨.
    * 본문: `GridView.builder`를 사용한 사진 썸네일 바둑판 배열.
    * 하단: Floating Action Button (사진 추가).
* **`AddRecordScreen` (입력 및 AI 분석 화면):**
    * 진입 즉시 로딩 스피너 표시 (AI 분석 및 위치 추출 대기).
    * 완료 시: 사진 썸네일과 함께 식당명, 위치, 메뉴명, 카테고리를 입력/수정할 수 있는 `TextField` 목록 표시. (데이터가 누락되거나 틀려도 사용자가 직접 수정 가능하도록 예외 처리).
    * 하단: '저장' 버튼.
* **`DetailScreen` (상세 보기 화면):**
    * 사진 원본과 함께 저장된 텍스트 정보를 깔끔하게 나열하는 읽기 전용 뷰.

## 3. 기술 스택 및 선택 근거 (Tech Stack)

| 구분 | 추천 패키지 | 선택 근거 |
| :--- | :--- | :--- |
| **프레임워크** | `Flutter` | 단일 코드베이스로 iOS 앱을 가장 빠르게 구축. |
| **상태 관리** | `Provider` | MVP의 복잡도에 가장 적합하고 에이전트가 보일러플레이트 없이 깔끔하게 짤 수 있는 표준 상태 관리. |
| **로컬 DB** | `Hive` | NoSQL 방식으로 SQL 테이블 생성(Schema) 없이 객체를 바로 저장하여 개발 속도를 2배 이상 단축. 검색(`contains`) 처리에도 매우 빠름. |
| **사진 및 메타데이터** | `photo_manager` (또는 `image_picker` + `exif` 조합) | iOS의 강력한 개인정보 보호 정책 속에서도 사진의 GPS 메타데이터(위치)를 훼손 없이 가져오기 위함. |
| **위치 변환** | `geocoding` | OS에 내장된 무료 역지오코딩 기능을 사용하여 Google Maps API 등의 추가 비용을 방지. |
| **AI 비전** | `google_generative_ai` | 사진 분석에 탁월한 Gemini 프레임워크 공식 지원 패키지. |

## 4. [코딩 에이전트 필수 지시 사항] iOS 권한 및 예외 처리
코딩을 시작할 때 다음 사항을 반드시 `pubspec.yaml` 및 `ios/Runner/Info.plist`에 최우선으로 반영할 것.

* **iOS 권한 설정 (`Info.plist`):**
  * `NSPhotoLibraryUsageDescription`: "음식 사진을 불러오고 저장하기 위해 갤러리 접근 권한이 필요합니다."
  * `NSLocationWhenInUseUsageDescription`: "사진의 촬영 위치(EXIF)를 기반으로 맛집의 지역 정보를 자동으로 입력하기 위해 권한이 필요합니다."
* **예외 처리 강제 (Fail-Safe):** * 캡처된 사진이거나 사용자가 위치 권한을 거부하여 EXIF GPS 데이터가 없는 경우, 앱이 크래시되지 않고 위치 필드를 비워둔 상태로 UI를 렌더링해야 함.
  * 네트워크 오류나 API Limit으로 Gemini 응답이 실패할 경우, 무한 로딩에 빠지지 않고 타임아웃 처리 후 사용자에게 "정보를 직접 입력해 주세요"라는 알림표시와 함께 빈 `TextField`를 제공해야 함.
