import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/ai_result.dart';

class VisionAIService {
  static const _modelId = 'gemini-2.5-flash';
  static const _timeout = Duration(seconds: 15);
  static const _prompt =
      '제공된 음식 사진을 분석하여 메뉴명과 카테고리(한식, 중식, 일식, 양식, 카페/디저트 등)를 파악해라. '
      '응답은 반드시 {"menu": "메뉴이름", "category": "카테고리명"} 형태의 순수 JSON 포맷으로만 반환하라.';

  GenerativeModel? _model;

  GenerativeModel _getModel() {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: _modelId,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
    );
  }

  Future<AiResult?> analyzeImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final mimeType = _resolveMimeType(imagePath);

      final response = await _getModel()
          .generateContent([
            Content.multi([
              TextPart(_prompt),
              InlineDataPart(mimeType, bytes),
            ]),
          ])
          .timeout(_timeout);

      return AiResult.tryParse(response.text);
    } catch (_) {
      return null;
    }
  }

  String _resolveMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
