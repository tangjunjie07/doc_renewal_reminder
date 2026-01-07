# Document Renewal Reminder App

## 产品需求与开发计划（PRD）

---

## 1. 项目背景与目标

本项目旨在开发一款 **Flutter 跨平台（iOS / Android）移动应用**，用于帮助个人及家庭成员集中管理各类证件的有效期，并在 **证件进入“可申请更新窗口”后进行智能提醒**，避免因错过申请时间而带来的风险。

### 核心目标

* 管理家庭成员的多种证件
* 基于证件类型规则进行智能提醒
* App 不打开或被关闭时依然可靠提醒
* 支持多语言（中文 / 日文 / 英文）
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

### 技术框架

* Flutter（单代码库）
* Dart

### 本地存储

* SQLite
* 数据仅保存在本机

### 通知方案

* 系统本地通知（Local Notifications）
* 使用 `flutter_local_notifications`
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

## 8. 追加功能要求（2026-01-07更新）

### 8.1 数据导入导出功能（优先级：高）

#### 背景
用户换设备时需要简单恢复数据。

#### iOS功能
* 数据导出到iCloud Drive
* 数据导入从iCloud Drive
* 导出/导入使用相同默认路径（方便同步）
* **附加功能**：分享功能（如果iOS支持）

#### Android功能
* 数据导出到下载目录
* 数据导入从文件选择器
* **导出后分享功能**（LINE、WeChat等主要通讯工具）

#### 技术要点
* 数据格式：JSON或SQLite备份文件
* 文件命名：doc_reminder_backup_YYYYMMDD_HHMMSS
* 包含：family_member、document、renewal_policy、reminder_state
* 加密选项（可选）

### 8.2 通知信息一览功能（优先级：中）

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

### 8.3 后台通知功能（优先级：🔴 **必须实现**）

#### 问题
当前实现：App完全关闭时无法主动检查并发送通知（仅依赖OS调度器）

#### 需求
* Android：使用WorkManager实现每日后台任务
* iOS：使用Background App Refresh实现后台刷新
* 功能：
  - 每日检查所有证件
  - 发现需要提醒的证件时发送通知
  - 更新ReminderState状态
  - 调度未来通知

#### 技术方案
* Android：`workmanager` package（1天1次后台检查）
* iOS：Background Modes配置 + BGTaskScheduler
* 共通逻辑：复用ReminderEngine和ReminderScheduler

### 8.4 推送通知实现（优先级：中）

#### 当前状态
使用本地通知（flutter_local_notifications）

#### 检讨事项
* 是否需要远程推送通知（APNs/FCM）
* 优势：
  - 服务器端触发
  - 更可靠的送达率
* 劣势：
  - 需要后端服务器
  - 违反「完全离线」原则
  - 增加维护成本

#### 建议
暂时保持本地通知，配合后台任务实现。如未来需要多设备同步或家庭共享功能时再考虑推送通知。

---

## 9. 后续扩展方向

* OCR 证件识别
* 家庭多设备同步
* 企业 / HR 证件管理版本
* AI 文案辅助（非关键路径）

---

## 9. MVP 成功标准

* 用户在不打开 App 的情况下仍能收到提醒
* 不错过证件可申请更新时间
* 数据结构具备良好扩展性
* 多语言体系完整、可维护

---

## 10. 总结

本项目以 **稳定、低成本、强实用性** 为核心原则，
是一个可以 **快速落地、真实解决问题、并具备长期扩展潜力** 的移动应用项目。
