# 책의 현재 장에서 자료 찾기

공식 저장소는 [kimsol1134/my-food-archive](https://github.com/kimsol1134/my-food-archive)입니다. 책에서 온라인 실습 자료를 안내하면 이 저장소에서 현재 장을 찾습니다.

본문을 먼저 따라 자신의 문서를 만들고, 아래 자료는 결과를 비교할 때 사용합니다. 완성 코드는 별도 폴더에 내려받습니다.

| 책 | 참고 자료 | 확인할 결과와 다음 단계 |
|---|---|---|
| 3장 | [기획서](PRD.md) | 내 앱의 목적과 핵심 기능을 정하고 4장으로 갑니다. |
| 4장 | [iPhone 기술 설계서](TRD.md) · [Android 기술 설계서](TRD_android.md) | 만들 앱에 맞는 기술을 고릅니다. 아래의 최종본 차이를 먼저 읽습니다. |
| 5장 | [화면 구조](IA.md) · [사용 흐름](Usecase.md) · [디자인](Design_guide.md) | 화면·이동·디자인을 정하고 6장으로 갑니다. |
| 6~7장 | [iPhone 구현계획서](Implement_plan.md) · [Android 구현계획서](Implement_plan_android.md) | 내 문서로 작업 순서를 만들고 Task 1을 진행합니다. |
| 6~9장 Android | [Android 개발 준비](android/development-guide.md#개발-준비) | 도구 설치와 에뮬레이터 실행 후 해당 장의 다음 실습으로 돌아갑니다. |
| 8~9장 | [완성 코드](../lib/) | 화면 뼈대와 데이터 구조를 비교합니다. 최종본에는 이후 장의 기능도 포함되어 있습니다. |
| 10~11장 | [Android Firebase 연결](android/development-guide.md#firebase-연결) · [AI 서비스](../lib/services/vision_ai_service.dart) | 10장에서 연결과 사진 정보를 준비하고, 11장에서 AI 입력을 확인합니다. |
| 12~14장 | [저장 서비스](../lib/services/local_db_service.dart) · [입력 화면](../lib/screens/add_edit_record_screen.dart) | 저장·검색·수정·삭제와 AI 실패 시 수동 입력을 확인합니다. |
| 15~16장 | [Android 내부 테스트](android/google-play-internal-test-guide.md) | Android는 안내된 범위를 진행한 뒤 15.5절 또는 16.5절로 돌아갑니다. iPhone은 책을 따릅니다. |
| 17~18장 | [App Store 체크리스트](AppStore_Submission_Checklist.md) · [Android 공개 로드맵](android/release-roadmap.md) | 플랫폼별 제출과 공개 상태를 확인한 뒤 책의 첫 사용자 피드백 흐름으로 이어갑니다. |
| 19장 | 책 본문 | 받은 피드백을 정리하고 앱을 소개합니다. 별도 코드는 없습니다. |

## 책의 중간 결과와 최종 예시본의 차이

이 저장소의 TRD와 구현계획서는 **10장 이후 Firebase AI Logic 전환과 출시 전 수정을 반영한 최종 예시본**입니다. 4~9장의 문서와 문장이 같지 않아도 정상입니다.

- 책 10장은 기존 AI 연결 방식을 다시 검토하고 Firebase AI Logic으로 바꾸는 과정입니다. 최종 문서는 이 변경을 이미 포함합니다.
- 구현계획서의 체크 표시는 저자의 완료 기록입니다. 내 프로젝트의 완료 상태가 아닙니다.
- 최종 코드는 개인정보처리방침과 출시 전 화면 개선도 포함합니다. 9장의 화면 뼈대와 비교할 때는 현재 만들고 있는 부분만 봅니다.
- 자신의 문서를 최종 예시로 덮어쓰지 않습니다. 책의 검토 프롬프트로 내 문서를 수정하고 다음 장으로 진행합니다.

## 고정 참고본과 최신 안내

[book-v1.0.1 ZIP](https://github.com/kimsol1134/my-food-archive/archive/refs/tags/book-v1.0.1.zip)은 기존 출판 참고본입니다. 다운로드 내용은 그대로 보존합니다. 이 저장소의 현재 안내에는 이후 발견한 설명 보완이 반영될 수 있습니다. ZIP에서 안내를 읽다가 막히면 [현재 시작 안내](https://github.com/kimsol1134/my-food-archive/blob/main/START_HERE.md)를 확인합니다.
