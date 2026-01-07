# Development Plan

## Flutter + SQLite 証件智能提醒 App

> **Product Completion**: 98/100 points  
> **Last Updated**: 2026年1月8日  
> **Current Phase**: Phase 8 (Mobile Device Testing)
> 
> 本文档用于 **指導実際編碼階段**、明確毎一階段「做什么、做到什么程度、完成標準は何か」。

---

## 0. 開発階段目標

在 **不引入後端、不使用付費 API** 的前提下，完成一個：

* iOS / Android / macOS 可運行
* SQLite (mobile) / Hive (web) 本地存儲
* 規則駆動的證件提醒
* 支持多言語（Flutter intl: ja/en/zh）
* App 関閉也能提醒（バックグラウンドタスク）
* データエクスポート/インポート（JSON形式）
* カレンダー同期（iOS/Android）

的 **MVP 可用版本** ✅ **98%完成**

---

## 1️⃣ Phase 0：项目初始化（Day 1）

### 目标

完成 Flutter 项目骨架，能跑在 iOS / Android 模拟器上。

### 任务

* 创建 Flutter 项目
* 初始化目录结构（按 PRD）
* 配置依赖

### 关键依赖

```yaml
dependencies:
  flutter:
  flutter_local_notifications:
  sqflite:
  path_provider:
  intl:
  flutter_intl:
```

### 完成标准

* `flutter run` 成功
* iOS / Android 首页显示
* intl 不报错

---

## 2️⃣ Phase 1：SQLite 数据层（Day 2–3）

### 目标

完成 **可长期扩展的本地数据层**

### 数据表

* family_member
* document
* renewal_policy
* reminder_state

### 任务

* 设计表结构
* 编写 `db_provider.dart`
* 完成 CRUD 封装（Repository）

### 完成标准

* 数据可插入 / 查询 / 删除
* App 重启后数据不丢失
* 不依赖 UI 也能测试（debug log）

---

## 3️⃣ Phase 2：基础业务功能（Day 4–6）

### 目标

用户可以 **完整录入真实数据**

### 功能

* 家庭成员管理
* 证件管理
* 证件类型选择
* 有效期输入

### 技术要点

* UI 不做复杂状态管理
* Controller → Repository

### 完成标准

* 可添加多个成员
* 每个成员可有多个证件
* 数据真实落库
* **証件番号は任意入力**（リマインドに不要なため、セキュリティ面でも有利）

---

## 4️⃣ Phase 3：证件更新规则系统（Day 7–8）

### 目标

实现 **规则驱动的“可申请更新时间”计算**

### 任务

* 定义 `RenewalPolicy` Model
* 内置默认规则表
* 允许用户覆盖默认值

### 核心逻辑

```
remind_start_date = expiry_date - renewal_months_before
```

### 完成标准

* 新建证件时自动算出提醒开始时间
* UI 能展示「将从 XX 日期开始提醒」

---

## 5️⃣ Phase 4：提醒引擎 & 状态机（Day 9–11）

### 目标

这是 **App 的核心阶段**

### 状态机

```
NORMAL → REMINDING → PAUSED → REMINDING → NORMAL
```

### 任务

* 实现 ReminderEngine
* 实现 ReminderScheduler
* 状态切换时同步更新通知

### 特别注意

* 删除旧通知再注册新通知
* Notification ID 统一管理

### 完成标准

* 到达可申请日期 → 自动开始提醒
* 点击“已开始更新” → 暂停提醒
* 超期未完成 → 自动恢复提醒

---

## 6️⃣ Phase 5：本地通知系统（Day 12–13）

### 目标

确保 **App 关闭也能稳定提醒**

### 任务

* 初始化 `flutter_local_notifications`
* 请求权限（iOS / Android）
* 注册未来多天通知

### 策略

* 一次性注册未来 N 天每日通知
* 状态变化时重建通知

### 完成标准

* App 不打开 → 能收到提醒
* 重启手机后仍能提醒（Android / iOS）

---

## 7️⃣ Phase 6：多语言接入（Day 14）

### 目标

完成 intl 多语言体系

### 任务

* 配置 flutter intl
* 拆分所有文案为 key
* 提醒通知文案多语言化

### 完成标准

* 切换系统语言后 UI 自动变化
* 通知文案随系统语言变化

---

## 8️⃣ Phase 7：整体联调 & 真机测试（Day 15–16）

### 目标

保证真实使用场景可用

### 测试清单

* 多成员 + 多证件
* 不同证件规则
* 暂停 / 恢复提醒
* iOS / Android 真机

### 完成标准

* 无 crash
* 提醒时间准确
* 数据不丢失

---

## 9️⃣ Phase 8：MVP 封板（Day 17）

### 输出物

* 可安装 APK / IPA
* 项目 README
* PRD + DEV_PLAN 文档齐全

### MVP では実装しない機能

* クラウド同期
* ログインシステム
* OCR
* AI オンライン呼び出し
* **家族へのメール自動送信**（Phase 9 で実装予定）

---

## 10️⃣ 开发阶段原则（务必遵守）

* 不提前做优化
* 不引入后端
* 不引入复杂状态管理
* 先保证 **“提醒绝对可靠”**

---

## 11️⃣ 开发完成定义（Definition of Done）

* 用户不打开 App 也能收到提醒
* 不会错过证件可申请更新窗口
* 项目结构清晰，方便二次开发

---

## 🆕 Phase 8.5（追加機能実装）

### 目標

**ユーザー要望による必須機能を追加実装**

### 8.5.1 データエクスポート/インポート機能 ✅ **完了**

#### 実装状況
* ✅ DataExportService実装（lib/features/settings/service/）
* ✅ JSON形式でエクスポート/インポート
* ✅ **上書きモード**：インポート時に既存データを全削除
* ✅ share_plus統合（ファイル共有）
* ✅ file_picker統合（ファイル選択）
* ✅ 設定画面UI実装（エクスポート/インポートボタン）
* ✅ 多言語対応（ja/en/zh）
* ✅ 警告ダイアログ実装（データ削除の明示的警告）

#### 実装詳細
```dart
// DataExportService主要メソッド
- exportToJson(): 全データをMap<String, dynamic>に変換
- createExportFile(): タイムスタンプ付きJSONファイル作成
- shareFile(): share_plusでファイル共有
- importFromJson(): JSONからデータ復元（ID自動マッピング）
- clearAllData(): インポート前に全データ削除
```

#### 技術依存
```yaml
dependencies:
  path_provider: ^2.1.2
  share_plus: ^7.2.2
  file_picker: ^6.2.1
```

#### 完成標準（全て達成）
* ✅ 全データをJSON形式でエクスポート可能
* ✅ エクスポートしたファイルを別端末でインポート可能
* ✅ **上書き警告**ダイアログで誤操作防止
* ✅ iOS/AndroidでシェアシートからファイL送信可能
* ✅ ID自動マッピング（旧ID → 新ID）

### 8.5.2 通知情報一覧機能 🟡 **計画中**（Phase 8.5.2）

#### タスク

* 設定タブに「通知一覧」ページ追加
* 表示内容：
  - 家族メンバー名
  - 証件タイプ
  - 通知予定日時
  - 通知ステータス（予定/送信済み/キャンセル済み）
  - リマインダー頻度
* 操作機能：
  - 通知詳細表示
  - 個別通知のキャンセル
  - 通知の再スケジュール

#### データソース
* ReminderStateRepository
* NotificationService（スケジュール済み通知取得）

#### 完成標準
* 全スケジュール済み通知を一覧表示
* リアルタイムで状態更新
* 通知操作が正常に動作

### 8.5.3 バックグラウンド通知機能 ✅ **完了**（Phase 8.1として実装）

#### 実装状況
* ✅ BackgroundTaskService実装（lib/core/background/）
* ✅ workmanagerパッケージ統合
* ✅ 24時間ごとの自動チェック
* ✅ ReminderEngine・ReminderScheduler統合
* ✅ iOS/Android対応（macOS/Web除外）
* ✅ 初回実行15分後、以降24時間ごと

#### 実装詳細
```dart
// BackgroundTaskService
- initialize(): workmanager初期化、タスク登録
- callbackDispatcher(): バックグラウンド実行ロジック
  1. 多言語設定読み込み
  2. ReminderEngine.checkAllDocuments()
  3. ReminderScheduler.scheduleAll()
```

#### 技術依存
```yaml
dependencies:
  workmanager: ^0.5.2
```

#### 完成標準（全て達成）
* ✅ アプリ完全終了状態でも24時間ごとに自動チェック
* ✅ リマインダー期間に入った証件を確実に通知
* ✅ バッテリー消費最小化（24時間に1回のみ）
* ✅ 完全オフライン動作

### 8.5.4 プッシュ通知検討 🟢 低優先度

#### 検討事項

**現状**
* 本地通知（flutter_local_notifications）使用
* 完全オフライン動作

**リモートプッシュ通知のメリット**
* サーバー側から任意のタイミングで通知可能
* 端末の電源OFFでも次回起動時に受信
* より確実な送達率

**リモートプッシュ通知のデメリット**
* バックエンドサーバー必須（コスト増）
* Firebase/APNs設定が複雑
* 「完全オフライン」原則に違反
* プライバシーリスク増

#### 結論

**Phase 8.5.3のバックグラウンド通知で対応可能**

リモートプッシュ通知は以下の場合のみ検討：
* 多端末同期機能を追加する場合
* 家族共有機能を追加する場合
* エンタープライズ版を開発する場合

---

## 🚀 Phase 9（将来拡張）：家族メール通知機能

### 目標

**家族にも自動でリマインドメールを送信**

### 前提条件

* Phase 1-8 が完了していること
* バックエンドサービス（Firebase Functions または SMTP）の準備

### 機能

1. **データベース拡張**
   * family_member テーブルに email カラム追加
   * 家族のメールアドレスを登録可能に

2. **通知サービス拡張**
   * NotificationService を抽象インターフェース化
   * LocalNotificationService（既存）
   * EmailNotificationService（新規）
   * HybridNotificationService（両方対応）

3. **設定画面拡張**
   * 「家族メール通知を有効化」トグル
   * 各メンバーにメールアドレス設定

4. **通知フロー**
```
リマインド発動
  ↓
1. ローカル通知（本人の端末）
  ↓
2. メール通知判定
  → 設定ON & メールアドレス登録済み
    → 家族にメール送信
  → それ以外
    → スキップ
```

### 技術選択肢

**Option A: Firebase Cloud Functions（推奨）**
* 無料枠あり（月125,000回まで）
* Flutter との統合が簡単
* SendGrid / AWS SES と連携可能

**Option B: 直接 SMTP**
* Gmail SMTP（無料、1日500通まで）
* コスト最小
* 設定がやや複雑

### 拡張性設計のポイント

**既存機能への影響ゼロ**
* オフライン機能は100%維持
* メール機能はオプション扱い
* メール送信失敗してもローカル通知は継続

**段階的導入**
1. Phase 8 まで: 完全オフライン
2. Phase 9: オンライン機能を上乗せ
3. ユーザーが設定で ON/OFF 切り替え可能

### 完成標準

* 家族メールアドレス登録可能
* リマインド時に家族にもメール送信
* メール送信失敗時のフォールバック処理
* ローカル通知は影響を受けない
* 設定でメール通知の ON/OFF 切り替え可能

---

> 本 Plan 用于 **指导开发执行，不作为最終産品説明文档**。
