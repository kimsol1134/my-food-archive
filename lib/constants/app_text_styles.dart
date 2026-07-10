import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 디자인 가이드(Design_guide.md §3)에 정의된 타이포그래피.
///
/// 커스텀 폰트(ttf)는 추가하지 않고 시스템 기본 폰트를 사용한다.
/// (Android: Roboto / iOS: SF Pro — 시스템이 자동 적용)
///
/// `maxLines` / `overflow`는 `TextStyle`이 아닌 `Text` 위젯의 속성이므로,
/// Label/Caption을 사용하는 위젯에서 각각 지정한다.
/// - Label: `maxLines: 1`, `overflow: TextOverflow.ellipsis`
class AppTextStyles {
  AppTextStyles._();

  /// Large Title — 화면 최상단 제목
  static const TextStyle largeTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textMain,
  );

  /// Title — 상세화면 식당명
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textMain,
  );

  /// Body — 검색창, 입력폼, 상세 텍스트
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
  );

  /// Label — 갤러리 카드 식당명
  static const TextStyle label = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  /// Caption — 갤러리 캡션, 안내 문구
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );
}
