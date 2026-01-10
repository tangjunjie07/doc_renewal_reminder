import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/documents/model/document.dart';
import 'package:doc_renewal_reminder/features/renewal_policy/service/policy_service.dart';

void main() {
  group('PolicyService.daysUntilExpiry', () {
    test('expiry is today -> returns 0', () {
      final now = DateTime(2026, 1, 10, 12, 0);
      final doc = Document(
        id: 1,
        memberId: 1,
        documentType: 'passport',
        expiryDate: DateTime(2026, 1, 10, 0, 0),
      );

      final days = PolicyService.daysUntilExpiry(doc, currentDate: now);
      expect(days, 0);
    });

    test('expiry is tomorrow -> returns 1', () {
      final now = DateTime(2026, 1, 10, 8, 0);
      final doc = Document(
        id: 2,
        memberId: 1,
        documentType: 'drivers_license',
        expiryDate: DateTime(2026, 1, 11, 0, 0),
      );

      final days = PolicyService.daysUntilExpiry(doc, currentDate: now);
      expect(days, 1);
    });

    test('expiry was yesterday -> negative value', () {
      final now = DateTime(2026, 1, 10, 10, 0);
      final doc = Document(
        id: 3,
        memberId: 1,
        documentType: 'residence_card',
        expiryDate: DateTime(2026, 1, 9, 23, 59),
      );

      final days = PolicyService.daysUntilExpiry(doc, currentDate: now);
      expect(days, -1);
    });

    test('time of day is ignored (date-only)', () {
      final now = DateTime(2026, 1, 10, 23, 50);
      final doc = Document(
        id: 4,
        memberId: 1,
        documentType: 'other',
        expiryDate: DateTime(2026, 1, 11, 1, 15),
      );

      final days = PolicyService.daysUntilExpiry(doc, currentDate: now);
      expect(days, 1);
    });
  });
}
