import 'package:flutter/material.dart';

/// 디자인 가이드(Design_guide.md §2)에 정의된 Light Mode 전용 컬러 시스템.
///
/// 하드코딩을 피하고 항상 이 상수를 통해 컬러를 참조한다.
/// 본 앱은 라이트 모드 전용이므로 다크 모드 변형 컬러는 정의하지 않는다.
class AppColors {
  AppColors._();

  /// 버튼, 활성화된 아이콘 (iOS System Blue)
  static const Color primary = Color(0xFF007AFF);

  /// 앱의 기본 전체 배경색 (Scaffold Background)
  static const Color background = Color(0xFFFFFFFF);

  /// 검색창 배경, 텍스트 입력창(TextField) 배경 (iOS System Gray 6)
  static const Color surface = Color(0xFFF2F2F7);

  /// 주요 타이틀, 본문 텍스트, 식당명
  static const Color textMain = Color(0xFF000000);

  /// 캡션, 부가 정보(지역/날짜/카테고리), 비활성화 텍스트 (iOS System Gray)
  static const Color textSub = Color(0xFF8E8E93);

  /// 목록 구분선 (필요 시 Opacity 50% 정도로 낮춰 사용)
  static const Color divider = Color(0xFFC6C6C8);

  /// 삭제 버튼, 에러 메시지 (iOS System Red)
  static const Color destructive = Color(0xFFFF3B30);
}
