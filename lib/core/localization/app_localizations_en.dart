// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Document Renewal Reminder';

  @override
  String get familyMembers => 'Family Members';

  @override
  String get noFamilyMembers => 'No family members yet';

  @override
  String get documents => 'Documents';

  @override
  String get noDocuments => 'No documents yet';

  @override
  String get addMember => 'Add Member';

  @override
  String get editMember => 'Edit Member';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAndAddDocument => 'Save & Add Document';

  @override
  String get saveAndAddAnother => 'Save & Add Another';

  @override
  String get name => 'Name';

  @override
  String get relation => 'Relation';

  @override
  String get birthday => 'Birthday';

  @override
  String get self => 'Self';

  @override
  String get spouse => 'Spouse';

  @override
  String get child => 'Child';

  @override
  String get parent => 'Parent';

  @override
  String get sibling => 'Sibling';

  @override
  String get other => 'Other';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteMemberMessage =>
      'Are you sure you want to delete this member?';

  @override
  String get selectDate => 'Select Date';

  @override
  String get loading => 'Loading...';

  @override
  String get loadMembersFailed => 'Failed to load members';

  @override
  String get deleteMember => 'Delete Member';

  @override
  String get deleteAllDocuments => 'Delete All Documents';

  @override
  String get noDocumentsToDelete => 'No documents to delete';

  @override
  String deleteAllDocumentsConfirm(String name, String count) {
    return 'Are you sure you want to delete $count document(s) for $name?\n\nThis action cannot be undone.';
  }

  @override
  String get deleteAll => 'Delete All';

  @override
  String documentsDeleted(String name, String count) {
    return 'Deleted $count document(s) for $name';
  }

  @override
  String get deleteFailed => 'Deletion failed';

  @override
  String deleteMemberConfirm(String name) {
    return 'Are you sure you want to delete $name?\n\n* You must delete all documents first.';
  }

  @override
  String memberDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String get noFamilyMembersYet => 'No family members yet';

  @override
  String get noFamilyMembersDesc =>
      'Add your first member using the button below\nStart managing your documents';

  @override
  String get addFirstMember => 'Add First Member';

  @override
  String get edit => 'Edit';

  @override
  String get deleteDocumentsTooltip => 'Delete all documents';

  @override
  String get deleteMemberTooltip => 'Delete member';

  @override
  String documentCount(String count) {
    return 'Documents: $count';
  }

  @override
  String get allDocuments => 'All Documents';

  @override
  String documentItemCount(String count) {
    return '$count items';
  }

  @override
  String get filterTooltip => 'Filter';

  @override
  String get filterSelfOnly => 'My Only';

  @override
  String get filterAll => 'Everyone';

  @override
  String get addDocumentButton => 'Add Document';

  @override
  String get noDocumentsYet => 'No documents yet';

  @override
  String get noOwnDocumentsYet => 'You don\'t have any documents yet';

  @override
  String get addFirstDocument => 'Add First Document';

  @override
  String get noDocumentsDesc =>
      'Add documents using the button below\nNever worry about expiration dates again';

  @override
  String get loadDocumentsFailed => 'Failed to load documents';

  @override
  String get settings => 'Settings';

  @override
  String get addNewMember => 'Add new member';

  @override
  String get selectMember => 'Select Member';

  @override
  String get noMembersYet => 'No members yet';

  @override
  String get addFirstMemberPrompt =>
      'Add your first member\nusing the button below';

  @override
  String notificationTitleRenewalNeeded(Object documentType) {
    return 'Document Renewal Needed';
  }

  @override
  String notificationBodyRenewalNeeded(
      Object days, Object documentType, Object memberName) {
    return '$memberName\'s $documentType will expire in $days days';
  }

  @override
  String get notificationBodyGeneric =>
      'Your document is approaching its expiration date. Please check.';

  @override
  String get notificationPermissionTitle => 'Notification permission';

  @override
  String get notificationPermissionStatusChecking => 'Checking status…';

  @override
  String get notificationPermissionGranted => 'Allowed';

  @override
  String get notificationPermissionDenied => 'Not allowed';

  @override
  String get notificationPermissionDialogTitle => 'Enable notifications';

  @override
  String get notificationPermissionDialogContent =>
      'To receive renewal reminders we need notification permission. Allow?';

  @override
  String get notificationPermissionLater => 'Later';

  @override
  String get notificationPermissionAllow => 'Allow';

  @override
  String get notificationPermissionDisabledTitle => 'Notifications disabled';

  @override
  String get notificationPermissionDisabledContent =>
      'Please enable notifications in system settings. Open settings?';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notificationAlreadyGranted => 'Notifications are already allowed';

  @override
  String get documentTypeResidenceCard => 'Residence Card';

  @override
  String get documentTypePassport => 'Passport';

  @override
  String get documentTypeDriversLicense => 'Driver\'s License';

  @override
  String get documentTypeHealthInsurance => 'Health Insurance Card';

  @override
  String get documentTypeMyNumber => 'My Number Card';

  @override
  String get documentTypeOther => 'Other Document';

  @override
  String get reminderFrequencyDaily => 'Daily';

  @override
  String get reminderFrequencyWeekly => 'Weekly';

  @override
  String get reminderFrequencyBiweekly => 'Biweekly';

  @override
  String get reminderFrequencyMonthly => 'Monthly';

  @override
  String get policyNotesResidenceCard =>
      'Renewal application at immigration office is available 3 months before expiration';

  @override
  String get policyNotesPassport =>
      'Application to receipt takes about 1 week. Apply early if you have overseas travel plans';

  @override
  String get policyNotesDriversLicense =>
      'Renewal period is 1 month before and after your birthday';

  @override
  String get policyNotesInsuranceCard =>
      'Usually renewed automatically. If you don\'t receive a new card, contact your employer or insurer';

  @override
  String get policyNotesMynumberCard =>
      'Renewal procedures can be done at municipal offices 3 months before expiration';

  @override
  String get policyNotesOther =>
      'Please check with the issuer for renewal details';

  @override
  String get policyValidationMinDays =>
      'Reminder period must be at least 1 day';

  @override
  String get policyValidationMaxDays =>
      'Reminder period must be within 365 days';

  @override
  String policyDescriptionTemplate(Object days, Object frequency) {
    return 'Notify $frequency starting $days days before expiry';
  }

  @override
  String get errorDatabaseOperation => 'Database operation failed';

  @override
  String get errorDocumentNotFound => 'Document not found';

  @override
  String get errorNotificationScheduling => 'Failed to schedule notification';

  @override
  String get addDocument => 'Add Document';

  @override
  String get editDocument => 'Edit Document';

  @override
  String get documentType => 'Document Type';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get documentNumber => 'Document Number';

  @override
  String get documentNumberOptional => 'Document Number (Optional)';

  @override
  String get securityNotRequired => 'For security, input is not required';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (Optional)';

  @override
  String get add => 'Add';

  @override
  String get addingDocument => 'Adding document...';

  @override
  String get updatingDocument => 'Updating document...';

  @override
  String get documentAdded => 'Document added';

  @override
  String get documentUpdated => 'Document updated';

  @override
  String get pleaseSelectExpiryDate => 'Please select expiry date';

  @override
  String get dateToSelect => 'Select Date';

  @override
  String get selectedDate => 'Selected Date';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get reminderPeriodQuestion =>
      'How far in advance would you like to receive notifications?';

  @override
  String get oneMonthBefore => '1 Month Before';

  @override
  String get threeMonthsBefore => '3 Months Before';

  @override
  String get sixMonthsBefore => '6 Months Before';

  @override
  String get oneYearBefore => '1 Year Before';

  @override
  String get reminderExample => 'Notes for renewal process, etc.';

  @override
  String get birthdayOptional => 'Birthday (Optional)';

  @override
  String get birthdayUsageHint =>
      'Birthday is used for age calculation, etc.\nYou can add or change it later.';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameExample => 'John Doe';

  @override
  String get relationshipType => 'Relationship';

  @override
  String get memberInfoUpdated => 'Member information updated';

  @override
  String get memberAdded => 'Member added';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get addingMember => 'Adding member...';

  @override
  String get saving => 'Saving...';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get selectBirthdayOptional => 'Select birthday (Optional)';

  @override
  String get clear => 'Clear';

  @override
  String documentsFor(Object name) {
    return 'Documents for $name';
  }

  @override
  String documentsCount(Object count) {
    return '$count items';
  }

  @override
  String get loadingDocuments => 'Loading...';

  @override
  String get deleteDocument => 'Delete Document';

  @override
  String deleteDocumentConfirm(Object documentType) {
    return 'Are you sure you want to delete $documentType?\n\nThis action cannot be undone.';
  }

  @override
  String get deleteDocumentConfirmation =>
      'Are you sure you want to delete this document?\n\nThis action cannot be undone.';

  @override
  String documentDeleted(Object documentType) {
    return 'Deleted $documentType';
  }

  @override
  String get documentsNotYetFor => 'No documents yet';

  @override
  String addDocumentsPrompt(Object name) {
    return 'Add documents for $name\nNo more worries about expiration';
  }

  @override
  String get worryFreeExpiry => 'No more worries about expiration';

  @override
  String get documentAdding => 'Add Document';

  @override
  String expired(Object days) {
    return 'Expired ($days days ago)';
  }

  @override
  String expiringSoon(Object days) {
    return '$days days until expiration';
  }

  @override
  String daysLeft(Object days) {
    return '$days days left';
  }

  @override
  String get daysRemaining => 'Days Remaining';

  @override
  String expiryDateLabel(Object date) {
    return 'Expiry: $date';
  }

  @override
  String dateFormat(Object day, Object month, Object year) {
    return '$month/$day/$year';
  }

  @override
  String numberLabel(Object number) {
    return 'Number: $number';
  }

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get language => 'Language / 语言 / 言語';

  @override
  String get changeAppLanguage => 'Change app language';

  @override
  String get notificationList => 'Notifications';

  @override
  String get viewScheduledNotifications => 'View scheduled notifications';

  @override
  String get noScheduledNotifications => 'No scheduled notifications';

  @override
  String get noScheduledNotificationsDesc =>
      'Notifications will be scheduled when you add documents';

  @override
  String get cancelNotification => 'Cancel Notification';

  @override
  String get cancelAllNotifications => 'Cancel All';

  @override
  String get cancelAllNotificationsConfirmation =>
      'Cancel all notifications? This action cannot be undone.';

  @override
  String get allNotificationsCancelled => 'All notifications cancelled';

  @override
  String get cancelNotificationConfirmation => 'Cancel this notification?';

  @override
  String get notificationCancelled => 'Notification cancelled';

  @override
  String get notificationId => 'Notification ID';

  @override
  String get noTitle => 'No Title';

  @override
  String get refresh => 'Refresh';

  @override
  String get failedToLoadNotifications => 'Failed to load notifications';

  @override
  String get failedToCancelNotification => 'Failed to cancel notification';

  @override
  String get reminderStartDate => 'Reminder Start Date';

  @override
  String get addToCalendar => 'Add to Calendar';

  @override
  String get addedToCalendar => 'Added to calendar';

  @override
  String get failedToAddToCalendar => 'Failed to add to calendar';

  @override
  String get syncToCalendar => 'Auto-sync to Calendar';

  @override
  String get syncToCalendarDescription =>
      'Automatically add reminder to calendar when saving';

  @override
  String get error => 'Error';

  @override
  String get notificationFrequency => 'Notification Frequency';

  @override
  String get databaseDebug => 'Database Debug';

  @override
  String get viewDatabaseStatus => 'View database status and data';

  @override
  String get residenceCard => 'Residence Card';

  @override
  String get passport => 'Passport';

  @override
  String get driversLicense => 'Driver\'s License';

  @override
  String get insuranceCard => 'Insurance Card';

  @override
  String get mynumberCard => 'My Number Card';

  @override
  String get otherDocument => 'Other';

  @override
  String get confirmRenewalStart => 'Confirm Renewal Start';

  @override
  String get renewalStartDescription =>
      'Start renewal process for this document?\nNotifications will be temporarily paused.';

  @override
  String get renewalStarted => '✅ Renewal started. Notifications paused.';

  @override
  String get confirmRenewalComplete => 'Confirm Renewal Complete';

  @override
  String get renewalCompleteDescription =>
      'Is the renewal for this document complete?\nNotifications will be stopped.';

  @override
  String get renewalCompleted => '✅ Renewal complete! Notifications stopped.';

  @override
  String get notificationStatus => 'Notification Status';

  @override
  String get days => 'days';

  @override
  String get confirm => 'Confirm';

  @override
  String get startRenewal => 'Start Renewal (Pause Notifications)';

  @override
  String get completeRenewal => 'Complete Renewal (Stop Notifications)';

  @override
  String get close => 'Close';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusReminding => 'Reminding 🔔';

  @override
  String get statusPaused => 'Paused ⏸️';

  @override
  String get expiryLabel => 'Expiry';

  @override
  String get documentNumberLabel => 'Number';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription => 'Backup all data to JSON file';

  @override
  String get exportDataConfirm => 'Export all data?';

  @override
  String get export => 'Export';

  @override
  String get shareBackupFile => 'Share backup file';

  @override
  String get exportSuccess => 'Export completed successfully';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataDescription => 'Restore data from JSON file';

  @override
  String get importDataWarning =>
      'Warning: Importing will DELETE all existing data. Make sure you have a backup.';

  @override
  String get import => 'Import';

  @override
  String importSuccess(Object documentCount, Object memberCount) {
    return 'Import completed: $memberCount members, $documentCount documents';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get securitySettings => 'Security';

  @override
  String get securitySettingsDescription =>
      'Biometric authentication and privacy settings';

  @override
  String get biometricAuth => 'Lock with Biometrics';

  @override
  String biometricAvailable(String types) {
    return 'Available: $types';
  }

  @override
  String get biometricNextStartup =>
      'Biometric authentication will be required on next startup';

  @override
  String get biometricNotAvailable =>
      'Biometric authentication is not available';

  @override
  String get biometricEnabled => 'Biometric authentication enabled';

  @override
  String get biometricDisabled => 'Biometric authentication disabled';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get biometricRequired => 'Biometric Authentication Required';

  @override
  String get biometricRequiredDescription =>
      'Please authenticate to use the app';

  @override
  String get authenticate => 'Authenticate';

  @override
  String get unlockApp => 'Authentication required to use the app';

  @override
  String get enableBiometricPrompt =>
      'Please authenticate to enable biometric authentication';

  @override
  String get dataBackup => 'Data Backup';

  @override
  String get dataBackupDescription => 'Export and import data';
}
