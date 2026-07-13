# Android 부록 배포 준비도 정량 평가

평가일: 2026-07-13

이 평가는 Android 앱 개발과 Google Play 배포가 처음인 독자가 용어부터 실제 Google Play 배포 준비까지 스스로 도달할 수 있는지를 기준으로 한다.

## 결과 요약

| 평가 항목 | 가중치 | 점수 | 가중 점수 | 확인 근거 |
|---|---:|---:|---:|---|
| 기술 정확성 | 25% | 9.8 | 2.45 | target SDK 36, Photo Picker 정책, Play Integrity provider와 Firebase AI Logic App Check `ENFORCED` 확인 |
| 빌드·재현성 | 20% | 9.8 | 1.96 | analyze 0건, test 2/2, 비디버그 키로 서명한 release AAB 43.9MB 재생성, GitHub Actions 통과 |
| 실제 배포 완결성 | 20% | 9.0 | 1.80 | App Check 강제 적용, Play App Signing SHA 대조, 에뮬레이터 Gemini 호출 성공. Google Play 설치본과 외부 심사는 별도 확인 필요 |
| 초보 독자 사용성 | 15% | 9.8 | 1.47 | Android 용어 사전, 장별 시작점, 예상 시간·실패 대응을 제공하고 Android 작업 순서만 설명 |
| 책 본문 연속성 | 10% | 9.9 | 0.99 | 원고·랜딩 페이지·온라인 자료의 장별 복귀 지점과 인쇄 URL을 통일 |
| 시각 안내 | 10% | 9.4 | 0.94 | Android 앱 6장, Play Console 14장, 인쇄 교정표, App Check 실행 증거 화면 관리 |
| **종합** | **100%** |  | **9.61 / 10** | 반올림 **9.6 / 10** |

이전 점검의 4.2/10에서 9.6/10으로 올랐다. 가장 큰 개선은 Android를 처음 접하는 독자가 별도 플랫폼 용어를 배우지 않고도 “계정 → AAB → 내부 테스트 → 실제 기기 → 공개” 순서를 이해하도록 전체 설명을 다시 쓴 점이다.

편집 원고와 온라인 자료의 연결만 따로 보면 출판 준비도는 **9.8/10**이다. 고정 랜딩 페이지, 실스캔 QR, 장별 복귀 지점, 그림 캡션, 개인정보 가림 기준이 정리되어 편집자가 바로 검수할 수 있다.

## 자동 검증 결과

- `flutter analyze`: 문제 0건
- `flutter test`: 2/2 통과
- 현재 작업 폴더 `flutter build appbundle --release`: 성공, 43.9MB
- 새 복제본 `flutter pub get → analyze → test → build appbundle --release`: 전부 성공
- 새 복제본 AAB: `versionCode 5`, `targetSdkVersion 36`
- 최종 병합 매니페스트: 광범위 사진·위치 권한 없음
- 로컬 Markdown 링크: 누락 0건
- Firebase Android 클라이언트 설정과 Google Services Gradle 플러그인: 저장소에서 재현 가능
- Play Integrity provider 등록과 Firebase AI Logic App Check `ENFORCED`: API 재조회 확인
- App Check 강제 적용 뒤 Android 에뮬레이터 Gemini 자동 채움: 성공
- Play App Signing의 앱 서명 SHA-256과 업로드 키 SHA-256이 Firebase Android 앱 등록값과 일치
- 독자용 Android 자료의 배포 플랫폼 비교 용어: 0건
- 개인정보처리방침: 앱 내부 화면과 공개 문서 모두 존재

상세 근거는 [`release-verification-2026-07-12.md`](release-verification-2026-07-12.md)에 기록했다.

## 독자가 실제 배포 전에 반드시 직접 확인할 것

다음 항목은 로컬 코드나 CI만으로 합격 처리할 수 없다.

1. 내부 테스트 링크로 Google Play에서 설치한 출시본에서 실제 음식 사진 한 장의 Gemini 자동 채움이 성공하는지 확인한다.
2. 새 개인 개발자 계정이면 비공개 테스트 12명·14일과 프로덕션 접근 심사를 통과한다.
3. 개인정보처리방침 URL과 종이책의 Android 고정 URL이 로그인 없이 열리는지 확인한다.

1번까지 성공하면 “Google Play 설치본까지 기술적으로 배포 가능”, 2~3번까지 끝나면 “사용자에게 공개 가능”으로 판정한다.

## 남은 개선점

- Play Console 캡처는 온라인 자료용 타이트 크롭이다. 종이책 본문에 120mm보다 크게 넣기로 결정하면 해당 화면만 브라우저 원본 해상도로 다시 캡처해야 한다.
- Play Console 화면은 자주 바뀐다. 문서의 기준일과 공식 링크를 출시 직전에 다시 확인해야 한다.
- Windows 통합 가이드는 의도적으로 책 전체 실습을 담아 길다. 급한 독자는 Android README의 장별 바로가기와 17~18장 공개 로드맵을 먼저 사용해야 한다.
