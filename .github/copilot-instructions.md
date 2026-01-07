<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Document Renewal Reminder App - Copilot Instructions

> **Product Completion**: 98/100 points  
> **Last Updated**: 2026年1月8日  
> **Current Phase**: Phase 8 (Mobile Device Testing)

## Project Overview
This is a Flutter cross-platform mobile app (iOS/Android/macOS) for managing document renewals and providing intelligent reminders. The app helps users track expiration dates of various documents (residence cards, passports, licenses, etc.) and sends reminders when documents enter their "renewal application window" based on predefined rules.

Key features:
- Family member management
- Document management with types and expiration dates
- Rule-driven reminder system (e.g., 90 days before expiry for residence cards)
- Local notifications that work even when the app is closed
- Background tasks (24-hour periodic check)
- Calendar sync (iOS/Android only)
- Data export/import with JSON backup (overwrite mode)
- Multi-language support (Japanese, English, Chinese)
- Completely offline, using SQLite (mobile) / Hive (web) for local storage
- No backend, no paid APIs

## Technology Stack
- **Framework**: Flutter 3.0+
- **Storage**: SQLite (sqflite) for iOS/Android/macOS, Hive for web
- **Notifications**: flutter_local_notifications
- **Background**: workmanager (iOS/Android only)
- **Calendar**: add_2_calendar (iOS/Android only)
- **Data Sharing**: share_plus, file_picker
- **Internationalization**: flutter_intl (ARB files)
- **Other**: path_provider, shared_preferences

## Development Principles
- **Offline-first**: All functionality works without internet
- **Rule-driven**: Reminders based on document type rules, not fixed days
- **Reliable notifications**: Must work when app is closed/killed
- **State machine**: NORMAL → REMINDING → PAUSED → NORMAL
- **Multi-language**: All UI and notification text uses intl keys, no hardcoded strings
- **Simple architecture**: Repository pattern, no complex state management
- **Data safety**: Export/import with overwrite mode, clear warnings

## Current Development Status (98/100)

### ✅ Completed Phases
1. ✅ Project initialization
2. ✅ SQLite/Hive data layer
3. ✅ Basic business features (Family, Document management)
4. ✅ Renewal rules system (DocumentType with default reminder days)
5. ✅ Reminder engine & state machine (ReminderEngine, ReminderState)
6. ✅ Local notification system (with multi-language support)
7. ✅ Multi-language integration (ja/en/zh)
8. ✅ Phase 8.1: Background tasks (workmanager)
9. ✅ Phase 8.3: Calendar sync (add_2_calendar)
10. ✅ Phase 8.4: Notification action dialog (DocumentActionDialog)
11. ✅ Phase 8.5.1: **Data export/import (JSON backup with overwrite mode)**

### 🔄 In Progress
- **Phase 8**: Mobile device testing (iOS/Android)
  - Test export/import functionality on mobile
  - Test background tasks
  - Test notification action dialog
  - Test calendar sync
  - Performance testing on actual devices

### 📋 Planned
- Phase 8.5.2: Notification list UI
- Phase 8.2: Release preparation (app icon, splash screen, build optimization)
- Phase 8.8: Automated testing (Widget, Unit, Integration tests)
- Phase 3.6: Biometric authentication (optional)

## Key Implementation Details

### Notification ID System
```
documentId * 1000 + offset

- offset 0-998: Regular reminder notifications
- offset 999: Final expiry warning (when renewal started)
```

### State Machine (ReminderState)
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

### Platform Support
| Feature | iOS/Android | macOS | Web |
|---------|-------------|-------|-----|
| Notifications | ✅ Full | ⚠️ Limited | ❌ No |
| Background Tasks | ✅ Yes | ❌ No | ❌ No |
| Calendar Sync | ✅ Yes | ❌ No | ❌ No |
| Data Export/Import | ✅ Yes | ✅ Yes | ⚠️ Partial |

## Coding Guidelines
- Use the existing directory structure: lib/core/, lib/features/, lib/shared/
- Implement models, repositories, and services as per the plan
- **All UI text must use intl keys** (e.g., `S.of(context).key`) - no hardcoded strings
- Notification IDs must follow the central ID system (documentId * 1000 + offset)
- Test data persistence and notifications thoroughly
- Prioritize reminder reliability over fancy UI
- Add clear warnings for destructive operations (e.g., data import)

## Documentation
- **PRD**: docs/PRD_Document_Renewal_Reminder_App.md
- **Development Plan**: docs/DEV_PLAN_Sqlite_Flutter.md
- **Implementation Progress**: docs/IMPLEMENTATION_PROGRESS.md
- **Workflow Specification**: docs/WORKFLOW_SPECIFICATION.md (complete reference)
- **Notification Investigation**: docs/NOTIFICATION_INVESTIGATION.md

## Important Notes for AI
1. **Read WORKFLOW_SPECIFICATION.md first** - it contains the complete system design, data models, state machine, and all workflows
2. **Data import is destructive** - always warn users about data deletion
3. **Platform limitations** - check platform before implementing features (e.g., calendar sync only on mobile)
4. **Multi-language** - all user-facing text must go through l10n system
5. **Testing priority** - Phase 8 mobile testing is critical before release

When suggesting code, ensure it aligns with the PRD requirements and current development phase. Refer to WORKFLOW_SPECIFICATION.md for detailed implementation patterns.