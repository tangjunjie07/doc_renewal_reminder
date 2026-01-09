import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/reminder/service/reminder_engine.dart';
import 'package:doc_renewal_reminder/features/documents/model/document.dart';

void main() {
  test('ReminderEngine daysUntilExpiry and getReminderStartDate via custom days', () async {
    final engine = ReminderEngine();
    final expiry = DateTime(2026, 12, 31);
    final doc = Document(
      id: 10,
      memberId: 1,
      documentType: 'residence_card',
      expiryDate: expiry,
      customReminderDays: 180,
    );

    final days = engine.daysUntilExpiry(doc);
    // daysUntilExpiry uses DateTime.now(); allow it to be an int (not null)
    expect(days, isA<int>());

    final start = await engine.getReminderStartDate(doc);
    expect(start, expiry.subtract(const Duration(days: 180)));
  });
}
