
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doc_renewal_reminder/core/localization/app_localizations.dart';

void main() {
  testWidgets('SettingsPage smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SettingsPage(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ja'), Locale('en'), Locale('zh')],
    ));
    expect(find.byType(SettingsPage), findsOneWidget);
  });
}
