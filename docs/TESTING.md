# 완성 참고본의 SDK와 테스트

## 고정한 Flutter 버전

현재 개발·자동 검증 기준은 **Flutter 3.41.6 stable / Dart 3.11.4**입니다. Flutter 버전의 기준 파일은 저장소 루트의 `.flutter-version`입니다. iOS와 Android 자동 검증이 이 파일을 읽어 같은 Flutter를 설치합니다.

`pubspec.yaml`의 `environment.sdk: ^3.11.4`는 Dart 호환 범위입니다. 특정 Flutter 설치 버전을 고정하는 설정은 아닙니다.

로컬에서는 [Flutter 공식 SDK 보관함](https://docs.flutter.dev/install/archive)에서 자신의 운영체제와 CPU에 맞는 3.41.6을 설치하고, 아래 명령으로 Flutter 3.41.6과 Dart 3.11.4가 표시되는지 확인합니다. 이미 다른 프로젝트에서 사용하는 Flutter가 있다면 별도 경로에 설치하고 이 프로젝트의 터미널에서 해당 SDK를 사용합니다. `.flutter-version` 파일만 추가한다고 로컬 Flutter가 자동 전환되지는 않습니다.

```sh
flutter --version
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
```

`pubspec.lock`과 iOS의 `Podfile.lock`은 저장소에 포함됩니다. 자동 검증은 잠금 파일을 유지한 채 의존성을 설치하며, 이후 분석·테스트·빌드에서 패키지를 다시 결정하지 않습니다. SDK를 올릴 때는 `.flutter-version`을 수정한 PR에서 양 플랫폼 빌드와 아래 테스트를 다시 확인합니다. 기존 `book-v1.0.1` 태그와 ZIP은 변경하지 않습니다.

## 자동으로 확인하는 동작

| 테스트 | 확인하는 사용자 동작 |
|---|---|
| `archive_persistence_test.dart` | 저장한 필드와 사진이 DB를 닫고 다시 열어도 유지됨 |
| 같은 파일 | 여러 검색어를 모두 포함하는 결과, 공백 처리, 날짜순 정렬 |
| 같은 파일 | 수정 즉시 현재 검색 결과 갱신, 재실행 후 수정 유지, 중복 방지 |
| 같은 파일 | 기록과 연결된 사진 삭제, 다른 사진 보존, 사진이 이미 없어도 삭제 성공 |
| 같은 파일 | 이전 형식의 검색 키워드가 재생성되어 기존 기록을 검색할 수 있음 |
| `manual_record_flow_test.dart` | AI 대기 중 저장 차단, 실패 후 수동 입력·저장·DB 재열기 |
| 같은 파일 | AI 제안 수정 후 저장, 식당명 공백만 입력했을 때 저장 차단 |
| `widget_test.dart` | 첫 화면 표시와 개인정보처리방침 진입 |

테스트는 임시 폴더의 실제 Hive DB를 사용합니다. AI와 사진 메타데이터 응답만 테스트 대역으로 바꾸므로 계정·API 호출·과금 없이 입력 화면을 검증할 수 있습니다. 저장 버튼의 활성 상태를 확인한 뒤 버튼에 연결된 비동기 저장 동작을 실행하고, DB를 다시 열어 결과를 확인합니다.

이 검사는 실제 앱 프로세스의 강제 종료나 기기 사진 선택기, App Check 인증 성공, 실제 Gemini 응답을 대신하지 않습니다. 해당 동작은 에뮬레이터·실기기에서 확인합니다. 릴리스 업로드 키도 테스트에 사용하지 않습니다.
