import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/documents/repository/document_repository.dart';

void main() {
  group('DocumentRepository', () {
    test('can instantiate', () {
      final repo = DocumentRepository();
      expect(repo, isNotNull);
    });
  });
}
