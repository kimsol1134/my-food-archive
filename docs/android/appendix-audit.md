# Android 부록 배포 준비도 정량 평가

평가일: 2026-07-12

이 평가는 GitHub 저장소의 Android 부록을 처음 읽는 독자가 책 15~18장의 iOS 흐름에서 이질감 없이 갈라져, 실제 Google Play 배포 준비까지 도달할 수 있는지를 기준으로 한다.

## 결과 요약

| 평가 항목 | 가중치 | 점수 | 가중 점수 | 확인 근거 |
|---|---:|---:|---:|---|
| 기술 정확성 | 25% | 9.3 | 2.33 | target SDK 36, Photo Picker 권한 정책, Firebase AI/App Check 출시 게이트 반영 |
| 빌드·재현성 | 20% | 9.5 | 1.90 | 새 복제본에서 analyze 0건, test 2/2, release AAB 43.9MB 생성 |
| 실제 배포 완결성 | 20% | 8.3 | 1.66 | AAB·서명·Play 흐름은 준비됨. 내부 테스트 설치본의 Gemini 성공과 외부 심사는 별도 확인 필요 |
| 초보 독자 사용성 | 15% | 8.8 | 1.32 | 15~16장과 17~18장 경로 분리, 예상 시간·사람/에이전트 역할·실패 대응 명시 |
| 책 본문 연속성 | 10% | 9.1 | 0.91 | TestFlight 대응표와 장별 복귀 지점, 17~18장 직선형 로드맵 제공 |
| 시각 안내 | 10% | 8.6 | 0.86 | Android 앱 6장, Play Console 14장 연결. Play Store 실제 설치 화면 캡처는 남아 있음 |
| **종합** | **100%** |  | **8.98 / 10** | 반올림 **9.0 / 10** |

이전 점검의 4.2/10에서 9.0/10으로 올랐다. 가장 큰 개선은 “빌드 가능한가”와 “Play Console에서 출시 가능한가”를 분리하고, Firebase AI가 실제 출시 설치본에서 동작해야만 다음 트랙으로 갈 수 있도록 게이트를 만든 점이다.

## 자동 검증 결과

- `flutter analyze`: 문제 0건
- `flutter test`: 2/2 통과
- 현재 작업 폴더 `flutter build appbundle --release`: 성공, 43.9MB
- 새 복제본 `flutter pub get → analyze → test → build appbundle --release`: 전부 성공
- 새 복제본 AAB: `versionCode 5`, `targetSdkVersion 36`
- 최종 병합 매니페스트: 광범위 사진·위치 권한 없음
- 로컬 Markdown 링크: 누락 0건
- Firebase Android 클라이언트 설정과 Google Services Gradle 플러그인: 저장소에서 재현 가능
- 개인정보처리방침: 앱 내부 화면과 공개 문서 모두 존재

## 독자가 실제 배포 전에 반드시 직접 확인할 것

다음 항목은 로컬 코드나 CI만으로 합격 처리할 수 없다.

1. Play Console과 Firebase가 같은 Google Cloud 프로젝트의 Play Integrity API에 연결되어 있는지 확인한다.
2. Play App Signing의 **앱 서명 인증서 SHA-256**이 Firebase Android 앱에 등록되어 있는지 확인한다.
3. Firebase AI Logic의 App Check 적용 상태를 확인한다.
4. 내부 테스트 링크로 Google Play에서 설치한 출시본에서 실제 음식 사진 한 장의 Gemini 자동 채움이 성공하는지 확인한다.
5. 새 개인 개발자 계정이면 비공개 테스트 12명·14일과 프로덕션 접근 심사를 통과한다.
6. 이 브랜치가 `main`에 병합된 뒤 개인정보처리방침 URL이 로그인 없이 열리는지 확인한다.

4번까지 성공하면 “기술적으로 배포 가능”, 5~6번까지 끝나면 “사용자에게 공개 가능”으로 판정한다.

## 남은 개선점

- 실제 Android 기기의 Google Play 앱에서 보이는 설치·업데이트 화면 캡처 1장이 없다. 계정·테스터 정보가 보이지 않게 가린 실기기 캡처를 추가하면 시각 안내 점수는 9점대로 올라간다.
- Play Console 화면은 자주 바뀐다. 문서의 기준일과 공식 링크를 출시 직전에 다시 확인해야 한다.
- Windows 통합 가이드는 의도적으로 책 전체 실습을 담아 길다. 급한 독자는 Android README의 장별 바로가기와 17~18장 공개 로드맵을 먼저 사용해야 한다.
