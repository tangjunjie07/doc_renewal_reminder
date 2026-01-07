<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Document Renewal Reminder App - Copilot Instructions

## Project Overview
This is a Flutter cross-platform mobile app (iOS/Android) for managing document renewals and providing intelligent reminders. The app helps users track expiration dates of various documents (residence cards, passports, licenses, etc.) and sends reminders when documents enter their "renewal application window" based on predefined rules.

Key features:
- Family member management
- Document management with types and expiration dates
- Rule-driven reminder system (e.g., 3 months before expiry for residence cards)
- Local notifications that work even when the app is closed
- Multi-language support (Chinese, Japanese, English)
- Completely offline, using SQLite for local storage
- No backend, no paid APIs

## Technology Stack
- **Framework**: Flutter (Dart)
- **Storage**: SQLite (sqflite package)
- **Notifications**: flutter_local_notifications
- **Internationalization**: flutter_intl (ARB files)
- **Other**: path_provider

## Development Principles
- **Offline-first**: All functionality works without internet
- **Rule-driven**: Reminders based on document type rules, not fixed days
- **Reliable notifications**: Must work when app is closed/killed
- **State machine**: NORMAL → REMINDING → PAUSED → REMINDING → NORMAL
- **Multi-language**: All UI and notification text uses intl keys, no hardcoded strings
- **Simple architecture**: Controller → Repository pattern, no complex state management

## Development Phases (from DEV_PLAN_Sqlite_Flutter.md)
Follow the phased development plan in docs/DEV_PLAN_Sqlite_Flutter.md:
1. Project initialization
2. SQLite data layer
3. Basic business features
4. Renewal rules system
5. Reminder engine & state machine
6. Local notification system
7. Multi-language integration
8. Integration testing & release

## Coding Guidelines
- Use the existing directory structure: lib/core/, lib/features/, lib/shared/
- Implement models, repositories, and services as per the plan
- Ensure all text uses intl keys (e.g., `S.of(context).key`)
- Notification IDs must be managed centrally
- Test data persistence and notifications thoroughly
- Prioritize reminder reliability over fancy UI

## Documentation
- PRD: docs/PRD_Document_Renewal_Reminder_App.md
- Development Plan: docs/DEV_PLAN_Sqlite_Flutter.md

When suggesting code, ensure it aligns with the PRD requirements and current development phase. Focus on completing the MVP as defined in the documents.