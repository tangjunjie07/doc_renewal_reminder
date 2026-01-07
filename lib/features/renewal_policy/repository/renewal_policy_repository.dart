import 'package:flutter/foundation.dart';
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../model/renewal_policy.dart';

/// 更新ポリシーリポジトリ
/// 
/// カスタム更新ポリシーのCRUD操作を提供します。
/// デフォルトポリシーはDefaultPoliciesクラスで管理されます。
class RenewalPolicyRepository {
  static const table = 'renewal_policy';

  /// ポリシーを挿入
  static Future<int> insert(RenewalPolicy policy) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.renewalPolicyBox);
      final id = box.length + 1;
      final policyWithId = policy.copyWith(id: id);
      await box.put(id, policyWithId.toMap());
      return id;
    } else {
      final db = await DBProvider.database;
      return await db.insert(table, policy.toMap());
    }
  }

  /// すべてのポリシーを取得
  static Future<List<RenewalPolicy>> getAll() async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.renewalPolicyBox);
      return box.values
          .map((e) => RenewalPolicy.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final db = await DBProvider.database;
      final res = await db.query(table);
      return res.map((e) => RenewalPolicy.fromMap(e)).toList();
    }
  }

  /// IDでポリシーを取得
  static Future<RenewalPolicy?> getById(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.renewalPolicyBox);
      final data = box.get(id);
      if (data == null) return null;
      return RenewalPolicy.fromMap(Map<String, dynamic>.from(data));
    } else {
      final db = await DBProvider.database;
      final res = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (res.isEmpty) return null;
      return RenewalPolicy.fromMap(res.first);
    }
  }

  /// ポリシーを更新
  static Future<void> update(RenewalPolicy policy) async {
    if (policy.id == null) {
      throw ArgumentError('Policy must have an id to be updated');
    }

    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.renewalPolicyBox);
      await box.put(policy.id!, policy.toMap());
    } else {
      final db = await DBProvider.database;
      await db.update(
        table,
        policy.toMap(),
        where: 'id = ?',
        whereArgs: [policy.id],
      );
    }
  }

  /// ポリシーを削除
  static Future<void> delete(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getBox(HiveProvider.renewalPolicyBox);
      await box.delete(id);
    } else {
      final db = await DBProvider.database;
      await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// 証件タイプでポリシーを取得
  static Future<List<RenewalPolicy>> getByDocumentType(String documentType) async {
    if (kIsWeb) {
      final all = await getAll();
      return all.where((p) => p.documentType == documentType).toList();
    } else {
      final db = await DBProvider.database;
      final res = await db.query(
        table,
        where: 'document_type = ?',
        whereArgs: [documentType],
      );
      return res.map((e) => RenewalPolicy.fromMap(e)).toList();
    }
  }
}
