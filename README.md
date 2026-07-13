# My Food Archive

길벗 책 실습 앱 **마이 맛집 아카이브**의 예제 코드와 Android 온라인 실습 자료입니다.

## 책 독자용 경로

- [Android 온라인 실습 자료](docs/android/README.md): 책 15~18장의 Google Play 대응 흐름

책을 따라 직접 앱을 만들고 있다면 완성 코드를 복사하기보다 `docs/android/README.md`의 장별 안내를 먼저 사용하세요. 이 저장소의 코드는 막힌 설정을 비교하거나 최종 결과를 검증하는 참고본입니다.

## 예제 앱 실행

이 저장소 자체도 Android에서 분석·테스트·빌드할 수 있는 실행 가능한 참고본입니다.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Google Play용 AAB:

```bash
flutter build appbundle --release
```

업로드 가능한 릴리스 서명에는 저장소에 포함되지 않은 `android/key.properties`와 업로드 키스토어가 필요합니다. 책 실습과 Play Console 절차는 [Android 온라인 실습 자료](docs/android/README.md)를 참고하세요.

## Firebase 공개 설정과 비밀값

`android/app/google-services.json`과 `lib/firebase_options.dart`는 Firebase 클라이언트 식별 설정이며 예제 재현을 위해 저장소에 포함합니다. 서버 자격 증명이나 업로드 키가 아닙니다.

실제 API 보호는 다음 설정으로 수행합니다.

- Debug 빌드: Firebase App Check Debug Provider
- Google Play 빌드: App Check Play Integrity
- Gemini 호출: Firebase AI Logic enforcement

업로드 키스토어, `android/key.properties`, 서비스 계정 키, 비밀번호는 커밋하지 않습니다.

## 저장소 관리와 출판 검수

아래 문서는 독자 실습이 아니라 저장소 관리와 출판 검수에 사용합니다.

- [Google Play 배포용 프로젝트 메모](docs/RELEASE.md)
- [Windows/Android 통합 QA 가이드](docs/windows-android-one-file-guide.md)
- [Android 온라인 실습 자료 출판 인계표](docs/android/editorial-handoff.md)
- [Android 부록 인쇄 교정 체크리스트](docs/android/print-proof-checklist.md)
- [Android 온라인 실습 자료 정량 평가](docs/android/appendix-audit.md)

## 개인정보처리방침

- [My Food Archive 개인정보처리방침](docs/privacy-policy.md)
- [지원 및 개인정보 문의](https://github.com/kimsol1134/my-food-archive/issues/new)
