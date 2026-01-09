import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/documents/model/document.dart';
import 'package:doc_renewal_reminder/features/renewal_policy/service/policy_service.dart';

void main() {
  test('calculateReminderStartDate uses customReminderDays when set', () async {
    final expiry = DateTime(2026, 6, 30);
    final doc = Document(
      id: 1,
      memberId: 1,
      documentType: 'passport',
      expiryDate: expiry,
      customReminderDays: 90,
    );

    final start = await PolicyService.calculateReminderStartDate(doc);
    expect(start, expiry.subtract(const Duration(days: 90)));
  });

  test('daysUntilExpiry computes correct days (midnight-normalized)', () {
    final today = DateTime(2026, 1, 1);
    final expiry = DateTime(2026, 1, 10);
    final doc = Document(
      id: 2,
      memberId: 1,
      documentType: 'drivers_license',
      expiryDate: expiry,
    );

    final days = PolicyService.daysUntilExpiry(doc, currentDate: today);
    expect(days, 9);
  });
}
