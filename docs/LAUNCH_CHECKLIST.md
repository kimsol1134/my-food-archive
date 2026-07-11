# ✅ 출시 전 체크리스트 — 맛집 아카이브 (Google Play)

> 상세 절차/명령은 [`RELEASE.md`](./RELEASE.md) 참조. 이 문서는 "빠짐없이 했는지" 확인용 체크리스트다.
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
- [x] 버전 `1.0.0+1` (versionName / versionCode)

## 3. 빌드 & 서명 ⚠️ (출시 직전 필수)
- [x] release 서명 배선 (`key.properties` 기반, 없으면 디버그 폴백)
- [x] AAB 빌드 파이프라인 검증 (`flutter build appbundle --release` 성공)
- [ ] **업로드 키스토어 생성** (`upload-keystore.jks`) — RELEASE.md §1
- [ ] **`android/key.properties` 작성** (비밀번호/별칭/경로) — RELEASE.md §2
- [ ] 키스토어 + 비밀번호 **안전한 곳에 백업** (분실 시 업데이트 불가)
- [ ] **서명된 AAB 재빌드** 후 debug 서명이 아님을 확인 (`keytool -printcert -jarfile`)

## 4. 권한 & 개인정보 (Play 정책)
- [x] 권한 최소화 확인 (INTERNET, READ_MEDIA_IMAGES 등 사진 접근만; 위치 권한 없음)
- [ ] **개인정보처리방침 URL** 준비 (사진 접근 → 필수). "데이터는 기기 로컬 저장, 서버 미전송" 명시
- [ ] **데이터 세이프티 폼** 작성 (수집 데이터/전송 여부)
- [ ] 사진 접근 사유가 스토어 설명/폼과 일치하는지 확인

## 5. 스토어 등록정보 자산
- [ ] 앱 아이콘 512×512 (스토어용)
- [ ] 피처 그래픽 1024×500
- [ ] 스크린샷 2장 이상 (`build/verify/`의 캡처 활용 가능)
- [ ] 앱 짧은 설명 / 자세한 설명 (한국어)
- [ ] 카테고리(음식/라이프스타일) · 콘텐츠 등급 설문 · 대상 연령

## 6. Play Console
- [ ] 개발자 계정 등록 (최초 1회, $25)
- [ ] 앱 생성 + 기본 정보 입력
- [ ] **Play App Signing** 활성화 (업로드 키로 업로드 → Google이 앱 서명 키 관리)
- [ ] 내부 테스트 트랙에 AAB 업로드 → 테스터 확인
- [ ] 프로덕션 심사 제출

## 7. v1 범위 확인 (의도적 제외 항목)
- [x] **AI 자동 태깅 미포함** (Firebase 미구성) — 이후 업데이트. `main.dart` try/catch 방어로 나머지 정상 동작
- [x] 알림/지도/공유/다크모드/백엔드 미포함 (MVP 범위 외)

## 8. 출시 후
- [ ] 첫 크래시/ANR 모니터링 (Play Console → 품질)
- [ ] 리뷰 대응
- [ ] (다음 버전) Firebase 연동 → AI 자동 태깅 추가 시 `versionCode` 증가 (`1.0.0+2`) — RELEASE.md 하단 참조
