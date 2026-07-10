import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/ai_result.dart';

/// Firebase AI Logic을 통해 Gemini Vision으로 음식 사진을 분석하는 서비스
/// (Implement_plan_android.md Task 11).
///
/// API 키는 Firebase가 보관하므로 앱 번들에 노출되지 않는다. 네트워크 오류,
/// 타임아웃(15초), App Check 토큰 거부, JSON 파싱 실패 등 어떤 실패에서도
/// null을 돌려주어 호출부가 빈 폼 + 안내 토스트로 폴백하도록 한다(Fail-Safe).
class VisionAiService {
  static const Duration _timeout = Duration(seconds: 15);

  static const String _prompt =
      '제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 '
      '파악해라. 응답은 반드시 {"menu": "메뉴이름", "category": "카테고리명"} 형태의 '
      '순수 JSON 포맷으로만 반환하라.';

  Future<AiResult?> analyzeImage(String absolutePath) async {
    try {
      final bytes = await File(absolutePath).readAsBytes();

      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      final response = await model.generateContent([
        Content.multi([
          TextPart(_prompt),
          InlineDataPart(_mimeTypeOf(absolutePath), bytes),
        ]),
      ]).timeout(_timeout);

      final text = response.text;
      if (text == null || text.trim().isEmpty) return null;
      return AiResult.tryParse(text);
    } catch (_) {
      return null;
    }
  }

  String _mimeTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
