# Document Renewal Reminder App

> **Product Completion**: 98/100 points  
> **Last Updated**: 2026年1月8日  
> **Current Phase**: Phase 8 (Mobile Device Testing)

A Flutter cross-platform app for managing document renewals and providing intelligent reminders. This app helps users track expiration dates of various documents (residence cards, passports, licenses, etc.) and sends reminders when documents enter their "renewal application window" based on predefined rules.

## ✨ Features


- 👨‍👩‍👧‍👦 **Family member management** - Manage multiple family members
- 📄 **Document management** - Track various document types with expiration dates
- 🔔 **Rule-driven reminder system** - Smart reminders based on document type (e.g., 90 days before expiry for residence cards)
- 📱 **Local notifications** - Works even when the app is closed
- ⏰ **Background tasks** - 24-hour periodic check (iOS/Android)
- 📅 **Calendar sync** - Add reminders to system calendar (iOS/Android)
- 💾 **Data export/import** - JSON backup with overwrite mode
- 🌍 **Multi-language support** - Japanese, English, Chinese
- 🔒 **Completely offline** - No backend, no paid APIs, SQLite (mobile) / Hive (web) storage
- 🎭 **State machine** - NORMAL → REMINDING → PAUSED → NORMAL workflow

## 🏗️ Technology Stack

- **Framework**: Flutter 3.0+
- **Storage**: SQLite (sqflite) for iOS/Android/macOS, Hive for web
- **Notifications**: flutter_local_notifications (RepeatInterval permanent loop)
- **Calendar**: add_2_calendar (iOS/Android only)
- **Data Sharing**: share_plus, file_picker
- **Internationalization**: flutter_intl (ARB files)
- **Other**: path_provider, shared_preferences

## 📱 Platform Support

| Feature | iOS/Android | macOS | Web |
|---------|-------------|-------|-----|
| Notifications | ✅ Full (3-tier defense) | ⚠️ Limited | ❌ No |
| RepeatInterval | ✅ Yes (permanent loop) | ⚠️ Yes (untested) | ❌ No |
| Calendar Sync | ✅ Yes | ❌ No | ❌ No |
| Data Export/Import | ✅ Yes | ✅ Yes | ⚠️ Partial |

## 🚀 Current Status (98/100)

### ✅ Completed Features
1. ✅ Family member management
2. ✅ Document management with 6 document types
3. ✅ Rule-driven reminder system (DocumentType with default reminder days)
4. ✅ Reminder engine & state machine (ReminderEngine, ReminderState)
5. ✅ Local notification system (multi-language support)
6. ✅ **3-tier defense notification system** (RepeatInterval permanent loop) - Phase 8.1.1
7. ✅ Calendar sync (add_2_calendar for iOS/Android)
8. ✅ Notification action dialog (DocumentActionDialog)
9. ✅ **Data export/import (JSON backup with overwrite mode)** - Phase 8.5.1
10. ✅ Multi-language integration (ja/en/zh)

### 🔄 In Progress
- Phase 8: Mobile device testing (iOS/Android)

### 📋 Planned
- Phase 8.5.2: Notification list UI
- Phase 8.2: Release preparation (app icon, splash screen)
- Phase 8.8: Automated testing (Widget, Unit, Integration tests)
- Phase 3.6: Biometric authentication (optional)

## 📋 Project Structure

```
lib/
├── main.dart
├── app.dart                      # App root entry (MaterialApp / i18n)
│
├── core/                         # Core infrastructure
│   ├── biometric_auth_service.dart # Biometric auth (future)
│   ├── biometric_gate.dart         # Biometric lock widget
│   ├── calendar_service.dart       # Calendar sync logic
│   ├── logger.dart                 # Logging utility
│   ├── notification_service.dart   # Notification (legacy entry)
│   ├── database/
│   │   ├── db_provider.dart        # SQLite/Hive initialization
│   │   ├── hive_provider.dart      # Web storage provider
│   │   └── schema.sql              # DB schema
│   ├── localization/
│   │   ├── app_localizations.dart  # intl auto-generated
│   │   ├── notification_localizations.dart # Notification text i18n
│   │   ├── intl_ja.arb             # Japanese (default)
│   │   ├── intl_en.arb             # English
│   │   └── intl_zh.arb             # Chinese
│   └── widgets/
│       └── startup_debug_page.dart # Debug startup info
│
├── features/                      # Feature modules
│   ├── family/
│   │   ├── family_controller.dart
│   │   ├── model/
│   │   │   └── family_member.dart
│   │   ├── repository/
│   │   │   └── family_repository.dart
│   │   └── ui/
│   │       ├── family_list_page.dart
│   │       └── family_edit_page.dart
│   │
│   ├── documents/
│   │   ├── document_controller.dart
│   │   ├── document_model.dart
│   │   ├── model/
│   │   │   └── document.dart
│   │   ├── repository/
│   │   │   └── document_repository.dart
│   │   ├── ui/
│   │   │   ├── document_action_dialog.dart
│   │   │   ├── document_all_list_page.dart
│   │   │   ├── document_edit_page.dart
│   │   │   └── document_list_page.dart
│   │   └── utils/
│   │       └── ...
│   │
│   ├── reminder/
│   │   ├── model/
│   │   │   └── reminder_state.dart
│   │   ├── repository/
│   │   │   └── reminder_state_repository.dart
│   │   └── service/
│   │       ├── reminder_engine.dart      # Core reminder logic
│   │       └── reminder_scheduler.dart   # Notification scheduling
│   │
│   ├── renewal_policy/
│   │   ├── data/
│   │   │   └── default_policies.dart
│   │   ├── model/
│   │   │   └── renewal_policy.dart
│   │   ├── repository/
│   │   │   └── renewal_policy_repository.dart
│   │   └── service/
│   │       └── policy_service.dart
│   │
│   ├── settings/
│   │   ├── db_debug_page.dart
│   │   ├── debug_notification_page.dart
│   │   ├── language_selector.dart
│   │   ├── notification_list_page.dart
│   │   ├── service/
│   │   │   └── data_export_service.dart  # JSON export/import
│   │   └── settings_page.dart
│   │
│   └── navigation/
│       ├── main_navigation_page.dart      # BottomNavigationBar
│       └── member_selector_dialog.dart
│
├── shared/
│   └── widgets/
│       ├── confirm_dialog.dart
│       ├── date_picker_tile.dart
│       └── empty_state.dart
│
└── l10n/                          # Generated localization files

assets/
├── l10n/
│   ├── intl_ja.arb            # Japanese (default)
│   ├── intl_en.arb            # English
│   └── intl_zh.arb            # Chinese
└── icons/                      # App icons (planned)
```
## 🔧 Getting Started

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd doc_renewal_reminder
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate localization files
```bash
flutter gen-l10n
```

4. Run the app
```bash
# iOS/Android
flutter run

# macOS (development)
flutter run -d macos

# Web (partial support)
flutter run -d chrome
```

## 📚 Documentation

- **[PRD](docs/PRD_Document_Renewal_Reminder_App.md)** - Product Requirements Document
- **[Development Plan](docs/DEV_PLAN_Sqlite_Flutter.md)** - Phased development plan
- **[Implementation Progress](docs/IMPLEMENTATION_PROGRESS.md)** - Current development status
- **[Workflow Specification](docs/WORKFLOW_SPECIFICATION.md)** - Complete system design reference

## 🔔 Key Implementation Details

### Notification ID System (3-Tier Defense)
```
documentId * 1000 + offset

- offset 0: Tier 1 (遠期唤醒) - Single notification at reminder start
- offset 1: Tier 2 (近期催办) - Daily loop 30 days before expiry
- offset 2: Tier 3 (過期轰炸) - Daily loop from expiry date
- offset 999: Final warning (when renewal started, PAUSED state)

3 notifications per document (60 total for 20 documents, under iOS 64 limit)
```

### State Machine
```
NORMAL → REMINDING (auto) → PAUSED (user "start renewal") → NORMAL (user "complete renewal")
                                  ↓
                          Final warning on expiry date
```

### Data Export/Import ⚠️
- **Format**: JSON (version 1.0)
- **Mode**: Overwrite (all existing data is deleted before import)
- **Warning**: Users are warned about data deletion with explicit confirmation
- **Export**: All FamilyMembers, Documents, ReminderStates
- **Import**: ID remapping (old IDs → new auto-generated IDs)

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests (planned - Phase 8.8)
flutter test test/widget_test.dart

# Integration tests (planned - Phase 8.8)
flutter test integration_test/
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues and questions, please use the GitHub issue tracker.
