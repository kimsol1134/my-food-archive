# Android 온라인 실습 자료

이 자료는 Android 앱 개발과 Google Play 배포가 처음인 독자를 위한 온라인 실습 가이드입니다. 사용 중인 컴퓨터가 Windows인지 macOS인지와 관계없이, 아래에서 현재 읽고 있는 장을 선택해 순서대로 진행하면 됩니다.

## 지금 시작할 곳

현재 읽는 장에 맞는 자료 하나만 열면 됩니다.

- 15~16장: **[Android 앱을 Google Play 내부 테스트에 올리기](google-play-internal-test-guide.md)**
- 17~18장: **[비공개 테스트에서 Google Play 공개까지](release-roadmap.md)**

Google Play 배포가 처음이라면 15~16장 자료부터 시작하세요. 개발자 계정, AAB, 서명, 테스트 트랙 같은 용어를 0절에서 먼저 설명합니다.

## 장별로 볼 곳

| 책 | 이 폴더에서 진행할 것 | 끝나면 돌아갈 곳 |
|---|---|---|
| 15장 | 가이드 0~10절 — Google Play Console 개발자 계정, 앱 만들기, 앱 번들 빌드, 내부 테스트 업로드, 실제 기기 설치 (8.1절은 건너뛰고 16장에서 사용) | 책 15.5절 |
| 16장 | 가이드 8절로 설치 확인 후 책 16.2절부터 진행. 앱을 고친 뒤 8.1절 "수정한 앱을 다시 내부 테스트에 올리는 절차" | 설치 확인 후 책 16.2절, 재업로드 후 책 16.5절 |
| 17장 | 공개 로드맵 1~7절 — 앱 콘텐츠 → 개인정보처리방침 → 데이터 보안 → 스토어 등록정보 → Firebase 릴리스 검증 → 비공개 테스트 → 프로덕션 접근 신청 | 책 17.5절 |
| 18장 | 공개 로드맵 8~10단계 — 프로덕션 트랙 출시, 정식 링크 확인, 마지막 점검. 아직 승인 전이라면 비공개 테스트 링크로 첫 사용자 확인 | 책 18.3절 |

## 예상 시간

- 개발자 계정 본인 확인: 바로 끝나지 않고 며칠 걸릴 수 있음
- 첫 내부 테스트 반영: 수분에서 길게는 48시간
- 새 개인 계정의 비공개 테스트: 최소 12명·14일
- 프로덕션 접근과 앱 심사: 추가 검토 시간 필요

책을 하루에 이어 읽더라도 Google Play 정식 공개는 같은 날 끝나지 않을 수 있습니다. 15~16장에서는 내부 테스트 설치를 목표로 하고, 17장에서 14일 테스트를 시작한 뒤 승인 전에는 비공개 테스트 링크로 18.3~18.4절을 진행합니다.

## 문제가 생겼을 때

Google Play Console의 화면 이름과 요구사항은 자주 바뀝니다. 이 자료의 텍스트와 실제 화면이 다르면 화면을 캡처해서 클로드 코드에게 보여 주세요. 캡처를 공유할 때는 계정 이메일, 결제 정보, 주소, 전화번호 같은 개인정보를 가립니다.

## 구현할 때 함께 볼 자료

- Windows에서 처음부터 끝까지 이어서 진행하는 통합 흐름: [`windows-android-one-file-guide.md`](../windows-android-one-file-guide.md)
- Android 기준 기술 설계서: [`TRD_android.md`](../TRD_android.md)
- Android 기준 구현계획서: [`Implement_plan_android.md`](../Implement_plan_android.md)

## 편집·검수용 자료

아래 자료는 독자가 실습할 때 읽지 않아도 됩니다.

- 고정 안내 페이지: https://kimsol1134.github.io/my-food-archive/android/
- 자료 원본: https://github.com/kimsol1134/my-food-archive/tree/main/docs/android
- [정량 평가 보고서](appendix-audit.md)
- [인쇄 교정 체크리스트](print-proof-checklist.md)
- [Firebase App Check·AAB 릴리스 검증 기록](release-verification-2026-07-12.md)
