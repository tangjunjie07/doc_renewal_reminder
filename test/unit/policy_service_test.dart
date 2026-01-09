import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/renewal_policy/service/policy_service.dart';

void main() {
  group('PolicyService', () {
    test('can instantiate', () {
      final service = PolicyService();
      expect(service, isNotNull);
    });
  });
}
