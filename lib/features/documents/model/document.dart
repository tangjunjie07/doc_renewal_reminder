/// 証件（ドキュメント）モデル
/// 
/// 家族メンバーが所有する証件（在留カード、パスポート等）の情報を保持します。
class Document {
  final int? id;
  
  /// 所有者のメンバーID
  final int memberId;
  
  /// 証件タイプ (residence_card / passport / drivers_license / insurance_card / mynumber_card / other)
  final String documentType;
  
  /// 証件番号（任意）セキュリティのため入力は必須ではない
  final String? documentNumber;
  
  /// 有効期限
  final DateTime expiryDate;
  
  /// カスタム更新ポリシーID（nullの場合はデフォルトポリシーを使用）
  final int? policyId;
  
  /// カスタムリマインダー日数（nullの場合はデフォルトポリシーを使用）
  /// 例: 30 = 1ヶ月前, 90 = 3ヶ月前, 180 = 6ヶ月前, 365 = 1年前
  final int? customReminderDays;
  
  /// カスタム通知頻度（nullの場合はデフォルトポリシーを使用）
  /// 'daily' / 'weekly' / 'biweekly' / 'monthly'
  final String? customReminderFrequency;
  
  /// カレンダーに自動同期するか
  final bool syncToCalendar;
  
  /// 備考・メモ
  final String? notes;
  
  /// 作成日時
  final DateTime? createdAt;
  
  /// 更新日時
  final DateTime? updatedAt;

  Document({
    this.id,
    required this.memberId,
    required this.documentType,
    this.documentNumber,
    required this.expiryDate,
    this.policyId,
    this.customReminderDays,
    this.customReminderFrequency,
    this.syncToCalendar = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// MapからDocumentオブジェクトを生成（データベース読み込み用）
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      memberId: map['member_id'] as int,
      documentType: map['document_type'] as String,
      documentNumber: map['document_number'] as String?,
      expiryDate: DateTime.parse(map['expiry_date'] as String),
      policyId: map['policy_id'] as int?,
      customReminderDays: map['custom_reminder_days'] as int?,
      customReminderFrequency: map['custom_reminder_frequency'] as String?,
      syncToCalendar: map['sync_to_calendar'] == 1,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// DocumentオブジェクトをMapに変換（データベース保存用）
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'id': id,
      'member_id': memberId,
      'document_type': documentType,
      'document_number': documentNumber,
      'expiry_date': expiryDate.toIso8601String(),
      'policy_id': policyId,
      'custom_reminder_days': customReminderDays,
      'custom_reminder_frequency': customReminderFrequency,
      'sync_to_calendar': syncToCalendar ? 1 : 0,
      'notes': notes,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// コピーを作成（一部プロパティを変更）
  Document copyWith({
    int? id,
    int? memberId,
    String? documentType,
    String? documentNumber,
    DateTime? expiryDate,
    int? policyId,
    int? customReminderDays,
    String? customReminderFrequency,
    bool? syncToCalendar,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      policyId: policyId ?? this.policyId,
      customReminderDays: customReminderDays ?? this.customReminderDays,
      customReminderFrequency: customReminderFrequency ?? this.customReminderFrequency,
      syncToCalendar: syncToCalendar ?? this.syncToCalendar,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Document(id: $id, memberId: $memberId, documentType: $documentType, expiryDate: $expiryDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document &&
        other.id == id &&
        other.memberId == memberId &&
        other.documentType == documentType &&
        other.expiryDate == expiryDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, memberId, documentType, expiryDate);
  }
}
