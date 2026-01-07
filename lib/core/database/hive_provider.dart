import 'package:hive_flutter/hive_flutter.dart';

/// Hive database provider for Web platform
class HiveProvider {
  static bool _initialized = false;
  
  // Singleton instance
  static final HiveProvider instance = HiveProvider._();
  
  HiveProvider._();

  /// Initialize Hive for Web
  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  /// Get or create a box
  static Future<Box<Map>> getBox(String boxName) async {
    if (!_initialized) {
      await initialize();
    }

    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Map>(boxName);
    }

    return await Hive.openBox<Map>(boxName);
  }

  /// Box names
  static const String familyBox = 'family_members';
  static const String documentBox = 'documents';
  static const String renewalPolicyBox = 'renewal_policies';
  static const String reminderStateBox = 'reminder_states';

  /// Get family member box
  static Future<Box<Map>> getFamilyBox() => getBox(familyBox);

  /// Get document box
  static Future<Box<Map>> getDocumentBox() => getBox(documentBox);

  /// Get renewal policy box
  static Future<Box<Map>> getRenewalPolicyBox() => getBox(renewalPolicyBox);

  /// Get reminder state box
  static Future<Box<Map>> getReminderStateBox() => getBox(reminderStateBox);
}
