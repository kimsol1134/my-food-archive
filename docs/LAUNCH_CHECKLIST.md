# Google Play 출시 상태 체크리스트 — 맛집 아카이브

> 이 문서는 저장소 관리자가 현재 출시 상태를 기록하는 체크리스트다. 독자용 화면 절차는 [Android 온라인 실습 자료](android/README.md), 서명과 빌드 재현 메모는 [`RELEASE.md`](./RELEASE.md)를 사용한다.
> 상태 표기: `[x]` 완료 · `[ ]` 남음 · `[~]` 부분/조건부.

## 1. 코드 & 기능 품질
- [x] Task 1~17 구현 완료 (기능 전체)
- [x] `flutter analyze` 0 issues
- [x] `flutter test` 통과 (위젯 스모크 테스트)
- [x] 에뮬레이터에서 UC-01~06 실기 검증
- [x] Fail-Safe 확인 (EXIF 부재/AI 실패/권한 거부 시 크래시 없음)
- [x] 토스트/키보드 폴리시 반영
- [ ] 실기기(물리 디바이스) 1대 이상에서 최종 스모크 테스트

## 2. 앱 아이덴티티
- [x] 앱 이름 "My Food Archive" (`strings.xml` → 매니페스트, iOS와 동일)
- [x] 런처 아이콘 (iOS의 Liquid Glass Polaroid 원본으로 Android 전 해상도 생성)
- [x] `applicationId` 확정: `com.solkim.my_food_archive`
- [x] 버전 `1.0.0+5` (versionName / versionCode)

## 3. 빌드 & 서명 ⚠️ (출시 직전 필수)
- [x] release 서명 배선 (`key.properties` 기반, 없으면 디버그 폴백)
- [x] AAB 빌드 파이프라인 검증 (`flutter build appbundle --release` 성공)
- [x] **업로드 키스토어 생성** (`upload-keystore.jks`) — 저장소에는 미포함
- [x] **`android/key.properties` 작성** — 저장소에는 미포함
- [ ] 키스토어 + 비밀번호 **별도 안전한 곳에 2차 백업**
- [x] **서명된 AAB 빌드 및 내부 테스트 업로드**

## 4. 권한 & 개인정보 (Play 정책)
- [x] 권한 최소화 확인 (`INTERNET`만 선언, Photo Picker 사용, 사진·위치 권한 없음)
- [x] **개인정보처리방침 본문과 앱 내부 화면** 준비 (`docs/privacy-policy.md`)
- [ ] Play Console에 공개 개인정보처리방침 URL 입력
- [ ] **데이터 보안 양식** 작성 (수집 데이터/전송 여부)
- [ ] 사용자 선택 사진이 Firebase AI Logic/Gemini로 전송된다는 설명이 앱·방침·데이터 보안 양식에서 일치하는지 확인

## 5. 스토어 등록정보 자산
- [ ] 앱 아이콘 512×512 (스토어용)
- [ ] 피처 그래픽 1024×500
- [x] Android 앱 스크린샷 6장 준비 (`docs/book-screenshots/android-app/`)
- [ ] 앱 짧은 설명 / 자세한 설명 (한국어)
- [ ] 카테고리(음식/라이프스타일) · 콘텐츠 등급 설문 · 대상 연령

## 6. Play Console
- [x] 개발자 계정 등록
- [x] 앱 생성 + 기본 정보 입력
- [x] **Play App Signing** 활성화
- [x] 내부 테스트 트랙에 AAB 업로드
- [x] Firebase Android 앱·Google Services·App Check Play Integrity 연결
- [ ] 내부 테스트 설치본에서 Gemini 자동 분석 최종 확인
- [ ] 앱 콘텐츠와 기본 스토어 등록정보 완료
- [ ] 비공개 테스트 시작 및 12명 이상 참여 상태 확인
- [ ] Play Console에 신청 가능 상태가 표시될 때까지 테스트 유지
- [ ] 프로덕션 접근 신청 및 승인 확인
- [ ] 프로덕션 출시 제출
- [ ] 앱 심사 승인 뒤 Google Play 공개 링크 확인

## 7. v1 범위 확인
- [x] **Firebase AI Logic 기반 Gemini 자동 태깅 포함**
- [x] Debug = App Check Debug Provider, Release = Play Integrity 분리
- [x] 알림/지도/공유/다크모드/백엔드 미포함 (MVP 범위 외)

## 8. 출시 후
- [ ] 첫 크래시/ANR 모니터링 (Play Console → 품질)
- [ ] 리뷰 대응
- [ ] 기능 변경 후 새 AAB를 올릴 때마다 `versionCode` 증가
