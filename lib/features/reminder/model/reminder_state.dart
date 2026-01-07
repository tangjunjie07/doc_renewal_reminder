/// リマインダー状態モデル
/// 
/// 状態マシン: NORMAL → REMINDING → PAUSED → REMINDING → NORMAL
/// - NORMAL: 通常状態（リマインダー開始前 or 更新完了後）
/// - REMINDING: リマインダー期間中（通知送信中）
/// - PAUSED: 一時停止中（ユーザーが更新開始を確認した期間）
class ReminderState {
  final int? id;
  final int documentId;
  final ReminderStatus status;
  final DateTime? reminderStartDate;     // リマインダー開始日
  final DateTime? expectedFinishDate;    // 予定完了日（PAUSED時に設定）
  final DateTime? lastNotificationDate;  // 最後の通知送信日
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderState({
    this.id,
    required this.documentId,
    required this.status,
    this.reminderStartDate,
    this.expectedFinishDate,
    this.lastNotificationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// データベースからの復元
  factory ReminderState.fromMap(Map<String, dynamic> map) {
    return ReminderState(
      id: map['id'] as int?,
      documentId: map['document_id'] as int,
      status: ReminderStatus.fromString(map['status'] as String),
      reminderStartDate: map['reminder_start_date'] != null
          ? DateTime.parse(map['reminder_start_date'] as String)
          : null,
      expectedFinishDate: map['expected_finish_date'] != null
          ? DateTime.parse(map['expected_finish_date'] as String)
          : null,
      lastNotificationDate: map['last_notification_date'] != null
          ? DateTime.parse(map['last_notification_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// データベースへの保存
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'document_id': documentId,
      'status': status.value,
      'reminder_start_date': reminderStartDate?.toIso8601String(),
      'expected_finish_date': expectedFinishDate?.toIso8601String(),
      'last_notification_date': lastNotificationDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピー（状態更新用）
  ReminderState copyWith({
    int? id,
    int? documentId,
    ReminderStatus? status,
    DateTime? reminderStartDate,
    DateTime? expectedFinishDate,
    DateTime? lastNotificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderState(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      status: status ?? this.status,
      reminderStartDate: reminderStartDate ?? this.reminderStartDate,
      expectedFinishDate: expectedFinishDate ?? this.expectedFinishDate,
      lastNotificationDate: lastNotificationDate ?? this.lastNotificationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 新規作成（NORMAL状態）
  factory ReminderState.createNormal(int documentId) {
    final now = DateTime.now();
    return ReminderState(
      documentId: documentId,
      status: ReminderStatus.normal,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// リマインダー開始（NORMAL → REMINDING）
  ReminderState startReminding(DateTime reminderStartDate) {
    assert(status == ReminderStatus.normal, 'Can only start from NORMAL state');
    return copyWith(
      status: ReminderStatus.reminding,
      reminderStartDate: reminderStartDate,
      updatedAt: DateTime.now(),
    );
  }

  /// 一時停止（REMINDING → PAUSED）
  ReminderState pause(DateTime expectedFinishDate) {
    assert(status == ReminderStatus.reminding, 'Can only pause from REMINDING state');
    return copyWith(
      status: ReminderStatus.paused,
      expectedFinishDate: expectedFinishDate,
      updatedAt: DateTime.now(),
    );
  }

  /// リマインダー再開（PAUSED → REMINDING）
  ReminderState resume() {
    assert(status == ReminderStatus.paused, 'Can only resume from PAUSED state');
    return copyWith(
      status: ReminderStatus.reminding,
      expectedFinishDate: null, // 予定完了日をクリア
      updatedAt: DateTime.now(),
    );
  }

  /// 更新完了（REMINDING/PAUSED → NORMAL）
  ReminderState complete() {
    assert(
      status == ReminderStatus.reminding || status == ReminderStatus.paused,
      'Can only complete from REMINDING or PAUSED state',
    );
    return copyWith(
      status: ReminderStatus.normal,
      reminderStartDate: null,
      expectedFinishDate: null,
      lastNotificationDate: null,
      updatedAt: DateTime.now(),
    );
  }

  /// 通知送信記録
  ReminderState recordNotification() {
    return copyWith(
      lastNotificationDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ReminderState(id: $id, documentId: $documentId, status: ${status.value}, '
        'reminderStartDate: $reminderStartDate, expectedFinishDate: $expectedFinishDate, '
        'lastNotificationDate: $lastNotificationDate)';
  }
}

/// リマインダー状態列挙型
enum ReminderStatus {
  normal('NORMAL'),
  reminding('REMINDING'),
  paused('PAUSED');

  final String value;
  const ReminderStatus(this.value);

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReminderStatus.normal,
    );
  }
}
