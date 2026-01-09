// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '文書更新リマインダー';

  @override
  String get familyMembers => '家族メンバー';

  @override
  String get noFamilyMembers => 'まだ家族メンバーがいません';

  @override
  String get documents => '文書';

  @override
  String get noDocuments => 'まだ文書がありません';

  @override
  String get addMember => 'メンバーを追加';

  @override
  String get editMember => 'メンバーを編集';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get saveAndAddDocument => '保存して証件を追加';

  @override
  String get saveAndAddAnother => '保存して次を追加';

  @override
  String get name => '名前';

  @override
  String get relation => '関係';

  @override
  String get birthday => '誕生日';

  @override
  String get self => '本人';

  @override
  String get spouse => '配偶者';

  @override
  String get child => '子供';

  @override
  String get parent => '親';

  @override
  String get sibling => '兄弟姉妹';

  @override
  String get other => 'その他';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String get deleteMemberMessage => 'このメンバーを削除してもよろしいですか？';

  @override
  String get selectDate => '日付を選択';

  @override
  String get loading => '読み込み中...';

  @override
  String get loadMembersFailed => 'メンバーの読み込みに失敗しました';

  @override
  String get deleteMember => 'メンバーを削除';

  @override
  String get deleteAllDocuments => '証件を一括削除';

  @override
  String get noDocumentsToDelete => '削除する証件がありません';

  @override
  String deleteAllDocumentsConfirm(String name, String count) {
    return '$nameさんの証件を$count件削除してもよろしいですか？\n\nこの操作は取り消せません。';
  }

  @override
  String get deleteAll => '全て削除';

  @override
  String documentsDeleted(String name, String count) {
    return '$nameさんの証件$count件を削除しました';
  }

  @override
  String get deleteFailed => '削除に失敗しました';

  @override
  String deleteMemberConfirm(String name) {
    return '$nameさんを削除してもよろしいですか？\n\n※ 先に証件を全て削除する必要があります。';
  }

  @override
  String memberDeleted(String name) {
    return '$nameさんを削除しました';
  }

  @override
  String get noFamilyMembersYet => '家族メンバーがまだいません';

  @override
  String get noFamilyMembersDesc => '下のボタンから最初のメンバーを追加しましょう\n証件の管理を始めることができます';

  @override
  String get addFirstMember => '最初のメンバーを追加';

  @override
  String get edit => '編集';

  @override
  String get deleteDocumentsTooltip => '証件を一括削除';

  @override
  String get deleteMemberTooltip => 'メンバー削除';

  @override
  String documentCount(String count) {
    return '証件: $count件';
  }

  @override
  String get allDocuments => '証件一覧';

  @override
  String documentItemCount(String count) {
    return '$count件';
  }

  @override
  String get filterTooltip => 'フィルター';

  @override
  String get filterSelfOnly => '自分のみ';

  @override
  String get filterAll => '全員';

  @override
  String get addDocumentButton => '証件追加';

  @override
  String get noDocumentsYet => '証件がまだありません';

  @override
  String get noOwnDocumentsYet => '自分の証件がまだありません';

  @override
  String get addFirstDocument => '最初の証件を追加';

  @override
  String get noDocumentsDesc => '下のボタンから証件を追加しましょう\n期限切れの心配がなくなります';

  @override
  String get loadDocumentsFailed => '証件の読み込みに失敗しました';

  @override
  String get settings => '設定';

  @override
  String get addNewMember => '新しいメンバーを追加';

  @override
  String get selectMember => 'メンバーを選択';

  @override
  String get noMembersYet => 'メンバーがいません';

  @override
  String get addFirstMemberPrompt => '下のボタンから\n最初のメンバーを追加しましょう';

  @override
  String notificationTitleRenewalNeeded(Object documentType) {
    return '$documentTypeの更新が必要です';
  }

  @override
  String notificationBodyRenewalNeeded(
      Object days, Object documentType, Object memberName) {
    return '$memberNameさんの$documentTypeはあと$days日で有効期限が切れます';
  }

  @override
  String get notificationBodyGeneric => '証件の有効期限が近づいています。確認してください。';

  @override
  String get notificationPermissionTitle => '通知許可';

  @override
  String get notificationPermissionStatusChecking => '状態を確認中…';

  @override
  String get notificationPermissionGranted => '許可済み';

  @override
  String get notificationPermissionDenied => '未許可';

  @override
  String get notificationPermissionDialogTitle => '通知のお願い';

  @override
  String get notificationPermissionDialogContent =>
      '期限リマインダーを受け取るために通知の許可が必要です。よろしいですか？';

  @override
  String get notificationPermissionLater => 'あとで';

  @override
  String get notificationPermissionAllow => '許可する';

  @override
  String get notificationPermissionDisabledTitle => '通知が無効です';

  @override
  String get notificationPermissionDisabledContent =>
      '端末の設定から通知を有効にしてください。設定を開きますか？';

  @override
  String get openSettings => '設定を開く';

  @override
  String get notificationAlreadyGranted => '通知は既に許可されています';

  @override
  String get documentTypeResidenceCard => '在留カード';

  @override
  String get documentTypePassport => 'パスポート';

  @override
  String get documentTypeDriversLicense => '運転免許証';

  @override
  String get documentTypeHealthInsurance => '健康保険証';

  @override
  String get documentTypeMyNumber => 'マイナンバーカード';

  @override
  String get documentTypeOther => 'その他の証件';

  @override
  String get reminderFrequencyDaily => '毎日';

  @override
  String get reminderFrequencyWeekly => '毎週';

  @override
  String get reminderFrequencyBiweekly => '2週間ごと';

  @override
  String get reminderFrequencyMonthly => '毎月';

  @override
  String get policyNotesResidenceCard => '入管での更新申請は有効期限の3ヶ月前から可能です';

  @override
  String get policyNotesPassport => '申請から受取まで約1週間かかります。海外渡航予定がある場合は早めの更新を';

  @override
  String get policyNotesDriversLicense => '誕生日の前後1ヶ月が更新期間です';

  @override
  String get policyNotesInsuranceCard =>
      '通常は自動更新されます。新しい保険証が届かない場合は勤務先または保険者に確認してください';

  @override
  String get policyNotesMynumberCard => '有効期限の3ヶ月前から市区町村の窓口で更新手続きが可能です';

  @override
  String get policyNotesOther => '更新手続きの詳細は発行元にご確認ください';

  @override
  String get policyValidationMinDays => 'リマインダー期間は1日以上である必要があります';

  @override
  String get policyValidationMaxDays => 'リマインダー期間は365日以内にしてください';

  @override
  String policyDescriptionTemplate(Object days, Object frequency) {
    return '有効期限の$days日前から、$frequency通知します';
  }

  @override
  String get errorDatabaseOperation => 'データベース操作に失敗しました';

  @override
  String get errorDocumentNotFound => '証件が見つかりません';

  @override
  String get errorNotificationScheduling => '通知のスケジュール設定に失敗しました';

  @override
  String get addDocument => '証件を追加';

  @override
  String get editDocument => '証件を編集';

  @override
  String get documentType => '証件タイプ';

  @override
  String get expiryDate => '有効期限';

  @override
  String get reminderSettings => 'リマインダー設定';

  @override
  String get documentNumber => '証件番号';

  @override
  String get documentNumberOptional => '証件番号（任意）';

  @override
  String get securityNotRequired => 'セキュリティ上、入力は必須ではありません';

  @override
  String get notes => 'メモ';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get add => '追加';

  @override
  String get addingDocument => '証件を追加しています...';

  @override
  String get updatingDocument => '証件を更新しています...';

  @override
  String get documentAdded => '証件を追加しました';

  @override
  String get documentUpdated => '証件を更新しました';

  @override
  String get pleaseSelectExpiryDate => '有効期限を選択してください';

  @override
  String get dateToSelect => '日付を選択';

  @override
  String get selectedDate => '選択された日付';

  @override
  String get tapToSelect => 'タップして選択';

  @override
  String get reminderPeriodQuestion => '期限のどれくらい前から通知を受け取りますか？';

  @override
  String get oneMonthBefore => '1ヶ月前';

  @override
  String get threeMonthsBefore => '3ヶ月前';

  @override
  String get sixMonthsBefore => '6ヶ月前';

  @override
  String get oneYearBefore => '1年前';

  @override
  String get reminderExample => '更新時の注意事項など';

  @override
  String get birthdayOptional => '生年月日（任意）';

  @override
  String get birthdayUsageHint => '生年月日は年齢計算などに使用されます。\n後から追加・変更することもできます。';

  @override
  String get fullName => '氏名';

  @override
  String get nameExample => '山田 太郎';

  @override
  String get relationshipType => '続柄';

  @override
  String get memberInfoUpdated => 'メンバー情報を更新しました';

  @override
  String get memberAdded => 'メンバーを追加しました';

  @override
  String get saveFailed => '保存に失敗しました';

  @override
  String get addingMember => 'メンバーを追加しています...';

  @override
  String get saving => '保存中...';

  @override
  String get pleaseEnterName => '名前を入力してください';

  @override
  String get selectBirthdayOptional => '生年月日を選択（任意）';

  @override
  String get clear => 'クリア';

  @override
  String documentsFor(Object name) {
    return '$nameの証件';
  }

  @override
  String documentsCount(Object count) {
    return '$count件';
  }

  @override
  String get loadingDocuments => '読み込み中...';

  @override
  String get deleteDocument => '証件を削除';

  @override
  String deleteDocumentConfirm(Object documentType) {
    return '$documentTypeを削除してもよろしいですか？\n\nこの操作は取り消せません。';
  }

  @override
  String get deleteDocumentConfirmation =>
      'この証件を削除してもよろしいですか？\n\nこの操作は取り消せません。';

  @override
  String documentDeleted(Object documentType) {
    return '$documentTypeを削除しました';
  }

  @override
  String get documentsNotYetFor => '証件がまだありません';

  @override
  String addDocumentsPrompt(Object name) {
    return '$nameさんの証件を追加しましょう\n期限切れの心配がなくなります';
  }

  @override
  String get worryFreeExpiry => '期限切れの心配がなくなります';

  @override
  String get documentAdding => '証件追加';

  @override
  String expired(Object days) {
    return '期限切れ（$days日前）';
  }

  @override
  String expiringSoon(Object days) {
    return 'あと$days日で期限切れ';
  }

  @override
  String daysLeft(Object days) {
    return 'あと$days日';
  }

  @override
  String get daysRemaining => '残り日数';

  @override
  String expiryDateLabel(Object date) {
    return '期限: $date';
  }

  @override
  String dateFormat(Object day, Object month, Object year) {
    return '$year年$month月$day日';
  }

  @override
  String numberLabel(Object number) {
    return '番号: $number';
  }

  @override
  String get editAction => '編集';

  @override
  String get deleteAction => '削除';

  @override
  String get language => 'Language / 语言 / 言語';

  @override
  String get changeAppLanguage => 'アプリの言語を変更';

  @override
  String get notificationList => '通知一覧';

  @override
  String get viewScheduledNotifications => '予定されている通知を確認';

  @override
  String get noScheduledNotifications => '予定されている通知はありません';

  @override
  String get noScheduledNotificationsDesc => '証件を追加すると、期限前に通知が設定されます';

  @override
  String get cancelNotification => '通知をキャンセル';

  @override
  String get cancelAllNotifications => '全てキャンセル';

  @override
  String get cancelAllNotificationsConfirmation =>
      '全ての通知をキャンセルしますか？この操作は取り消せません。';

  @override
  String get allNotificationsCancelled => '全ての通知をキャンセルしました';

  @override
  String get cancelNotificationConfirmation => 'この通知をキャンセルしますか？';

  @override
  String get notificationCancelled => '通知をキャンセルしました';

  @override
  String get notificationId => '通知ID';

  @override
  String get noTitle => 'タイトルなし';

  @override
  String get refresh => '更新';

  @override
  String get failedToLoadNotifications => '通知の読み込みに失敗しました';

  @override
  String get failedToCancelNotification => '通知のキャンセルに失敗しました';

  @override
  String get reminderStartDate => 'リマインダー開始日';

  @override
  String get addToCalendar => 'カレンダーに追加';

  @override
  String get addedToCalendar => 'カレンダーに追加しました';

  @override
  String get failedToAddToCalendar => 'カレンダー追加に失敗しました';

  @override
  String get syncToCalendar => 'カレンダーに自動同期';

  @override
  String get syncToCalendarDescription => '有効にすると、保存時にカレンダーにリマインダーを自動追加します';

  @override
  String get error => 'エラー';

  @override
  String get notificationFrequency => '通知頻度';

  @override
  String get databaseDebug => 'データベースデバッグ';

  @override
  String get viewDatabaseStatus => 'データベースの状態とデータを表示';

  @override
  String get residenceCard => '在留カード';

  @override
  String get passport => 'パスポート';

  @override
  String get driversLicense => '運転免許証';

  @override
  String get insuranceCard => '保険証';

  @override
  String get mynumberCard => 'マイナンバー';

  @override
  String get otherDocument => 'その他';

  @override
  String get confirmRenewalStart => '更新開始の確認';

  @override
  String get renewalStartDescription => 'この証件の更新手続きを開始しますか？\n通知は一時的に停止されます。';

  @override
  String get renewalStarted => '✅ 更新を開始しました。通知は一時停止されます。';

  @override
  String get confirmRenewalComplete => '更新完了の確認';

  @override
  String get renewalCompleteDescription => 'この証件の更新が完了しましたか？\n通知は停止されます。';

  @override
  String get renewalCompleted => '✅ 更新完了！通知は停止されました。';

  @override
  String get notificationStatus => '通知状態';

  @override
  String get days => '日';

  @override
  String get confirm => '確認';

  @override
  String get startRenewal => '更新開始（通知を一時停止）';

  @override
  String get completeRenewal => '更新完了（通知を停止）';

  @override
  String get close => '閉じる';

  @override
  String get statusNormal => '通常';

  @override
  String get statusReminding => '通知中 🔔';

  @override
  String get statusPaused => '一時停止中 ⏸️';

  @override
  String get expiryLabel => '期限';

  @override
  String get documentNumberLabel => '番号';

  @override
  String get exportData => 'データエクスポート';

  @override
  String get exportDataDescription => '全データをJSONファイルにバックアップ';

  @override
  String get exportDataConfirm => '全てのデータをエクスポートしますか？';

  @override
  String get export => 'エクスポート';

  @override
  String get shareBackupFile => 'バックアップファイルを共有します';

  @override
  String get exportSuccess => 'エクスポートが完了しました';

  @override
  String get exportFailed => 'エクスポートに失敗しました';

  @override
  String get importData => 'データインポート';

  @override
  String get importDataDescription => 'JSONファイルからデータを復元';

  @override
  String get importDataWarning =>
      '警告：インポートすると、既存の全データが削除されます。バックアップがあることを確認してください。';

  @override
  String get import => 'インポート';

  @override
  String importSuccess(Object documentCount, Object memberCount) {
    return 'インポート完了: $memberCount人, $documentCount件';
  }

  @override
  String get importFailed => 'インポートに失敗しました';

  @override
  String get securitySettings => 'セキュリティ';

  @override
  String get securitySettingsDescription => '生体認証とプライバシー設定';

  @override
  String get biometricAuth => '生体認証でロック';

  @override
  String biometricAvailable(String types) {
    return '利用可能: $types';
  }

  @override
  String get biometricNextStartup => '次回起動時から生体認証が必要になります';

  @override
  String get biometricNotAvailable => '生体認証が利用できません';

  @override
  String get biometricEnabled => '生体認証が有効になりました';

  @override
  String get biometricDisabled => '生体認証が無効になりました';

  @override
  String get authenticationFailed => '認証に失敗しました';

  @override
  String get biometricRequired => '生体認証が必要です';

  @override
  String get biometricRequiredDescription => 'アプリを使用するには認証してください';

  @override
  String get authenticate => '認証する';

  @override
  String get unlockApp => 'アプリを使用するには認証が必要です';

  @override
  String get enableBiometricPrompt => '生体認証を有効にするために認証してください';

  @override
  String get dataBackup => 'データバックアップ';

  @override
  String get dataBackupDescription => 'データのエクスポート・インポート';

  @override
  String get supportTitle => 'お問い合わせ・ご意見';

  @override
  String get supportDescription => 'ご意見・ご要望は下記からご連絡ください。';

  @override
  String get supportDialogContent =>
      'ご意見・ご要望はGitHubまたはメールでお送りいただけます。内容は必ず開発者に届きます。';

  @override
  String get githubButton => 'GitHubでフィードバック';

  @override
  String get mailButton => 'メールで問い合わせ';

  @override
  String get supportMailSubject => '【アプリ問い合わせ】';

  @override
  String get supportMailBody => 'ご意見・ご要望内容を記入してください。';
}
