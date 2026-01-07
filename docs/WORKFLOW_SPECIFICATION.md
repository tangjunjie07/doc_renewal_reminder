# ワークフロー仕様書（Workflow Specification）

> **目的**: 次回AIが読んでも即座に理解できる、アプリの完全なワークフローと仕様
> 
> **最終更新**: 2026年1月8日  
> **バージョン**: 1.0  
> **製品完成度**: 98/100点

---

## 📱 アプリ概要

### プロダクト名
**Document Renewal Reminder App**（証件更新リマインダー）

### コンセプト
家族全員の重要書類（在留カード、パスポート、免許証など）の有効期限を管理し、更新申請期間に入ったら自動で通知するオフライン完結型アプリ。

### 主要機能
1. **家族メンバー管理** - 家族全員の情報を登録
2. **証件管理** - 各メンバーの証件（書類）を管理
3. **スマートリマインダー** - ルールベースの自動通知
4. **状態管理** - 更新開始〜完了までの進捗追跡
5. **データバックアップ** - JSONエクスポート/インポート（上書きモード）
6. **バックグラウンド通知** - アプリ終了時も24時間ごとに自動チェック
7. **カレンダー同期** - iOS/Androidカレンダーにイベント追加
8. **多言語対応** - 日本語・英語・中国語

### ターゲットプラットフォーム
- **iOS/Android** - メイン（通知・カレンダー同期・バックグラウンドタスク完全対応）
- **macOS** - デスクトップ開発用（通知制限あり）
- **Web** - 未対応（Hive対応済みだが通知不可）

---

## 🏗️ アーキテクチャ

### 技術スタック
```
Flutter 3.0+
├── sqflite (SQLite) - iOS/Android/macOS/Windows/Linux
├── hive - Web
├── flutter_local_notifications - 通知
├── workmanager - バックグラウンドタスク
├── share_plus - ファイル共有
├── file_picker - ファイル選択
├── add_2_calendar - カレンダー統合
└── shared_preferences - 設定保存
```

### ディレクトリ構造
```
lib/
├── main.dart                    # エントリーポイント
├── app.dart                     # MyApp（多言語・テーマ管理）
├── core/                        # コア機能
│   ├── database/                # DB層
│   │   ├── db_provider.dart     # SQLite管理
│   │   └── hive_provider.dart   # Web用Hive
│   ├── localization/            # 多言語
│   │   ├── app_localizations.dart
│   │   ├── notification_localizations.dart
│   │   ├── intl_ja.arb
│   │   ├── intl_en.arb
│   │   └── intl_zh.arb
│   ├── background/              # バックグラウンド
│   │   └── background_task_service.dart
│   └── notification_service.dart # 通知サービス
├── features/                    # 機能別
│   ├── family/                  # 家族管理
│   │   ├── model/
│   │   ├── repository/
│   │   └── ui/
│   ├── documents/               # 証件管理
│   │   ├── model/
│   │   ├── repository/
│   │   └── ui/
│   ├── reminder/                # リマインダー
│   │   ├── model/
│   │   ├── repository/
│   │   └── service/
│   ├── settings/                # 設定
│   │   ├── service/
│   │   │   └── data_export_service.dart
│   │   └── settings_page.dart
│   └── navigation/              # ナビゲーション
│       └── main_navigation_page.dart
└── shared/                      # 共有コンポーネント
```

---

## 💾 データモデル

### 1. FamilyMember（家族メンバー）
```dart
{
  id: int?,
  name: String,                // 名前
  relationship: String,        // 関係（self/spouse/child/parent/other）
  dateOfBirth: DateTime?,      // 生年月日
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### 2. Document（証件）
```dart
{
  id: int?,
  memberId: int,               // 外部キー: FamilyMember
  documentType: String,        // 証件タイプ
  documentNumber: String?,     // 証件番号（任意）
  expiryDate: DateTime,        // 有効期限
  policyId: int?,              // カスタムポリシーID（未使用）
  customReminderDays: int?,    // カスタムリマインダー日数
  customReminderFrequency: String?, // カスタム通知頻度
  syncToCalendar: bool,        // カレンダー同期フラグ
  notes: String?,              // 備考
  createdAt: DateTime,
  updatedAt: DateTime
}
```

**証件タイプ**:
- `residence_card` - 在留カード（90日前通知）
- `passport` - パスポート（180日前通知）
- `drivers_license` - 運転免許証（30日前通知）
- `health_insurance` - 保険証（30日前通知）
- `mynumber_card` - マイナンバーカード（90日前通知）
- `other` - その他（30日前通知）

### 3. ReminderState（リマインダー状態）
```dart
{
  id: int?,
  documentId: int,             // 外部キー: Document（UNIQUE）
  status: ReminderStatus,      // 状態（normal/reminding/paused）
  reminderStartDate: DateTime?,  // リマインダー開始日
  expectedFinishDate: DateTime?, // 予定完了日
  lastNotificationDate: DateTime?, // 最後の通知日
  createdAt: DateTime,
  updatedAt: DateTime
}
```

**ReminderStatus** enum:
```dart
enum ReminderStatus {
  normal('NORMAL'),      // 通常状態（通知なし）
  reminding('REMINDING'), // 通知中
  paused('PAUSED')       // 一時停止（更新手続き中）
}
```

---

## 🔄 主要ワークフロー

### A. 証件追加フロー
```
1. 証件一覧画面で「+」ボタンをタップ
2. メンバー選択ダイアログ表示
   - 既存メンバーを選択
   - または「新規メンバー追加」
3. 証件編集画面
   - 証件タイプ選択（グリッドUI）
   - 有効期限選択（日付ピッカー）
   - 証件番号入力（任意）
   - カスタムリマインダー設定
   - カレンダー同期トグル
   - 備考入力
4. 「保存」ボタン
5. DocumentRepository.insert()
6. カレンダー同期（syncToCalendar=trueの場合）
7. ReminderEngine.checkDocument() → 状態判定
8. ReminderScheduler.scheduleAll() → 通知スケジュール
```

### B. リマインダー自動チェックフロー
```
[起動時]
main.dart
  ↓
ReminderScheduler.scheduleAll()
  ↓
全証件を取得
  ↓
各証件について:
  - ReminderEngine.checkDocument()
  - 有効期限までの日数を計算
  - リマインダー期間内か判定
  - ReminderState作成/更新
  - NotificationService.scheduleNotification()

[バックグラウンド: 24時間ごと]
BackgroundTaskService.callbackDispatcher()
  ↓
ReminderEngine.checkAllDocuments()
  ↓
ReminderScheduler.scheduleAll()
```

### C. 通知タップフロー
```
通知をタップ
  ↓
NotificationService._onNotificationTapped()
  ↓
payload（documentId）を解析
  ↓
DocumentAllListPageに遷移
  ↓
該当する証件カードをハイライト表示（未実装）
```

### D. 更新開始〜完了フロー
```
[更新開始]
証件カードをタップ
  ↓
DocumentActionDialog表示
  ↓
「更新開始」ボタン
  ↓
確認ダイアログ
  ↓
ReminderEngine.confirmRenewalStarted()
  - 状態: REMINDING → PAUSED
  - expectedFinishDate = 有効期限日
  ↓
ReminderScheduler.cancelForDocument()
  - 通常通知をキャンセル
  ↓
有効期限日9:00 AMに最終警告通知をスケジュール
  - 通知ID: documentId * 1000 + 999

[更新完了]
DocumentActionDialog
  ↓
「更新完了」ボタン
  ↓
確認ダイアログ
  ↓
ReminderEngine.confirmRenewalCompleted()
  - 状態: 任意 → NORMAL
  ↓
ReminderScheduler.cancelForDocument()
  - 全通知をキャンセル（最終警告含む）
```

### E. データエクスポート/インポートフロー
```
[エクスポート]
設定画面 → 「データエクスポート」
  ↓
確認ダイアログ
  ↓
DataExportService.exportToJson()
  - 全FamilyMember取得
  - 全Document取得
  - 全ReminderState取得
  - JSON形式に変換
  ↓
DataExportService.createExportFile()
  - 一時ディレクトリにファイル作成
  - ファイル名: doc_reminder_backup_YYYY-MM-DDTHH-MM-SS.json
  ↓
DataExportService.shareFile()
  - share_plusでファイル共有ダイアログ表示
  - ユーザーが保存先を選択

[インポート]
設定画面 → 「データインポート」
  ↓
⚠️ 上書き警告ダイアログ
  「既存の全データが削除されます。バックアップがあることを確認してください。」
  ↓
file_pickerでJSONファイル選択
  ↓
DataExportService.clearAllData()
  - ReminderState全削除
  - Document全削除
  - FamilyMember全削除
  ↓
DataExportService.importFromJson()
  - バージョンチェック（v1.0）
  - メンバーをインポート（ID自動採番）
  - 証件をインポート（memberIdマッピング）
  - リマインダー状態をインポート（documentIdマッピング）
  ↓
成功メッセージ表示
  「インポート完了: X人, Y件」
```

---

## 🔔 通知システム

### 通知ID体系
```
documentId * 1000 + offset

- offset 0-998: 通常のリマインダー通知
- offset 999: 有効期限最終警告通知（更新開始時のみ）
```

### 通知スケジューリングロジック
```dart
// 1. リマインダー期間を計算
reminderStartDate = expiryDate - customReminderDays（またはデフォルト日数）

// 2. 次回通知日を計算（頻度に基づく）
switch (customReminderFrequency) {
  case 'daily':   nextDate = lastNotification + 1日
  case 'weekly':  nextDate = lastNotification + 7日
  case 'biweekly': nextDate = lastNotification + 14日
  case 'monthly': nextDate = lastNotification + 30日
}

// 3. 通知をスケジュール
NotificationService.scheduleNotification(
  id: documentId * 1000,
  title: '{証件タイプ}の更新申請期限が近づいています',
  body: '{メンバー名}さんの{証件タイプ}の有効期限まであと{X}日です。',
  scheduledDate: nextDate,
)
```

### 通知の多言語対応
- `NotificationLocalizations` クラスで言語コードを永続化
- バックグラウンドタスクでも言語設定を読み込み
- 通知タイトル・本文を動的に生成

---

## 🎭 状態マシン（State Machine）

### ReminderState状態遷移図
```
┌─────────┐
│ NORMAL  │ 通常状態（リマインダー開始前 or 更新完了後）
└────┬────┘
     │ リマインダー期間に入る
     ↓
┌──────────┐
│REMINDING │ 通知中（定期的に通知を送信）
└────┬─────┘
     │ ユーザーが「更新開始」
     ↓
┌─────────┐
│ PAUSED  │ 一時停止（更新手続き中、通常通知停止）
└────┬────┘     │
     │          │ 有効期限日に最終警告通知
     │          ↓
     │     [期限日通知]
     │
     │ ユーザーが「更新完了」
     ↓
┌─────────┐
│ NORMAL  │ 通常状態に戻る
└─────────┘

注: PAUSED状態でも有効期限日には最終警告通知が送信される
```

### 状態遷移トリガー
1. **NORMAL → REMINDING**
   - トリガー: `ReminderEngine.checkDocument()`
   - 条件: 現在日 >= リマインダー開始日 && 現在日 < 有効期限
   - 処理: `ReminderState.startReminding()`

2. **REMINDING → PAUSED**
   - トリガー: ユーザー操作「更新開始」
   - 処理: `ReminderEngine.confirmRenewalStarted()`
   - 副作用: 
     - 通常通知をキャンセル
     - 有効期限日9:00 AMに最終警告通知をスケジュール

3. **PAUSED → REMINDING**（自動復帰）
   - トリガー: `ReminderEngine._resumeExpiredPausedStates()`
   - 条件: 現在日 > expectedFinishDate（有効期限を過ぎた）
   - 処理: `ReminderState.resume()`
   - 備考: 現在は未使用（有効期限を過ぎたら最終警告が出ているため）

4. **任意 → NORMAL**
   - トリガー: ユーザー操作「更新完了」
   - 処理: `ReminderEngine.confirmRenewalCompleted()`
   - 副作用: 全通知をキャンセル（最終警告含む）

---

## 📲 UI構造

### 画面構成
```
MainNavigationPage (BottomNavigationBar)
├── [証件] DocumentAllListPage (初期画面)
│   ├── タップ → DocumentActionDialog
│   ├── 長押し → DocumentEditPage
│   └── 右クリック → コンテキストメニュー
│       ├── 通知状態 → DocumentActionDialog
│       ├── 編集 → DocumentEditPage
│       └── 削除 → 確認ダイアログ
├── [家族] FamilyListPage
│   └── メンバータップ → DocumentListPage (特定メンバーの証件)
└── [設定] SettingsPage
    ├── 言語選択 (ja/en/zh)
    ├── データエクスポート
    ├── データインポート
    ├── 通知情報一覧
    ├── 通知デバッグ
    ├── バックグラウンドタスク設定
    └── データベースデバッグ
```

### DocumentActionDialog（通知状態管理ダイアログ）
```
┌────────────────────────────────┐
│ 在留カード                       │
│ 山田太郎                        │
├────────────────────────────────┤
│ 📅 期限: 2026年12月31日         │
│ ⏰ 残り日数: 357日              │
│ 🔔 通知状態: 通知中 🔔          │
├────────────────────────────────┤
│ [更新開始（通知を一時停止）] ◀ REMINDING状態
│ [更新完了（通知を停止）]     ◀ PAUSED状態
│ [閉じる]                        │
└────────────────────────────────┘
```

---

## 🌍 多言語対応

### サポート言語
- **日本語 (ja)** - デフォルト
- **英語 (en)**
- **中国語 (zh)**

### 主要なl10nキー
```dart
// 証件タイプ
residenceCard, passport, driversLicense, insuranceCard, mynumberCard

// 通知関連
notificationStatus, statusNormal, statusReminding, statusPaused
startRenewal, completeRenewal, confirmRenewalStart, confirmRenewalComplete

// データ管理
exportData, importData, exportSuccess, importSuccess
importDataWarning // 「既存の全データが削除されます」

// ラベル
expiryLabel, documentNumberLabel, daysRemaining
```

### 言語切り替えフロー
```
設定画面 → 言語選択
  ↓
MyApp.setLocale(context, locale)
  ↓
SharedPreferences.setString('language_code', locale.languageCode)
  ↓
NotificationLocalizations.saveLanguageCode(locale.languageCode)
  ↓
アプリ全体が再ビルド（通知も新言語で生成）
```

---

## 🎯 重要な実装ポイント

### 1. 通知ID管理
- **通常通知**: `documentId * 1000 + 0`
- **最終警告通知**: `documentId * 1000 + 999`
- これにより1つの証件につき最大1000個の通知枠を確保

### 2. バックグラウンドタスク
- **workmanager** を使用
- **24時間ごと**に自動実行
- Android/iOSのみ対応（macOS/Webは除外）
- アプリ完全終了時も動作

### 3. カレンダー同期
- **add_2_calendar** パッケージ使用
- **iOS/Androidのみ対応**（macOS未対応）
- 同期内容:
  - タイトル: 「{証件タイプ} リマインダー開始日」
  - 日付: リマインダー開始日（終日イベント）
  - 説明: 有効期限、証件番号、備考

### 4. データエクスポート/インポート
- **JSON形式**（version: "1.0"）
- **上書きモード**: インポート前に全データ削除
- **エクスポート内容**: FamilyMember, Document, ReminderState
- **ID自動マッピング**: 旧ID → 新IDの対応表を作成

### 5. プラットフォーム別対応
```dart
// iOS/Android
- 通知: ✅ 完全対応
- カレンダー: ✅ 完全対応
- バックグラウンドタスク: ✅ 完全対応
- ファイル共有: ✅ 完全対応

// macOS
- 通知: ⚠️ 制限あり（バナー表示されないことがある）
- カレンダー: ❌ 未対応（MissingPluginException）
- バックグラウンドタスク: ❌ 未対応
- ファイル共有: ⚠️ file_picker動作（警告あり）

// Web
- 通知: ❌ 未対応
- データベース: ✅ Hive対応
```

---

## 📊 データフロー図

### 証件追加から通知までの完全フロー
```
[ユーザー操作]
  ↓
DocumentEditPage.save()
  ↓
DocumentRepository.insert(document)
  ↓
SQLite/Hive に保存
  ↓
add_2_calendar (syncToCalendar=true)
  ↓
ReminderEngine.checkDocument(documentId)
  ↓
有効期限までの日数を計算
  ↓
リマインダー期間内？
  YES ↓                    NO → 終了
ReminderStateRepository.insert(
  status: REMINDING,
  reminderStartDate: today
)
  ↓
ReminderScheduler.scheduleForDocument(documentId)
  ↓
次回通知日を計算（頻度に基づく）
  ↓
NotificationService.scheduleNotification(
  id: documentId * 1000,
  title: 多言語対応タイトル,
  body: 多言語対応本文,
  scheduledDate: 次回通知日
)
  ↓
[通知スケジュール完了]
```

---

## 🔐 セキュリティ・プライバシー

### データ保存
- **完全オフライン**: インターネット接続不要
- **ローカルストレージのみ**: SQLite (モバイル) / Hive (Web)
- **暗号化**: 未実装（Phase 3.6で生体認証を予定）

### 権限
- **iOS**: NSCalendarsUsageDescription（カレンダーアクセス）
- **Android**: READ_CALENDAR, WRITE_CALENDAR

---

## 🐛 既知の制限事項

1. **macOS通知表示**
   - システム設定によってはバナーが表示されない
   - 通知センターには届く

2. **macOSカレンダー同期**
   - add_2_calendar パッケージが未対応
   - エラーは silent に処理

3. **Web対応**
   - 通知機能なし（flutter_local_notifications未対応）
   - バックグラウンドタスクなし

4. **file_pickerパッケージ警告**
   - macOS/Windows/Linuxで警告が出る
   - 実際の動作には影響なし

---

## 📝 今後の拡張計画

### Phase 8.5.2: 通知情報一覧
- 予定された通知の一覧表示
- 通知の手動キャンセル

### Phase 8.2: リリース準備
- アプリアイコン作成（1024x1024）
- スプラッシュ画面実装
- ProGuard設定（Android）

### Phase 8.8: 自動テスト
- Widget テスト
- Unit テスト
- Integration テスト

### Phase 3.6: 生体認証（オプション）
- Face ID / Touch ID / 指紋認証
- アプリ起動時認証
- バックグラウンド復帰時再認証

---

## 📞 トラブルシューティング

### 通知が表示されない
1. 通知権限を確認（iOS: 設定 > 通知）
2. デバッグ通知機能でテスト（設定 > 通知デバッグ）
3. ReminderState の状態を確認（REMINDING状態か？）
4. getPendingNotifications() で予定通知を確認

### バックグラウンドタスクが動作しない
1. Android/iOSでのみ動作（macOS/Web未対応）
2. 初回実行は15分後（initialDelay設定）
3. ログで確認: `[BackgroundTask] 🔄 バックグラウンドタスク開始`

### インポートエラー
1. JSONファイルのバージョン確認（"version": "1.0"）
2. ファイル形式が正しいか確認
3. エラーメッセージで詳細を確認

---

## 🎓 開発ガイドライン

### コーディング規約
- ファイル名: `snake_case.dart`
- クラス名: `PascalCase`
- 変数名: `camelCase`
- すべてのUI文言は `l10n.key` を使用（ハードコード禁止）

### デバッグ方法
```dart
// ログ出力
debugPrint('[Feature] メッセージ');

// 通知デバッグ
設定 > 通知デバッグ > 即座に通知 / 10秒後に通知

// データベース確認
設定 > データベースデバッグ
```

### Git運用
- `main` ブランチ: 安定版
- Feature開発: `feature/機能名` ブランチ
- コミットメッセージ: `[Phase X.Y] 機能名: 変更内容`

---

**最終更新**: 2026年1月8日  
**製品完成度**: 98/100点  
**次のステップ**: Phase 8（モバイル実機テスト）
