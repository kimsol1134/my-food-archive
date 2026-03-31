# 📱 [마이 맛집 아카이브] MVP 디자인 및 UI/UX 구현 가이드 (최종본)

## 1. Design Concept Overview
- **방향성:** iOS 기본 앱(사진, 메모 등)과 시각적으로 완벽히 동화되는 'Pure Native(순정 애플 스타일)'.
- **테마 고정 [AI 필수 지시]:** 본 앱은 **라이트 모드(Light Mode) 전용**으로 개발한다. 사용자의 기기가 다크모드여도 앱은 무조건 라이트 모드로 강제 고정(`ThemeData.light()`)하여 렌더링할 것.

## 2. Color System (Light Mode Only)
[AI 코딩 에이전트 필수 지시사항] 하드코딩을 피하고, 아래 컬러를 기준으로 Flutter의 `colorScheme` 또는 상수 클래스(`AppColors`)를 구성할 것.

| 역할 | Hex Code | 용도 및 설명 |
| :--- | :--- | :--- |
| **Primary** | `#007AFF` | 버튼, 활성화된 아이콘 (iOS System Blue) |
| **Background** | `#FFFFFF` | 앱의 기본 전체 배경색 (Scaffold Background) |
| **Surface** | `#F2F2F7` | 검색창 배경, 텍스트 입력창(TextField) 배경 (iOS System Gray 6) |
| **Text Main** | `#000000` | 주요 타이틀, 본문 텍스트, 식당명 |
| **Text Sub** | `#8E8E93` | 캡션, 부가 정보(지역, 날짜, 카테고리 등), 비활성화 텍스트 (iOS System Gray) |
| **Divider** | `#C6C6C8` | 목록 구분선 (Opacity를 50% 정도 낮춰서 사용 가능) |
| **Destructive**| `#FF3B30` | 삭제 버튼, 에러 메시지 (iOS System Red) |

## 3. Typography
[AI 코딩 에이전트 필수 지시사항] 커스텀 폰트 파일(ttf)을 추가하지 마라. 시스템 기본 폰트(Apple SD Gothic Neo / SF Pro)가 자동으로 적용되도록 기본 `TextStyle`만 지정할 것.

- **Large Title (화면 최상단 제목)**: `fontSize: 28`, `fontWeight: FontWeight.bold`, `letterSpacing: -0.5`
- **Title (상세화면 식당명)**: `fontSize: 22`, `fontWeight: FontWeight.bold`
- **Body (검색창, 입력폼, 상세 텍스트)**: `fontSize: 17`, `fontWeight: FontWeight.w400`
- **Label (갤러리 카드 식당명)**: `fontSize: 15`, `fontWeight: FontWeight.w600`, `maxLines: 1`, `overflow: TextOverflow.ellipsis`
- **Caption (갤러리 캡션, 안내 문구)**: `fontSize: 13`, `fontWeight: FontWeight.w400`, `color: Text Sub`

## 4. Layout & UI Components

### 4.1. 전역(Global) 여백 시스템
- **Screen Margin (화면 좌우 여백):** `20px`
- **Border Radius (모서리 둥기):** - 이미지 썸네일: `8px`
  - 텍스트 입력창(TextField) 및 버튼: `10px`

### 4.2. HomeScreen (홈 화면)
- **검색창 (Search Bar):** 높이 `36px`, 배경 `Surface` 컬러. 좌측에 돋보기 아이콘. 안드로이드식 밑줄(Underline) 절대 금지.
- **갤러리 그리드 (GridView):** `crossAxisCount: 2`, `crossAxisSpacing: 12`, `mainAxisSpacing: 16`. 썸네일 이미지는 `BoxFit.cover`로 꽉 차게 렌더링.
- **Empty State (데이터가 0개일 때):** 화면 중앙 배치. `CupertinoIcons.photo_on_rectangle` 아이콘(사이즈 64, Text Sub 컬러) + "아직 저장된 맛집이 없어요." 텍스트 (Body 사이즈, Text Sub 컬러).
- **FAB (+ 버튼):** 우측 하단 고정. 크기 `56x56`, 배경 `Primary` 컬러. 은은한 그림자(`blurRadius: 10`, `color: black.withOpacity(0.15)`).

### 4.3. AddEditRecordScreen (기록 추가/수정 화면)
- **AI 분석 로딩 오버레이 (가장 중요):** 이미지 분석 중일 때 화면 전체를 반투명한 검은색(`black.withOpacity(0.3)`)으로 덮고, 중앙에 `CupertinoActivityIndicator`와 "AI가 사진을 분석하고 있어요..." 텍스트 노출. 이 동안 화면 터치 차단(IgnorePointer).
- **텍스트 입력창 (TextField):** 테두리와 밑줄이 없는 iOS 기본 스타일(`CupertinoTextField` 스타일 차용). 배경을 `Surface` 색상으로 채우고 `borderRadius: 10` 적용. 내부 Padding은 가로 `12`, 세로 `12`.
- **필수 입력 제어:** '식당명' TextField가 비어있으면 하단 '저장' 버튼의 배경색을 `Text Sub` 색상으로 변경하고 터치(onPressed)를 비활성화할 것.

### 4.4. DetailScreen (상세 보기 화면)
- **원본 이미지 뷰:** 화면 최상단에 원본 비율을 유지하되(`BoxFit.contain` 또는 화면 가로 너비에 맞춘 `BoxFit.cover`), 최대 높이를 화면의 40%로 제한.
- **메타 데이터 레이아웃:** 사진 하단에 식당명(Title)을 크게 배치하고, 그 아래 지역/메뉴/카테고리/날짜를 수직(Column)으로 여백 `8px`을 주어 깔끔하게 나열할 것.

## 5. Interaction & UX 지시사항 (Fail-Safe)
- **스크롤 물리 엔진:** iOS 특유의 화면 끝 바운스 효과(`BouncingScrollPhysics`)를 전역 스크롤에 적용할 것.
- **키보드 숨김:** 사용자가 텍스트 입력 중 빈 화면을 터치하면 키보드가 즉시 내려가도록 `FocusScope.of(context).unfocus()` 처리.
- **다이얼로그 (팝업):** 삭제 확인 창이나 권한 요청 안내는 안드로이드용 Material Dialog가 아닌, 반드시 `CupertinoAlertDialog`를 사용하여 iOS 네이티브 느낌을 강제할 것.
- **스낵바 대체:** 권한 거부 등 일시적 안내는 iOS에 스낵바가 없으므로 화면 하단 혹은 상단에 둥근 플로팅 토스트(Toast) 형태로 가볍게 띄울 것.