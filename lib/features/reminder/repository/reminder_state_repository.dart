import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/database/db_provider.dart';
import '../../../core/database/hive_provider.dart';
import '../model/reminder_state.dart';

/// ReminderStateリポジトリ
/// 
/// リマインダー状態のCRUD操作を提供
class ReminderStateRepository {
  /// 新規作成（INSERT）
  static Future<int> insert(ReminderState state) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      final id = await box.add(state.toMap());
      return id;
    } else {
      final db = await DBProvider.database;
      return await db.insert('reminder_state', state.toMap());
    }
  }

  /// 全件取得
  static Future<List<ReminderState>> getAll() async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      return box.values
          .map((map) => ReminderState.fromMap(Map<String, dynamic>.from(map)))
          .toList();
    } else {
      final db = await DBProvider.database;
      final List<Map<String, dynamic>> maps = await db.query('reminder_state');
      return maps.map((map) => ReminderState.fromMap(map)).toList();
    }
  }

  /// ID検索
  static Future<ReminderState?> getById(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      final map = box.get(id);
      return map != null 
          ? ReminderState.fromMap(Map<String, dynamic>.from(map))
          : null;
    } else {
      final db = await DBProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminder_state',
        where: 'id = ?',
        whereArgs: [id],
      );
      return maps.isNotEmpty ? ReminderState.fromMap(maps.first) : null;
    }
  }

  /// documentIdで検索
  static Future<ReminderState?> getByDocumentId(int documentId) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      for (var key in box.keys) {
        final map = box.get(key);
        if (map != null) {
          final state = ReminderState.fromMap(Map<String, dynamic>.from(map));
          if (state.documentId == documentId) {
            return state;
          }
        }
      }
      return null;
    } else {
      final db = await DBProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminder_state',
        where: 'document_id = ?',
        whereArgs: [documentId],
      );
      return maps.isNotEmpty ? ReminderState.fromMap(maps.first) : null;
    }
  }

  /// 更新（UPDATE）
  static Future<int> update(ReminderState state) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      await box.put(state.id, state.toMap());
      return 1;
    } else {
      final db = await DBProvider.database;
      return await db.update(
        'reminder_state',
        state.toMap(),
        where: 'id = ?',
        whereArgs: [state.id],
      );
    }
  }

  /// 削除（DELETE）
  static Future<int> delete(int id) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      await box.delete(id);
      return 1;
    } else {
      final db = await DBProvider.database;
      return await db.delete(
        'reminder_state',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// documentIdで削除（証件削除時に使用）
  static Future<int> deleteByDocumentId(int documentId) async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      final keysToDelete = <dynamic>[];
      for (var key in box.keys) {
        final map = box.get(key);
        if (map != null) {
          final state = ReminderState.fromMap(Map<String, dynamic>.from(map));
          if (state.documentId == documentId) {
            keysToDelete.add(key);
          }
        }
      }
      for (var key in keysToDelete) {
        await box.delete(key);
      }
      return keysToDelete.length;
    } else {
      final db = await DBProvider.database;
      return await db.delete(
        'reminder_state',
        where: 'document_id = ?',
        whereArgs: [documentId],
      );
    }
  }

  /// REMINDING状態の全件取得（通知スケジューリング用）
  static Future<List<ReminderState>> getRemindingStates() async {
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      final List<ReminderState> result = [];
      for (var key in box.keys) {
        final map = box.get(key);
        if (map != null) {
          final state = ReminderState.fromMap(Map<String, dynamic>.from(map));
          if (state.status == ReminderStatus.reminding) {
            result.add(state);
          }
        }
      }
      return result;
    } else {
      final db = await DBProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminder_state',
        where: 'status = ?',
        whereArgs: ['REMINDING'],
      );
      return maps.map((map) => ReminderState.fromMap(map)).toList();
    }
  }

  /// PAUSED状態で予定完了日を過ぎたものを取得（自動再開用）
  static Future<List<ReminderState>> getExpiredPausedStates() async {
    final now = DateTime.now();
    if (kIsWeb) {
      final box = await HiveProvider.getReminderStateBox();
      final List<ReminderState> result = [];
      for (var key in box.keys) {
        final map = box.get(key);
        if (map != null) {
          final state = ReminderState.fromMap(Map<String, dynamic>.from(map));
          if (state.status == ReminderStatus.paused &&
              state.expectedFinishDate != null &&
              state.expectedFinishDate!.isBefore(now)) {
            result.add(state);
          }
        }
      }
      return result;
    } else {
      final db = await DBProvider.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'reminder_state',
        where: 'status = ? AND expected_finish_date < ?',
        whereArgs: ['PAUSED', now.toIso8601String()],
      );
      return maps.map((map) => ReminderState.fromMap(map)).toList();
    }
  }
}
