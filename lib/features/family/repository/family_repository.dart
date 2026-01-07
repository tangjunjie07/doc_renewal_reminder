import 'package:flutter/foundation.dart';
import 'package:doc_renewal_reminder/core/database/db_provider.dart';
import 'package:doc_renewal_reminder/core/database/hive_provider.dart';
import 'package:doc_renewal_reminder/features/family/model/family_member.dart';

class FamilyRepository {
  static const table = 'family_member';

  /// Insert a family member
  static Future<int> insert(FamilyMember member) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.familyBox);
      final id = box.length + 1;
      final memberWithId = FamilyMember(
        id: id,
        name: member.name,
        relationship: member.relationship,
        dateOfBirth: member.dateOfBirth,
        createdAt: member.createdAt,
        updatedAt: member.updatedAt,
      );
      await box.put(id, memberWithId.toMap());
      return id;
    } else {
      final db = await DBProvider.database;
      return await db.insert(table, member.toMap());
    }
  }

  /// Get all family members
  static Future<List<FamilyMember>> getAll() async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.familyBox);
      return box.values
          .map((e) => FamilyMember.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final db = await DBProvider.database;
      final res = await db.query(table);
      return res.map((e) => FamilyMember.fromMap(e)).toList();
    }
  }

  /// Get family member by ID
  static Future<FamilyMember?> getById(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.familyBox);
      final data = box.get(id);
      if (data != null) {
        return FamilyMember.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } else {
      final db = await DBProvider.database;
      final res = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isNotEmpty) {
        return FamilyMember.fromMap(res.first);
      }
      return null;
    }
  }

  /// Update family member
  static Future<int> update(FamilyMember member) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.familyBox);
      await box.put(member.id, member.toMap());
      return 1;
    } else {
      final db = await DBProvider.database;
      return await db.update(
        table,
        member.toMap(),
        where: 'id = ?',
        whereArgs: [member.id],
      );
    }
  }

  /// Delete family member
  static Future<int> delete(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.familyBox);
      await box.delete(id);
      return 1;
    } else {
      final db = await DBProvider.database;
      return await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}