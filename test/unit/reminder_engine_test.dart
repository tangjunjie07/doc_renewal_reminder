import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/reminder/service/reminder_engine.dart';

void main() {
  group('ReminderEngine', () {
    test('can instantiate', () {
      final engine = ReminderEngine();
      expect(engine, isNotNull);
    });
  });
}
