/// 更新ポリシーモデル
/// 
/// 証件の更新リマインダーに関するポリシーを定義します。
/// デフォルトポリシーとカスタムポリシーの両方をサポートします。
class RenewalPolicy {
  final int? id;
  
  /// 証件タイプ (residence_card / passport / drivers_license / insurance_card / mynumber_card / other)
  final String documentType;
  
  /// 有効期限の何日前からリマインダーを開始するか
  final int daysBeforeExpiry;
  
  /// リマインダーの頻度 (daily / weekly / biweekly / monthly)
  final String reminderFrequency;
  
  /// 自動更新されるかどうか（例：保険証は通常自動更新）
  final bool autoRenewable;
  
  /// 備考・注意事項
  final String? notes;
  
  /// 作成日時
  final DateTime? createdAt;
  
  /// 更新日時
  final DateTime? updatedAt;

  RenewalPolicy({
    this.id,
    required this.documentType,
    required this.daysBeforeExpiry,
    required this.reminderFrequency,
    required this.autoRenewable,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// MapからRenewalPolicyオブジェクトを生成（データベース読み込み用）
  factory RenewalPolicy.fromMap(Map<String, dynamic> map) {
    return RenewalPolicy(
      id: map['id'] as int?,
      documentType: map['document_type'] as String,
      daysBeforeExpiry: map['days_before_expiry'] as int,
      reminderFrequency: map['reminder_frequency'] as String,
      autoRenewable: (map['auto_renewable'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// RenewalPolicyオブジェクトをMapに変換（データベース保存用）
  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return {
      'id': id,
      'document_type': documentType,
      'days_before_expiry': daysBeforeExpiry,
      'reminder_frequency': reminderFrequency,
      'auto_renewable': autoRenewable ? 1 : 0,
      'notes': notes,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': now.toIso8601String(),
    };
  }

  /// コピーを作成（一部プロパティを変更）
  RenewalPolicy copyWith({
    int? id,
    String? documentType,
    int? daysBeforeExpiry,
    String? reminderFrequency,
    bool? autoRenewable,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RenewalPolicy(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      daysBeforeExpiry: daysBeforeExpiry ?? this.daysBeforeExpiry,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      autoRenewable: autoRenewable ?? this.autoRenewable,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'RenewalPolicy(id: $id, documentType: $documentType, daysBeforeExpiry: $daysBeforeExpiry, reminderFrequency: $reminderFrequency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RenewalPolicy &&
        other.id == id &&
        other.documentType == documentType &&
        other.daysBeforeExpiry == daysBeforeExpiry &&
        other.reminderFrequency == reminderFrequency &&
        other.autoRenewable == autoRenewable;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      documentType,
      daysBeforeExpiry,
      reminderFrequency,
      autoRenewable,
    );
  }
}
