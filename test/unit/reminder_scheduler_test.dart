import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/reminder/service/reminder_scheduler.dart';

void main() {
  group('ReminderScheduler', () {
    test('can instantiate', () {
      final scheduler = ReminderScheduler();
      expect(scheduler, isNotNull);
    });
  });
}
