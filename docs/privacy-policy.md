# My Food Archive 개인정보처리방침

- 앱 이름: My Food Archive(마이 맛집 아카이브)
- 개발자: solkim
- 시행일: 2026년 7월 12일
- 최종 수정일: 2026년 8월 12일
- 문의: [kimsol1134@gmail.com](mailto:kimsol1134@gmail.com)

## 1. 처리하는 정보

앱은 사용자가 직접 입력하거나 사진에서 추출한 다음 정보를 처리합니다.

- 식당명, 메뉴명, 카테고리
- 사용자가 선택한 음식 사진
- 사진에 포함된 촬영 날짜와 위치 메타데이터
- Firebase AI Logic이 처리하는 SDK·앱 버전·모델 정보와 Firebase Authentication 서비스 식별자
- 앱 기능 보호를 위한 Firebase App Check 사용자 에이전트와 기기 무결성 증명 정보

## 2. 이용 목적과 처리 위치

식당명, 메뉴명, 카테고리, 날짜, 위치와 사진은 맛집 기록 저장·검색·수정·삭제 기능을 제공하기 위해 사용자의 기기 내 앱 전용 저장 공간에 보관됩니다. 개발자는 이 기록을 별도 서버에 저장하거나 사용자 계정과 연결하지 않습니다.

사용자가 음식 사진을 선택하면 메뉴명과 카테고리를 자동으로 분석하기 위해 사진이 Firebase AI Logic을 거쳐 Google Gemini 서비스로 전송됩니다. 사진 파일에는 촬영 날짜나 위치 같은 메타데이터가 포함되어 있을 수 있습니다. 이 전송은 사용자가 사진을 선택한 직후 자동으로 발생하며, 분석 결과는 앱 화면을 채우는 용도로 사용됩니다.

Firebase AI Logic은 SDK 버전, 앱 버전과 호출한 모델명 같은 서비스 정보를 처리할 수 있습니다. Firebase Authentication은 AI 서비스 요청에 필요한 식별자를 생성할 수 있으며, 이는 앱의 회원가입이나 사용자 로그인 기능을 뜻하지 않습니다.

Firebase App Check는 무단 API 호출과 변조된 앱의 접근을 막기 위해 Firebase 사용자 에이전트와 기기 무결성 증명 정보를 처리할 수 있습니다. iPhone에서는 Apple App Attest 또는 DeviceCheck의 증명 객체·토큰을, Android에서는 Google Play Integrity 관련 정보를 사용할 수 있습니다.

## 3. 제3자 서비스

앱은 다음 외부 서비스를 사용합니다.

- Firebase Core
- Firebase AI Logic
- Firebase Authentication(Firebase AI Logic 내부 요청에 사용)
- Firebase App Check
- Google Gemini API
- Apple App Attest / DeviceCheck(iPhone 앱 무결성 확인)
- Google Play Integrity(Android 앱 무결성 확인)

각 서비스의 데이터 처리는 Google 또는 Apple의 약관과 개인정보처리방침의 적용을 받을 수 있습니다. Firebase SDK별 처리 정보는 [Firebase의 App Store 데이터 공개 안내](https://firebase.google.com/docs/ios/app-store-data-collection)에서 확인할 수 있습니다.

## 4. 보관과 삭제

맛집 기록과 복사된 사진은 사용자가 기록을 삭제할 때 함께 삭제됩니다. 앱을 삭제하면 운영체제가 앱 전용 저장 공간의 데이터를 제거합니다. 개발자는 사용자 기록이나 사진을 별도 서버에 보관하지 않습니다. 외부 AI 서비스의 일시 처리와 보관은 해당 서비스의 정책 및 설정에 따릅니다.

## 5. 계정, 광고와 아동 대상 여부

앱은 회원가입과 사용자 로그인 기능을 제공하지 않으며 광고를 표시하지 않습니다. 어린이를 주 대상으로 만든 서비스가 아닙니다.

## 6. 보안

앱은 운영체제의 앱 전용 저장 공간을 사용합니다. Firebase AI 요청은 App Check로 보호하며, iPhone에서는 App Attest와 DeviceCheck 대체 경로를, Android에서는 Play Integrity를 사용합니다. Gemini API의 서버 자격 증명은 앱 코드에 포함하지 않습니다.

## 7. 문의와 변경

개인정보 관련 문의는 위 이메일로 접수할 수 있습니다. 앱의 데이터 처리 방식이 바뀌면 이 문서와 앱 내부의 개인정보처리방침을 함께 갱신합니다.
