
import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/documents/ui/document_list_page.dart';
import 'package:doc_renewal_reminder/features/family/model/family_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doc_renewal_reminder/core/localization/app_localizations.dart';

void main() {
  testWidgets('DocumentListPage smoke test', (WidgetTester tester) async {
    final dummyMember = FamilyMember(
      id: 1,
      name: 'テストユーザー',
      relationship: '本人',
      dateOfBirth: DateTime(2000, 1, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await tester.pumpWidget(MaterialApp(
      home: DocumentListPage(member: dummyMember),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja'), Locale('en'), Locale('zh')],
    ));
    expect(find.byType(DocumentListPage), findsOneWidget);
  });
}
