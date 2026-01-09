import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/family/repository/family_repository.dart';

void main() {
  group('FamilyRepository', () {
    test('can instantiate', () {
      final repo = FamilyRepository();
      expect(repo, isNotNull);
    });
  });
}
