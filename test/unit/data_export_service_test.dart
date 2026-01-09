import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/settings/service/data_export_service.dart';

void main() {
  group('DataExportService', () {
    test('can instantiate', () {
      final service = DataExportService();
      expect(service, isNotNull);
    });
  });
}
