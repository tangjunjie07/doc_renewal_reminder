# 通知テーブルの必要性分析

## 現在の実装状況

### 通知データの管理方法
現在、通知データは**データベーステーブルには保存されていません**。

**実装箇所:**
- `NotificationService` が `flutter_local_notifications` プラグインを使用
- `getPendingNotifications()` でシステムレベルのスケジュール済み通知を取得
- 通知は iOS/Android の**システム通知センター**が管理

### 現在のデータフロー
```
Document (DB) → ReminderEngine → NotificationService → システム通知
                                        ↓
                              PendingNotificationRequest
```

---

## 通知テーブル追加の必要性

### メリット ✅

#### 1. 通知履歴の追跡
- **問題**: 現在、過去に送信された通知の履歴が残らない
- **解決**: `notification_history` テーブルで履歴管理
  - 送信日時
  - 通知タイプ
  - ユーザーの反応（既読/未読/削除）

#### 2. 通知とドキュメントの関連付け
- **問題**: `PendingNotificationRequest` には通知ID、タイトル、本文しかない
- **解決**: `notifications` テーブルで以下を保存:
  ```sql
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY,
    document_id INTEGER NOT NULL,
    family_member_id INTEGER NOT NULL,
    notification_id INTEGER UNIQUE NOT NULL, -- システム通知ID
    scheduled_date TEXT NOT NULL,
    notification_type TEXT NOT NULL, -- 'FIRST_REMINDER', 'SECOND_REMINDER'
    status TEXT NOT NULL, -- 'SCHEDULED', 'SENT', 'CANCELLED'
    created_at TEXT NOT NULL,
    sent_at TEXT,
    FOREIGN KEY (document_id) REFERENCES documents(id),
    FOREIGN KEY (family_member_id) REFERENCES family_members(id)
  );
  ```

#### 3. 通知状態の管理
- ステータス追跡: SCHEDULED → SENT → CANCELLED
- リマインダーエンジンとの同期
- 重複通知の防止

#### 4. 分析機能
- 通知送信頻度の統計
- 最も通知が多い証件タイプ
- ユーザーの反応率

### デメリット ❌

#### 1. 実装の複雑化
- Repository層の追加
- 同期ロジックの実装
- システム通知とDBの整合性維持

#### 2. データ重複
- システム通知 ≠ DBテーブル
- 2つの情報源の管理が必要

#### 3. パフォーマンス
- 通知作成時にDB書き込み
- 定期チェック時のDB読み込み

---

## 推奨実装アプローチ

### Phase 1: 現在のシンプル実装を維持（MVP）
**現状で十分な理由:**
- ✅ システム通知で基本機能は動作
- ✅ `getPendingNotifications()` で予定通知の確認可能
- ✅ 実装がシンプル
- ✅ オフライン完結

**この段階での対応:**
- NotificationListPage で `PendingNotificationRequest` を表示（実装済み）
- システム通知IDのみで管理

### Phase 2: 通知履歴テーブルの追加（将来拡張）
**実装タイミング:** ユーザーフィードバック後

**テーブル設計案:**
```dart
// models/notification_log.dart
class NotificationLog {
  final int? id;
  final int documentId;
  final int familyMemberId;
  final int systemNotificationId; // flutter_local_notifications の ID
  final DateTime scheduledDate;
  final String notificationType; // 'FIRST_REMINDER', 'SECOND_REMINDER', etc.
  final String status; // 'SCHEDULED', 'SENT', 'CANCELLED', 'DISMISSED'
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? dismissedAt;
  
  NotificationLog({
    this.id,
    required this.documentId,
    required this.familyMemberId,
    required this.systemNotificationId,
    required this.scheduledDate,
    required this.notificationType,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.dismissedAt,
  });
}
```

**使用ケース:**
1. 通知スケジュール時: DBに記録
2. 通知キャンセル時: ステータスを'CANCELLED'に更新
3. 通知送信後: ステータスを'SENT'に更新（Workmanagerで実装）
4. 履歴画面: 過去の通知を表示

### Phase 3: 高度な通知管理（オプション）
- 通知設定のカスタマイズ（ユーザーごと）
- 通知頻度の制限
- スヌーズ機能
- 通知グループ化

---

## 結論

### 現時点での推奨事項
**テーブル追加は不要** - 以下の理由で:

1. ✅ **MVPには不要**: 基本機能は `flutter_local_notifications` で実現済み
2. ✅ **シンプルさ優先**: オフライン前提のアプリに複雑なDB管理は過剰
3. ✅ **システム通知で十分**: `getPendingNotifications()` で予定通知の確認可能
4. ✅ **実装済み**: NotificationListPage で通知一覧・削除が可能

### 将来的に追加を検討すべきケース
- 📊 **通知履歴の分析**が必要になった時
- 🔔 **複雑な通知ルール**（スヌーズ、再通知）が必要になった時
- 📈 **使用状況統計**を取りたい時
- 🔄 **通知の同期**（複数デバイス間）が必要になった時

### 次のステップ
1. ✅ **Phase 8.5.2完了**: 通知一覧機能（システム通知ベース）
2. 🔴 **Phase 8.5.3実装**: Workmanager統合（バックグラウンドチェック）
3. 🟡 **カレンダー統合**: add_2_calendar導入
4. 🟢 **ユーザーフィードバック収集**: 通知履歴機能の必要性を評価
5. 🔵 **Phase 2実装判断**: フィードバックに基づいて通知テーブル追加を決定

---

## 実装優先度まとめ

```
現在のシステム通知管理 (✅完了)
    ↓
Workmanager統合 (🔴最優先 - Phase 8.5.3)
    ↓
カレンダー統合 (🟡高優先度)
    ↓
ユーザーフィードバック収集 (🟡中優先度)
    ↓
通知テーブル追加の判断 (🟢将来拡張)
```

**結論**: 現時点では**テーブル追加は不要**。システム通知管理で十分機能します。
