# カレンダー通知とプッシュ通知の調査報告

## 1. カレンダー通知について

### 現在の実装状況
- **flutter_local_notifications** を使用してローカル通知を実装済み
- スケジュール通知は `scheduleNotification()` メソッドで設定可能

### カレンダー通知ができない理由

#### iOS/macOS
- **カレンダーへの直接追加は別のAPI**
  - ローカル通知はシステム通知トレイに表示される
  - カレンダーイベントは `EventKit` framework を使用する必要がある
  - パッケージ: `device_calendar` または `add_2_calendar`

#### Android
- 同様に `Calendar Provider API` を使用する必要がある
- ローカル通知とカレンダーイベントは別の仕組み

### 解決策

#### オプション1: カレンダーイベント追加機能を実装
```yaml
dependencies:
  add_2_calendar: ^3.0.0  # または device_calendar
```

**実装例:**
```dart
import 'package:add_2_calendar/add_2_calendar.dart';

Future<void> addToCalendar(Document document) async {
  final Event event = Event(
    title: '${document.documentType}の更新',
    description: '有効期限: ${document.expiryDate}',
    location: '',
    startDate: document.expiryDate.subtract(Duration(days: 7)),
    endDate: document.expiryDate,
    allDay: false,
  );
  
  await Add2Calendar.addEvent2Cal(event);
}
```

#### オプション2: 通知からカレンダーに手動追加を促す
- 通知をタップした時にカレンダーアプリを開くディープリンク
- ユーザーが手動でカレンダーに追加

### 推奨事項
**オプション1を推奨**: 
- UX向上（ワンタップでカレンダー追加）
- 証件追加時に「カレンダーに追加」ボタンを配置
- 更新リマインダーと一緒にカレンダーイベントも作成

---

## 2. プッシュ通知の可能性

### 現在の制限
**ローカル通知の問題点:**
1. ✅ アプリがバックグラウンドで動作中: 正常動作
2. ❌ アプリが完全に終了: 通知が配信されない可能性
3. ❌ デバイスが再起動: 通知スケジュールが消える

### プッシュ通知の実装可能性

#### A. Firebase Cloud Messaging (FCM)
**メリット:**
- ✅ デバイス再起動後も通知を配信
- ✅ アプリ完全終了時も通知可能
- ✅ iOS/Android/Webすべて対応
- ✅ 無料（一定範囲内）

**デメリット:**
- ❌ バックエンドサーバーが必要
- ❌ ユーザーデータをクラウドに保存する必要
- ❌ 実装コストが高い
- ❌ プライバシーの懸念（オフライン前提のアプリと矛盾）

**実装方法:**
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
```

#### B. Workmanager + ローカル通知（推奨）
**メリット:**
- ✅ 完全オフライン動作
- ✅ プライバシー保護
- ✅ バックグラウンドで定期的にチェック
- ✅ 実装コストが低い
- ✅ 既存のローカル通知を活用

**デメリット:**
- ⚠️ Android: 最大15分間隔（厳密なスケジュールは不可）
- ⚠️ iOS: BGTaskSchedulerの制約あり
- ⚠️ デバイス再起動後は手動でアプリを起動する必要あり

**実装方法（Phase 8.5.3）:**
```yaml
dependencies:
  workmanager: ^0.5.1
```

```dart
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // ReminderEngineを実行
    await ReminderEngine.checkAllDocuments();
    await ReminderScheduler.scheduleAll();
    return Future.value(true);
  });
}

void main() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    "reminder-check",
    "reminderCheck",
    frequency: Duration(hours: 1), // Android最小15分
  );
}
```

#### C. ハイブリッドアプローチ（最適解）
1. **Workmanager for background checks** (Phase 8.5.3で実装)
2. **ローカル通知 for immediate alerts** (既存)
3. **カレンダー統合 for user visibility** (新規実装)
4. **オプションでFCM** (将来拡張)

### 推奨実装順序

#### Phase 1: Workmanager統合（Phase 8.5.3）- 🔴 最優先
- ✅ 完全オフライン
- ✅ バックグラウンドチェック
- ✅ 既存コード再利用

#### Phase 2: カレンダー統合 - 🟡 高優先度
- ✅ UX向上
- ✅ ユーザーが慣れ親しんだカレンダーアプリを活用
- ✅ 実装コスト低

#### Phase 3: FCMプッシュ通知 - 🟢 将来拡張
- ⚠️ バックエンド必要
- ⚠️ ユーザー設定でオプトイン
- ⚠️ プライバシーポリシー更新必要

---

## 3. 結論

### カレンダー通知
**実装方法:** `add_2_calendar` パッケージを使用
**優先度:** 🟡 高優先度
**実装場所:** DocumentEditPageに「カレンダーに追加」ボタン

### プッシュ通知
**推奨アプローチ:** Workmanager + ローカル通知（Phase 8.5.3）
**FCMは将来拡張:** ユーザー需要に応じて検討

### 次のアクション
1. ✅ **Phase 8.5.2完了**: 通知一覧機能実装済み
2. 🔴 **Phase 8.5.3開始**: Workmanager統合（最優先）
3. 🟡 **カレンダー統合**: add_2_calendar導入
4. 🟢 **FCM検討**: ユーザーフィードバック収集後

### 実装優先度
```
Phase 8.5.3 (Workmanager) > カレンダー統合 > FCM
      🔴                          🟡              🟢
```
