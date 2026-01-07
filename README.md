# doc_renewal_reminder

A Flutter app for managing document renewals and providing intelligent reminders. This app helps users track expiration dates of various documents (residence cards, passports, licenses, etc.) and sends reminders when documents enter their "renewal application window" based on predefined rules.

## Features

- Family member management
- Document management with types and expiration dates
- Rule-driven reminder system
- Local notifications that work even when the app is closed
- Multi-language support (Chinese, Japanese, English)
- Completely offline, using SQLite for local storage

## Project Structure

```
lib/
├── main.dart
├── app.dart                      # App 根入口（MaterialApp / 多语言）
│
├── core/                          # 核心基础设施（不依赖业务）
│   ├── constants/
│   │   ├── document_type.dart     # 证件类型枚举
│   │   ├── reminder_status.dart   # 状态机枚举
│   │   └── app_constants.dart
│   │
│   ├── localization/
│   │   ├── app_localizations.dart # intl 自动生成
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_ja.dart
│   │   └── app_localizations_zh.dart
│   │
│   ├── notifications/
│   │   ├── notification_service.dart
│   │   └── notification_ids.dart # 通知ID统一管理
│   │
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── log_utils.dart
│   │
│   └── database/
│       ├── db_provider.dart       # SQLite / Hive 初始化
│       └── migrations.dart
│
├── features/                      # 业务模块（Feature-based）
│   ├── family/
│   │   ├── model/
│   │   │   └── family_member.dart
│   │   ├── repository/
│   │   │   └── family_repository.dart
│   │   ├── ui/
│   │   │   ├── family_list_page.dart
│   │   │   └── family_edit_page.dart
│   │   └── family_controller.dart
│   │
│   ├── documents/
│   │   ├── model/
│   │   │   └── document.dart
│   │   ├── repository/
│   │   │   └── document_repository.dart
│   │   ├── ui/
│   │   │   ├── document_list_page.dart
│   │   │   └── document_edit_page.dart
│   │   └── document_controller.dart
│   │
│   ├── renewal_policy/
│   │   ├── model/
│   │   │   └── renewal_policy.dart
│   │   ├── data/
│   │   │   └── default_policies.dart
│   │   ├── repository/
│   │   │   └── renewal_policy_repository.dart
│   │   └── policy_service.dart
│   │
│   ├── reminder/
│   │   ├── model/
│   │   │   └── reminder_state.dart
│   │   ├── reminder_engine.dart
│   │   └── reminder_scheduler.dart
│   │
│   └── settings/
│       ├── settings_page.dart
│       └── settings_controller.dart
│
├── shared/
│   ├── widgets/
│   │   ├── confirm_dialog.dart
│   │   ├── date_picker_tile.dart
│   │   └── empty_state.dart
│   │
│   └── theme/
│       └── app_theme.dart
│
└── generated/
└── l10n.dart                  # intl 自动生成（不要手写）

assets/
├── l10n/
│   ├── intl_zh.arb
│   ├── intl_ja.arb
│   └── intl_en.arb
│
└── icons/

android/
ios/
pubspec.yaml
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
