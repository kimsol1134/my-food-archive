# Android 릴리스 검증 기록 — 2026-07-12

이 문서는 공개 저장소의 설정, Firebase App Check API, 로컬 릴리스 AAB와 Android 에뮬레이터를 같은 날 교차 확인한 기록입니다. 비밀키, 디버그 토큰, 인증서 지문은 기록하지 않습니다.

## Firebase와 App Check

| 확인 항목 | 결과 |
|---|---|
| Firebase 프로젝트 | `my-food-archive-dbc0c` 활성 상태 |
| Android 앱 | `com.solkim.my_food_archive` 등록됨 |
| 로컬 `google-services.json` | Firebase Android 앱의 패키지 이름과 일치 |
| Android provider | Play Integrity 등록됨, token TTL 3600초 |
| Play App Signing 인증서 | 앱 서명 SHA-256과 업로드 키 SHA-256 모두 Firebase Android 앱 등록값과 일치 |
| Firebase AI Logic App Check | `firebaseml.googleapis.com`을 `ENFORCED`로 전환하고 재조회 확인 |
| 개발용 검증 | Android 에뮬레이터의 debug provider token을 별도 등록 |

## 릴리스 AAB

2026-07-12에 `flutter clean → pub get → analyze → test → build appbundle --release`를 다시 실행했습니다.

| 확인 항목 | 결과 |
|---|---|
| `flutter analyze` | 문제 0건 |
| `flutter test` | 2/2 통과 |
| AAB | 43,942,828 bytes |
| 서명 | Android Debug 인증서가 아닌 업로드 키 서명 |
| package | `com.solkim.my_food_archive` |
| version | `1.0.0` / versionCode `5` |
| SDK | min 24 / target 36 |
| 광범위 사진 권한 | 없음 |
| 위치 권한 | 없음 |

## 강제 적용 뒤 Gemini 호출

App Check를 `ENFORCED`로 바꾼 뒤 Android 14 에뮬레이터에서 음식 사진을 선택했습니다. 메뉴 `토마토 스파게티`와 카테고리 `양식`이 자동으로 채워졌고, App Check 거부 로그는 없었습니다.

![App Check 강제 적용 뒤 Gemini 결과](../book-screenshots/verification/app-check-enforced-2026-07-12.png)

## 아직 사람과 실제 기기가 필요한 확인

에뮬레이터 debug provider 성공은 Firebase AI Logic 강제 적용과 앱 호출 경로가 맞다는 증거입니다. Play Console의 앱 서명 화면과 Firebase CLI의 Android 앱 SHA 목록을 직접 대조해 앱 서명 키와 업로드 키가 모두 등록된 것도 확인했습니다.

아직 남은 확인은 Google Play 내부 테스트 링크로 **실제 Android 기기**에 설치한 릴리스 빌드에서 같은 Gemini 자동 채움을 실행하는 것입니다.

이 확인이 끝나야 “Google Play가 서명한 설치본의 Play Integrity 검증 완료”로 판정합니다.
