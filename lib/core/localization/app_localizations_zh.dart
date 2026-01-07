// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '文书更新提醒';

  @override
  String get familyMembers => '家庭成员';

  @override
  String get noFamilyMembers => '暂无家庭成员';

  @override
  String get documents => '文书';

  @override
  String get noDocuments => '暂无文书';

  @override
  String get addMember => '添加成员';

  @override
  String get editMember => '编辑成员';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get saveAndAddDocument => '保存并添加证件';

  @override
  String get saveAndAddAnother => '保存并添加下一个';

  @override
  String get name => '姓名';

  @override
  String get relation => '关系';

  @override
  String get birthday => '生日';

  @override
  String get self => '本人';

  @override
  String get spouse => '配偶';

  @override
  String get child => '子女';

  @override
  String get parent => '父母';

  @override
  String get sibling => '兄弟姐妹';

  @override
  String get other => '其他';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get deleteMemberMessage => '确定要删除此成员吗？';

  @override
  String get selectDate => '选择日期';

  @override
  String get loading => '加载中...';

  @override
  String get loadMembersFailed => '成员加载失败';

  @override
  String get deleteMember => '删除成员';

  @override
  String get deleteAllDocuments => '批量删除证件';

  @override
  String get noDocumentsToDelete => '没有可删除的证件';

  @override
  String deleteAllDocumentsConfirm(String name, String count) {
    return '确定要删除$name的$count个证件吗？\n\n此操作无法撤销。';
  }

  @override
  String get deleteAll => '全部删除';

  @override
  String documentsDeleted(String name, String count) {
    return '已删除$name的$count个证件';
  }

  @override
  String get deleteFailed => '删除失败';

  @override
  String deleteMemberConfirm(String name) {
    return '确定要删除$name吗？\n\n* 必须先删除所有证件。';
  }

  @override
  String memberDeleted(String name) {
    return '已删除$name';
  }

  @override
  String get noFamilyMembersYet => '暂无家庭成员';

  @override
  String get noFamilyMembersDesc => '点击下方按钮添加第一个成员\n开始管理您的证件';

  @override
  String get addFirstMember => '添加第一个成员';

  @override
  String get edit => '编辑';

  @override
  String get deleteDocumentsTooltip => '批量删除证件';

  @override
  String get deleteMemberTooltip => '删除成员';

  @override
  String documentCount(String count) {
    return '证件: $count个';
  }

  @override
  String get allDocuments => '证件列表';

  @override
  String documentItemCount(String count) {
    return '$count个';
  }

  @override
  String get filterTooltip => '筛选';

  @override
  String get filterSelfOnly => '仅本人';

  @override
  String get filterAll => '所有人';

  @override
  String get addDocumentButton => '添加证件';

  @override
  String get noDocumentsYet => '还没有证件';

  @override
  String get noOwnDocumentsYet => '您还没有任何证件';

  @override
  String get addFirstDocument => '添加第一个证件';

  @override
  String get noDocumentsDesc => '点击下方按钮添加证件\n从此不再担心证件过期';

  @override
  String get loadDocumentsFailed => '证件加载失败';

  @override
  String get settings => '设置';

  @override
  String get addNewMember => '添加新成员';

  @override
  String get selectMember => '选择成员';

  @override
  String get noMembersYet => '还没有成员';

  @override
  String get addFirstMemberPrompt => '点击下方按钮\n添加第一个成员';

  @override
  String notificationTitleRenewalNeeded(Object documentType) {
    return '$documentType需要更新';
  }

  @override
  String notificationBodyRenewalNeeded(
      Object days, Object documentType, Object memberName) {
    return '$memberName的$documentType还有$days天就要过期了';
  }

  @override
  String get notificationBodyGeneric => '您的证件有效期即将到期，请及时查看。';

  @override
  String get documentTypeResidenceCard => '在留卡';

  @override
  String get documentTypePassport => '护照';

  @override
  String get documentTypeDriversLicense => '驾驶执照';

  @override
  String get documentTypeHealthInsurance => '健康保险卡';

  @override
  String get documentTypeMyNumber => '个人编号卡';

  @override
  String get documentTypeOther => '其他证件';

  @override
  String get reminderFrequencyDaily => '每天';

  @override
  String get reminderFrequencyWeekly => '每周';

  @override
  String get reminderFrequencyBiweekly => '每两周';

  @override
  String get reminderFrequencyMonthly => '每月';

  @override
  String get policyNotesResidenceCard => '可以在有效期前3个月到入管办理更新申请';

  @override
  String get policyNotesPassport => '从申请到领取大约需要1周时间。如有出国计划请提前办理';

  @override
  String get policyNotesDriversLicense => '生日前后1个月为更新期间';

  @override
  String get policyNotesInsuranceCard => '通常会自动更新。如未收到新保险证请联系公司或保险机构';

  @override
  String get policyNotesMynumberCard => '可以在有效期前3个月到市区町村窗口办理更新手续';

  @override
  String get policyNotesOther => '更新手续详情请咨询发行机构';

  @override
  String get policyValidationMinDays => '提醒期间必须至少为1天';

  @override
  String get policyValidationMaxDays => '提醒期间必须在365天以内';

  @override
  String policyDescriptionTemplate(Object days, Object frequency) {
    return '从有效期前$days天开始,$frequency通知';
  }

  @override
  String get errorDatabaseOperation => '数据库操作失败';

  @override
  String get errorDocumentNotFound => '未找到证件';

  @override
  String get errorNotificationScheduling => '通知设置失败';

  @override
  String get addDocument => '添加证件';

  @override
  String get editDocument => '编辑证件';

  @override
  String get documentType => '证件类型';

  @override
  String get expiryDate => '有效期限';

  @override
  String get reminderSettings => '提醒设置';

  @override
  String get documentNumber => '证件号码';

  @override
  String get documentNumberOptional => '证件号码（可选）';

  @override
  String get securityNotRequired => '出于安全考虑，输入不是必需的';

  @override
  String get notes => '备注';

  @override
  String get notesOptional => '备注（可选）';

  @override
  String get add => '添加';

  @override
  String get addingDocument => '正在添加证件...';

  @override
  String get updatingDocument => '正在更新证件...';

  @override
  String get documentAdded => '证件已添加';

  @override
  String get documentUpdated => '证件已更新';

  @override
  String get pleaseSelectExpiryDate => '请选择有效期限';

  @override
  String get dateToSelect => '选择日期';

  @override
  String get selectedDate => '已选日期';

  @override
  String get tapToSelect => '点击选择';

  @override
  String get reminderPeriodQuestion => '您希望提前多久收到通知？';

  @override
  String get oneMonthBefore => '提前1个月';

  @override
  String get threeMonthsBefore => '提前3个月';

  @override
  String get sixMonthsBefore => '提前6个月';

  @override
  String get reminderExample => '更新时的注意事项等';

  @override
  String get birthdayOptional => '生日（可选）';

  @override
  String get birthdayUsageHint => '生日用于年龄计算等。\n您可以稍后添加或更改。';

  @override
  String get fullName => '姓名';

  @override
  String get nameExample => '张三';

  @override
  String get relationshipType => '关系';

  @override
  String get memberInfoUpdated => '成员信息已更新';

  @override
  String get memberAdded => '成员已添加';

  @override
  String get saveFailed => '保存失败';

  @override
  String get addingMember => '正在添加成员...';

  @override
  String get saving => '保存中...';

  @override
  String get pleaseEnterName => '请输入姓名';

  @override
  String get selectBirthdayOptional => '选择生日（可选）';

  @override
  String get clear => '清除';

  @override
  String documentsFor(Object name) {
    return '$name的证件';
  }

  @override
  String documentsCount(Object count) {
    return '$count个';
  }

  @override
  String get loadingDocuments => '加载中...';

  @override
  String get deleteDocument => '删除证件';

  @override
  String deleteDocumentConfirm(Object documentType) {
    return '确定要删除$documentType吗？\n\n此操作无法撤销。';
  }

  @override
  String get deleteDocumentConfirmation => '确定要删除此证件吗？\n\n此操作无法撤销。';

  @override
  String documentDeleted(Object documentType) {
    return '已删除$documentType';
  }

  @override
  String get documentsNotYetFor => '暂无证件';

  @override
  String addDocumentsPrompt(Object name) {
    return '添加$name的证件\n不再担心过期问题';
  }

  @override
  String get worryFreeExpiry => '不再担心过期问题';

  @override
  String get documentAdding => '添加证件';

  @override
  String expired(Object days) {
    return '已过期（$days天前）';
  }

  @override
  String expiringSoon(Object days) {
    return '还有$days天过期';
  }

  @override
  String daysLeft(Object days) {
    return '还有$days天';
  }

  @override
  String get daysRemaining => '剩余天数';

  @override
  String expiryDateLabel(Object date) {
    return '有效期: $date';
  }

  @override
  String dateFormat(Object day, Object month, Object year) {
    return '$year年$month月$day日';
  }

  @override
  String numberLabel(Object number) {
    return '号码: $number';
  }

  @override
  String get editAction => '编辑';

  @override
  String get deleteAction => '删除';

  @override
  String get language => 'Language / 语言 / 言語';

  @override
  String get changeAppLanguage => '更改应用语言';

  @override
  String get notificationList => '通知列表';

  @override
  String get viewScheduledNotifications => '查看已计划的通知';

  @override
  String get noScheduledNotifications => '没有已计划的通知';

  @override
  String get noScheduledNotificationsDesc => '添加证件后，将设置期限前通知';

  @override
  String get cancelNotification => '取消通知';

  @override
  String get cancelNotificationConfirmation => '确定要取消此通知吗？';

  @override
  String get notificationCancelled => '通知已取消';

  @override
  String get notificationId => '通知ID';

  @override
  String get noTitle => '无标题';

  @override
  String get refresh => '刷新';

  @override
  String get failedToLoadNotifications => '无法加载通知';

  @override
  String get failedToCancelNotification => '无法取消通知';

  @override
  String get reminderStartDate => '提醒开始日期';

  @override
  String get addToCalendar => '添加到日历';

  @override
  String get addedToCalendar => '已添加到日历';

  @override
  String get failedToAddToCalendar => '添加到日历失败';

  @override
  String get syncToCalendar => '自动同步到日历';

  @override
  String get syncToCalendarDescription => '启用后，保存时自动添加提醒到日历';

  @override
  String get error => '错误';

  @override
  String get notificationFrequency => '通知频率';

  @override
  String get databaseDebug => '数据库调试';

  @override
  String get viewDatabaseStatus => '查看数据库状态和数据';

  @override
  String get residenceCard => '在留卡';

  @override
  String get passport => '护照';

  @override
  String get driversLicense => '驾驶执照';

  @override
  String get insuranceCard => '保险卡';

  @override
  String get mynumberCard => '个人编号卡';

  @override
  String get otherDocument => '其他';

  @override
  String get confirmRenewalStart => '确认开始更新';

  @override
  String get renewalStartDescription => '开始此证件的更新手续吗？\n通知将暂时停止。';

  @override
  String get renewalStarted => '✅ 已开始更新。通知已暂停。';

  @override
  String get confirmRenewalComplete => '确认更新完成';

  @override
  String get renewalCompleteDescription => '此证件的更新已完成吗？\n通知将停止。';

  @override
  String get renewalCompleted => '✅ 更新完成！通知已停止。';

  @override
  String get notificationStatus => '通知状态';

  @override
  String get days => '天';

  @override
  String get confirm => '确认';

  @override
  String get startRenewal => '开始更新（暂停通知）';

  @override
  String get completeRenewal => '完成更新（停止通知）';

  @override
  String get close => '关闭';

  @override
  String get statusNormal => '正常';

  @override
  String get statusReminding => '通知中 🔔';

  @override
  String get statusPaused => '已暂停 ⏸️';

  @override
  String get expiryLabel => '到期日';

  @override
  String get documentNumberLabel => '号码';

  @override
  String get exportData => '导出数据';

  @override
  String get exportDataDescription => '备份所有数据到JSON文件';

  @override
  String get exportDataConfirm => '是否导出所有数据？';

  @override
  String get export => '导出';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get exportFailed => '导出失败';

  @override
  String get importData => '导入数据';

  @override
  String get importDataDescription => '从json文件恢复数据';

  @override
  String get importDataWarning => '警告：导入将删除所有现有数据。请确保已备份。';

  @override
  String get import => '导入';

  @override
  String importSuccess(Object documentCount, Object memberCount) {
    return '导入完成：$memberCount人，$documentCount件证件';
  }

  @override
  String get importFailed => '导入失败';
}
