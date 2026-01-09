
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/documents/ui/document_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doc_renewal_reminder/core/localization/app_localizations.dart';

void main() {
  testWidgets('DocumentEditPage smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const DocumentEditPage(memberId: 1),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja'), Locale('en'), Locale('zh')],
    ));
    expect(find.byType(DocumentEditPage), findsOneWidget);
  });
}
