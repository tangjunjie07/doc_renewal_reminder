import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final String? savedLanguageCode;
  final ValueChanged<String> onSelected;

  const LanguageSelector({super.key, this.savedLanguageCode, required this.onSelected});

  void _showSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.language),
              subtitle: Text(l10n.changeAppLanguage),
            ),
            const Divider(),
            _buildOption(ctx, 'en', 'English', '🇬🇧'),
            _buildOption(ctx, 'ja', '日本語', '🇯🇵'),
            _buildOption(ctx, 'zh', '中文', '🇨🇳'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String code, String label, String flag) {
    final current = savedLanguageCode ?? Localizations.localeOf(context).languageCode;
    final selected = current == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        Navigator.pop(context);
        onSelected(code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = savedLanguageCode ?? Localizations.localeOf(context).languageCode;
    String display;
    switch (current) {
      case 'ja':
        display = '日本語';
        break;
      case 'zh':
        display = '中文';
        break;
      default:
        display = 'English';
    }

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.blue),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(display),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showSheet(context),
    );
  }
}
