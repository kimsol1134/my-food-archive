import 'dart:convert';

/// Gemini Vision 분석 결과(Implement_plan_android.md Task 11).
///
/// 메뉴명과 카테고리만 담는다. 모델 응답이 깨졌거나 비어있으면 [tryParse]가
/// null을 돌려주어 호출부가 "직접 입력" 흐름으로 폴백한다(Fail-Safe).
class AiResult {
  const AiResult({required this.menuName, required this.category});

  final String menuName;
  final String category;

  /// 모델이 반환한 JSON 텍스트를 파싱한다.
  ///
  /// `responseMimeType: application/json`을 요청하지만, 혹시 코드펜스(```json)나
  /// 부가 텍스트가 섞여 와도 첫 `{` ~ 마지막 `}` 구간만 잘라 파싱한다.
  static AiResult? tryParse(String jsonText) {
    try {
      final start = jsonText.indexOf('{');
      final end = jsonText.lastIndexOf('}');
      if (start == -1 || end == -1 || end < start) return null;

      final decoded = jsonDecode(jsonText.substring(start, end + 1));
      if (decoded is! Map) return null;

      final menu = (decoded['menu'] ?? '').toString().trim();
      final category = (decoded['category'] ?? '').toString().trim();
      if (menu.isEmpty && category.isEmpty) return null;

      return AiResult(menuName: menu, category: category);
    } catch (_) {
      return null;
    }
  }
}
