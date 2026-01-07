import 'package:doc_renewal_reminder/features/family/model/family_member.dart';
import 'repository/family_repository.dart';

class FamilyController {
  Future<List<FamilyMember>> loadMembers() async {
    return FamilyRepository.getAll();
  }

  Future<FamilyMember?> loadMember(int id) async {
    return FamilyRepository.getById(id);
  }

  Future<void> saveMember(FamilyMember member) async {
    if (member.id == null) {
      await FamilyRepository.insert(member);
    } else {
      await FamilyRepository.update(member);
    }
  }

  Future<void> deleteMember(int id) async {
    await FamilyRepository.delete(id);
  }
}