import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WebFooterLinks extends StatelessWidget {
  const WebFooterLinks({super.key});

  static const String githubUrl = 'https://github.com/tangjunjie07/doc_renewal_reminder'; // TODO: 実際のURLに変更
  static const String websiteUrl = 'https://tangjunjie07.github.io/doc_renewal_reminder'; // TODO: 実際のURLに変更

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(githubUrl)),
            icon: const Icon(Icons.code, size: 18),
            label: const Text('GitHub'),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(websiteUrl)),
            icon: const Icon(Icons.public, size: 18),
            label: const Text('WebSite'),
          ),
        ],
      ),
    );
  }
}
