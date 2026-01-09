import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../documents/ui/document_all_list_page.dart';
import '../family/ui/family_list_page.dart';
import '../settings/settings_page.dart';

/// メインナビゲーション画面（製品レベルUI）
/// 証件一覧を初期表示
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  int _documentPageKey = 0;
  int _familyPageKey = 0;

  List<Widget> _buildPages() {
    return [
      DocumentAllListPage(key: ValueKey(_documentPageKey)),
      FamilyListPage(key: ValueKey(_familyPageKey)),
      const SettingsPage(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      // タブが切り替わったらそのページを再構築
      if (index == 0) {
        _documentPageKey++;
      } else if (index == 1) {
        _familyPageKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabChanged,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: Icon(
                Icons.description,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: l10n.allDocuments,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outlined),
              selectedIcon: Icon(
                Icons.people,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: l10n.familyMembers,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
