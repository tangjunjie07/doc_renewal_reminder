import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/reminder/repository/reminder_state_repository.dart';

void main() {
  group('ReminderStateRepository', () {
    test('can instantiate', () {
      final repo = ReminderStateRepository();
      expect(repo, isNotNull);
    });
  });
}
