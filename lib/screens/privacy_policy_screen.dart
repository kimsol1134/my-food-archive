import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static final Uri _policyUri = Uri.parse(
    'https://github.com/kimsol1134/my-food-archive/blob/main/docs/privacy-policy.md',
  );
  static final Uri _supportUri = Uri.parse(
    'https://github.com/kimsol1134/my-food-archive/issues/new',
  );

  Future<void> _open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('앱 정보 및 개인정보처리방침')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const Text(
              'My Food Archive',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text('개발자: solkim · 시행일: 2026년 7월 12일'),
            const SizedBox(height: 24),
            const _PolicySection(
              title: '기기에 저장되는 정보',
              body:
                  '식당명, 메뉴명, 카테고리, 날짜, 위치와 선택한 사진은 앱 전용 저장 공간에 보관됩니다. 기록을 삭제하면 연결된 로컬 사진도 함께 삭제되며, 앱을 삭제하면 앱 데이터가 제거됩니다.',
            ),
            const _PolicySection(
              title: 'AI 분석을 위한 전송',
              body:
                  '사용자가 음식 사진을 선택하면 메뉴명과 카테고리를 분석하기 위해 사진이 Firebase AI Logic을 거쳐 Google Gemini 서비스로 전송됩니다. 사진에 촬영 날짜나 위치 같은 메타데이터가 포함되어 있을 수 있습니다. 개발자는 별도 서버에 사진을 저장하지 않습니다.',
            ),
            const _PolicySection(
              title: '계정과 광고',
              body:
                  '회원가입과 로그인 기능이 없으며 광고를 표시하지 않습니다. Firebase App Check와 Play Integrity는 무단 API 사용을 막기 위해 앱·기기 식별 정보를 처리할 수 있습니다.',
            ),
            const _PolicySection(
              title: '문의 및 정책 변경',
              body:
                  '개인정보 관련 문의는 아래 지원 링크로 접수할 수 있습니다. 처리 방식이 달라지면 앱과 공개 정책 문서를 함께 갱신합니다.',
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _open(_policyUri),
              icon: const Icon(CupertinoIcons.doc_text),
              label: const Text('온라인 개인정보처리방침 열기'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _open(_supportUri),
              icon: const Icon(CupertinoIcons.bubble_left_bubble_right),
              label: const Text('개인정보 및 지원 문의'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.55)),
        ],
      ),
    );
  }
}
