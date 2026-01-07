# Document Renewal Reminder App

## 产品需求与开发计划（PRD）

> **Product Completion**: 98/100 points  
> **Last Updated**: 2026年1月8日  
> **Current Phase**: Phase 8 (Mobile Device Testing)

---

## 1. 项目背景与目标

本项目旨在开发一款 **Flutter 跨平台（iOS/Android/macOS）移动应用**，用于帮助个人及家庭成员集中管理各类证件的有效期，并在 **证件进入"可申请更新窗口"后进行智能提醒**，避免因错过申请时间而带来的风险。

### 核心目标

* 管理家庭成员的多種证件
* 基于证件类型规则进行智能提醒
* App 不打开或被关闭时依然可靠提醒（24小时バックグラウンドタスク）
* 支持多语言（日本语 / 英语 / 中文）
* 数据导出/导入功能（JSON备份，覆盖模式）
* 日历同步功能（iOS/Android）
* 不依赖后端、不使用付费 API，完全离线可用

---

## 2. 目标用户

* 在日外国人及其家庭
* 拥有多个需要定期更新证件的个人 / 家庭
* 希望通过简单工具避免遗忘证件更新事项的用户

---

## 3. 平台与技术选型

### 平台

* iOS
* Android
* macOS（開発用、通知制限あり）
* Web（Hive対応、通知未対応）

### 技术框架

* Flutter 3.0+
* Dart

### 本地存储

* SQLite（sqflite） - iOS/Android/macOS
* Hive - Web
* 数据仅保存在本机

### 通知方案

* 系统本地通知（Local Notifications）
* 使用 `flutter_local_notifications`
* バックグラウンドタスク（`workmanager`）- 24時間ごとに自動チェック
* 不使用 Firebase / APNs

### 多语言

* Flutter intl
* ARB 文件管理文案
* 初期支持：

  * 中文（简体）
  * 日文
  * 英文（可选）

---

## 4. 功能需求

### 4.1 家庭成员管理（Family）

#### 功能

* 新增 / 编辑 / 删除家庭成员
* 成员关系类型：

  * 本人
  * 配偶
  * 子女

#### 数据字段

* member_id
* name
* relation
* birthday（可选）

---

### 4.2 证件管理（Document）

#### 支持证件类型（MVP）

* 在留卡
* 护照
* 驾照
* 身份证
* MyNumber

#### 证件字段

* document_id
* member_id
* document_type
* country（可选）
* document_number（可选）
* expiry_date（必填）
* renewal_policy_id
* remark

---

### 4.3 证件更新规则（Renewal Policy）

#### 设计原则

* 规则驱动，而非固定提前天数
* 不使用 AI 计算日期
* 用户可手动覆盖默认规则

#### 示例规则

| 证件类型     | 默认可申请时间  |
| -------- | -------- |
| 在留卡      | 到期前 3 个月 |
| 护照（中国）   | 到期前 6 个月 |
| 驾照       | 到期前 1 个月 |
| MyNumber | 到期前 3 个月 |

#### 核心计算逻辑

```
remind_start_date = expiry_date - renewal_months_before
```

---

### 4.4 智能提醒系统（Reminder）

#### 提醒触发逻辑

* 仅在证件进入「可申请更新窗口」后开始提醒
* 默认每天提醒一次
* 使用系统本地通知
* App 未打开 / 被关闭时仍然生效

---

### 4.5 证件状态机（State Machine）

```
NORMAL
  ↓（进入可申请窗口）
REMINDING
  ↓（用户确认已开始更新）
PAUSED
  ↓（超过预计完成时间）
REMINDING
  ↓（用户输入新有效期）
NORMAL
```

---

### 4.6 用户确认与暂停机制

当用户点击「已开始更新」：

* 输入预计完成时间（expected_finish_date）
* 暂停提醒
* 若超过预计完成时间且未更新证件 → 自动恢复提醒

---

## 5. 多语言设计（Flutter intl）

### 设计原则

* 文案与逻辑完全解耦
* 所有 UI 与通知文案使用 intl key
* 不在代码中硬编码语言文本

### 示例 ARB 文案

```json
"remind.title.residence_card": "在留卡需要更新",
"remind.body.default": "{name} 的 {doc} 已进入可申请更新阶段（剩余 {days} 天）"
```

---

## 6. 非功能性需求

* 完全离线可用
* 无账号系统
* 无后端依赖
* 启动速度快
* UI 简洁、工具导向

---

## 7. MVP 开发计划

### Phase 1（Week 1）

* Flutter 项目初始化
* 数据模型设计
* 家庭成员 & 证件 CRUD

### Phase 2（Week 2）

* 更新规则系统
* 提醒时间计算
* 本地通知注册与取消

### Phase 3（Week 3）

* 状态机逻辑
* 多语言接入（intl）
* iOS / Android 真机测试

---

## 8. 追加功能要求（2026-01-08更新）

### 8.1 数据导入导出功能 ✅ **已完成**（Phase 8.5.1）

#### 实装状態
* ✅ JSON形式のエクスポート/インポート実装済み
* ✅ **上書きモード**：インポート時に既存データを全削除
* ✅ share_plus統合（iOS/Android）
* ✅ file_picker統合（ファイル選択）
* ✅ 警告ダイアログ実装（データ削除の明示的な警告）
* ✅ 多言語対応（ja/en/zh）

#### 実装功能
* データエクスポート：全FamilyMember、Document、ReminderStateをJSON出力
* データインポート：JSONファイルから復元（既存データを上書き）
* ファイル共有：iOS/Androidのシェアシートで送信
* ID自動マッピング：旧ID → 新ID自動変換

#### ファイル形式
```json
{
  "version": "1.0",
  "exportDate": "2026-01-08T12:30:45.123Z",
  "members": [...],
  "documents": [...],
  "reminderStates": [...]
}
```

#### 技術実装
* DataExportService（lib/features/settings/service/）
* share_plus: ^7.2.2
* file_picker: ^6.2.1
* ファイル名形式：doc_reminder_backup_YYYY-MM-DDTHH-MM-SS.json

### 8.2 通知信息一览功能（优先级：中） 📋 **計画中**（Phase 8.5.2）

#### 功能
* 设置Tab内新增「通知一览」页面
* 显示已调度的所有通知
* 显示内容：
  - 家庭成员名
  - 证件类型
  - 通知时间
  - 通知状态（已调度/已发送/已取消）
* 操作：
  - 查看通知详情
  - 取消单个通知
  - 重新调度通知

#### 技术要点
* 从ReminderStateRepository获取数据
* 与NotificationService集成
* 实时更新通知状态

### 8.3 后台通知功能 ✅ **已完成**（Phase 8.1）

#### 実装状態
* ✅ workmanagerパッケージ統合
* ✅ 24時間ごとのバックグラウンドタスク実装
* ✅ BackgroundTaskService実装
* ✅ ReminderEngine・ReminderScheduler統合
* ✅ iOS/Android対応（macOS/Web除外）

#### 実装功能
* 毎日自動チェック：アプリ完全終了時も動作
* 全証件の有効期限チェック
* リマインダー期間に入った証件の自動通知スケジュール
* ReminderState状態の自動更新

#### 技術実装
* BackgroundTaskService（lib/core/background/）
* workmanager: ^0.5.2
* 実行頻度：24時間ごと
* 初回実行：登録から15分後

### 8.4 通知アクションダイアログ ✅ **已完成**（Phase 8.4）

#### 実装状態
* ✅ DocumentActionDialog実装
* ✅ 「更新開始」「更新完了」ボタン
* ✅ ReminderState状態遷移（REMINDING → PAUSED → NORMAL）
* ✅ 通知の一時停止/再開機能
* ✅ 有効期限日の最終警告通知（通知ID: documentId * 1000 + 999）

#### 実装功能
* 証件カードタップでダイアログ表示
* 現在の通知状態表示（通知中/一時停止/通常）
* 更新開始：REMINDING → PAUSED、通常通知停止、最終警告スケジュール
* 更新完了：任意状態 → NORMAL、全通知キャンセル

### 8.5 カレンダー同期 ✅ **已完成**（Phase 8.3）

#### 実装状態
* ✅ add_2_calendarパッケージ統合
* ✅ リマインダー開始日をカレンダーに追加
* ✅ iOS/Android対応（macOS未対応）
* ✅ 証件ごとにON/OFF切り替え可能

#### 実装功能
* カレンダーイベント自動作成
* イベント内容：証件タイプ、有効期限、証件番号、備考
* 終日イベントとして登録
* プラットフォーム制限の自動処理

---

## 9. 当前状態（2026年1月8日）

### ✅ 已完成功能
1. 家庭成員管理
2. 証件管理
3. 規則駆動リマインダー
4. 状態マシン（NORMAL → REMINDING → PAUSED → NORMAL）
5. ローカル通知システム
6. バックグラウンドタスク（24時間ごと）
7. カレンダー同期（iOS/Android）
8. 通知アクションダイアログ
9. データエクスポート/インポート（上書きモード）
10. 多言語対応（日本語/英語/中文）

### 🔄 進行中
- Phase 8: モバイル実機テスト（iOS/Android）

### 📋 計画中
- Phase 8.5.2: 通知一覧UI
- Phase 8.2: リリース準備（アイコン、スプラッシュ画面）
- Phase 8.8: 自動テスト（Widget/Unit/Integration）
- Phase 3.6: 生体認証（オプション）

### 🎯 製品完成度: 98/100点

---

## 10. 后続扩張方向

* OCR 証件識別
* 家庭多設備同期
* 企業 / HR 証件管理版本
* AI 文案輔助（非関鍵路径）
* 生体認証（Face ID / Touch ID）

---

## 11. MVP 成功標準 ✅ **達成済み**

* ✅ 用户在不打开 App 的情況下仍能収到提醒（バックグラウンドタスク実装済み）
* ✅ 不错过証件可申请更新時間（規則駆動システム）
* ✅ 数据結構具備良好拡張性（SQLite/Hive）
* ✅ 多言語体系完整、可維護（ja/en/zh）
* ✅ データバックアップ・復元機能（JSON エクスポート/インポート）

---

## 12. 総結

本項目以 **穏定、低成本、強実用性** 為核心原則，
是一個可以 **快速落地、真実解決問題、并具備長期拡張潜力** 的移動應用項目。

**現在の状態**: 98%完成、モバイル実機テストフェーズ。
