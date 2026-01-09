import 'package:flutter_test/flutter_test.dart';
import 'package:doc_renewal_reminder/features/family/model/family_member.dart';
import 'package:doc_renewal_reminder/features/family/repository/family_repository.dart';
import 'package:doc_renewal_reminder/features/documents/model/document.dart';
import 'package:doc_renewal_reminder/features/documents/repository/document_repository.dart';
import 'package:doc_renewal_reminder/features/reminder/model/reminder_state.dart';
import 'package:doc_renewal_reminder/features/reminder/repository/reminder_state_repository.dart';
import 'package:doc_renewal_reminder/features/settings/service/data_export_service.dart';

void main() {
  test('DataExportService exports inserted data', () async {
    // 1) Insert a family member
    final member = FamilyMember(
      name: 'テスト太郎',
      relationship: '本人',
      dateOfBirth: DateTime(1990, 1, 1),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final memberId = await FamilyRepository.insert(member);

    // 2) Insert a document for that member
    final doc = Document(
      memberId: memberId,
      documentType: 'passport',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final docId = await DocumentRepository.insert(doc);

    // 3) Insert a reminder state for that document
    final state = ReminderState(
      documentId: docId,
      status: ReminderStatus.normal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ReminderStateRepository.insert(state);

    // 4) Export to JSON and verify counts
    final exported = await DataExportService.exportToJson();

    expect(exported.containsKey('members'), true);
    expect(exported.containsKey('documents'), true);
    expect(exported.containsKey('reminderStates'), true);

    final members = exported['members'] as List<dynamic>;
    final documents = exported['documents'] as List<dynamic>;
    final reminderStates = exported['reminderStates'] as List<dynamic>;

    expect(members.any((m) => (m as Map<String, dynamic>)['id'] == memberId), true);
    expect(documents.any((d) => (d as Map<String, dynamic>)['id'] == docId), true);
    expect(reminderStates.isNotEmpty, true);
  });
}
