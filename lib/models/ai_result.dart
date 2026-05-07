import 'dart:convert';

class AiResult {
  final String menuName;
  final String category;

  const AiResult({required this.menuName, required this.category});

  static AiResult? tryParse(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final cleaned = _stripCodeFence(trimmed);

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is! Map) return null;

      final menu = (decoded['menu'] ?? decoded['menuName'])?.toString().trim() ?? '';
      final category = decoded['category']?.toString().trim() ?? '';
      if (menu.isEmpty && category.isEmpty) return null;

      return AiResult(menuName: menu, category: category);
    } catch (_) {
      return null;
    }
  }

  static String _stripCodeFence(String input) {
    if (!input.startsWith('```')) return input;
    final firstNewline = input.indexOf('\n');
    if (firstNewline == -1) return input;
    var body = input.substring(firstNewline + 1);
    final fenceEnd = body.lastIndexOf('```');
    if (fenceEnd != -1) body = body.substring(0, fenceEnd);
    return body.trim();
  }
}
