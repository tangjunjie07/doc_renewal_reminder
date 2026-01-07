import 'dart:async';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class DBProvider {
  static const _dbName = 'doc_reminder.db';
  static const _dbVersion = 4; // バージョンアップ: sync_to_calendar カラム追加

  static Database? _database;
  
  // Singleton instance
  static final DBProvider instance = DBProvider._();
  
  DBProvider._();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path;
    
    // Platform-specific initialization
    if (kIsWeb) {
      throw UnsupportedError('Web platform uses Hive. This should not be called.');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms - use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      path = _dbName;
    } else {
      // Mobile platforms (Android/iOS) - use standard sqflite
      final databasesPath = await getDatabasesPath();
      path = join(databasesPath, _dbName);
    }

    try {
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // バージョン1から2へのマイグレーション: custom_reminder_daysカラム追加
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE document ADD COLUMN custom_reminder_days INTEGER
      ''');
    }
    // バージョン2から3へのマイグレーション: custom_reminder_frequencyカラム追加
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE document ADD COLUMN custom_reminder_frequency TEXT
      ''');
    }
    // バージョン3から4へのマイグレーション: sync_to_calendarカラム追加
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE document ADD COLUMN sync_to_calendar INTEGER DEFAULT 0
      ''');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 家族メンバーテーブル
    await db.execute('''
      CREATE TABLE family_member (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        birthday TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 更新ポリシーテーブル
    await db.execute('''
      CREATE TABLE renewal_policy (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_type TEXT NOT NULL,
        days_before_expiry INTEGER NOT NULL,
        reminder_frequency TEXT NOT NULL,
        auto_renewable INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 証件テーブル
    await db.execute('''
      CREATE TABLE document (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        document_type TEXT NOT NULL,
        document_number TEXT,
        expiry_date TEXT NOT NULL,
        policy_id INTEGER,
        custom_reminder_days INTEGER,
        custom_reminder_frequency TEXT,
        sync_to_calendar INTEGER DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES family_member (id) ON DELETE CASCADE,
        FOREIGN KEY (policy_id) REFERENCES renewal_policy (id) ON DELETE SET NULL
      )
    ''');

    // リマインダー状態テーブル
    await db.execute('''
      CREATE TABLE reminder_state (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_id INTEGER NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'NORMAL',
        reminder_start_date TEXT,
        expected_finish_date TEXT,
        last_notification_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (document_id) REFERENCES document (id) ON DELETE CASCADE
      )
    ''');

    // インデックスの作成（パフォーマンス向上）
    await db.execute('CREATE INDEX idx_document_member_id ON document(member_id)');
    await db.execute('CREATE INDEX idx_document_expiry_date ON document(expiry_date)');
    await db.execute('CREATE INDEX idx_reminder_state_document_id ON reminder_state(document_id)');
  }
}
