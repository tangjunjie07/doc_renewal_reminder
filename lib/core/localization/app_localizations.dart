import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Renewal Reminder'**
  String get appTitle;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// No description provided for @noFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No family members yet'**
  String get noFamilyMembers;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocuments;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get editMember;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveAndAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Document'**
  String get saveAndAddDocument;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Another'**
  String get saveAndAddAnother;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @self.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self;

  /// No description provided for @spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @sibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get sibling;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this member?'**
  String get deleteMemberMessage;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadMembersFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load members'**
  String get loadMembersFailed;

  /// No description provided for @deleteMember.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get deleteMember;

  /// No description provided for @deleteAllDocuments.
  ///
  /// In en, this message translates to:
  /// **'Delete All Documents'**
  String get deleteAllDocuments;

  /// No description provided for @noDocumentsToDelete.
  ///
  /// In en, this message translates to:
  /// **'No documents to delete'**
  String get noDocumentsToDelete;

  /// No description provided for @deleteAllDocumentsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} document(s) for {name}?\n\nThis action cannot be undone.'**
  String deleteAllDocumentsConfirm(String name, String count);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @documentsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} document(s) for {name}'**
  String documentsDeleted(String name, String count);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed'**
  String get deleteFailed;

  /// No description provided for @deleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?\n\n* You must delete all documents first.'**
  String deleteMemberConfirm(String name);

  /// No description provided for @memberDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String memberDeleted(String name);

  /// No description provided for @noFamilyMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No family members yet'**
  String get noFamilyMembersYet;

  /// No description provided for @noFamilyMembersDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your first member using the button below\nStart managing your documents'**
  String get noFamilyMembersDesc;

  /// No description provided for @addFirstMember.
  ///
  /// In en, this message translates to:
  /// **'Add First Member'**
  String get addFirstMember;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteDocumentsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete all documents'**
  String get deleteDocumentsTooltip;

  /// No description provided for @deleteMemberTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete member'**
  String get deleteMemberTooltip;

  /// No description provided for @documentCount.
  ///
  /// In en, this message translates to:
  /// **'Documents: {count}'**
  String documentCount(String count);

  /// No description provided for @allDocuments.
  ///
  /// In en, this message translates to:
  /// **'All Documents'**
  String get allDocuments;

  /// No description provided for @documentItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String documentItemCount(String count);

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @filterSelfOnly.
  ///
  /// In en, this message translates to:
  /// **'My Only'**
  String get filterSelfOnly;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get filterAll;

  /// No description provided for @addDocumentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocumentButton;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @noOwnDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any documents yet'**
  String get noOwnDocumentsYet;

  /// No description provided for @addFirstDocument.
  ///
  /// In en, this message translates to:
  /// **'Add First Document'**
  String get addFirstDocument;

  /// No description provided for @noDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add documents using the button below\nNever worry about expiration dates again'**
  String get noDocumentsDesc;

  /// No description provided for @loadDocumentsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load documents'**
  String get loadDocumentsFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addNewMember.
  ///
  /// In en, this message translates to:
  /// **'Add new member'**
  String get addNewMember;

  /// No description provided for @selectMember.
  ///
  /// In en, this message translates to:
  /// **'Select Member'**
  String get selectMember;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @addFirstMemberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add your first member\nusing the button below'**
  String get addFirstMemberPrompt;

  /// No description provided for @notificationTitleRenewalNeeded.
  ///
  /// In en, this message translates to:
  /// **'Document Renewal Needed'**
  String notificationTitleRenewalNeeded(Object documentType);

  /// No description provided for @notificationBodyRenewalNeeded.
  ///
  /// In en, this message translates to:
  /// **'{memberName}\'s {documentType} will expire in {days} days'**
  String notificationBodyRenewalNeeded(
      Object days, Object documentType, Object memberName);

  /// No description provided for @notificationBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your document is approaching its expiration date. Please check.'**
  String get notificationBodyGeneric;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionStatusChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking status…'**
  String get notificationPermissionStatusChecking;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationPermissionDialogTitle;

  /// No description provided for @notificationPermissionDialogContent.
  ///
  /// In en, this message translates to:
  /// **'To receive renewal reminders we need notification permission. Allow?'**
  String get notificationPermissionDialogContent;

  /// No description provided for @notificationPermissionLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get notificationPermissionLater;

  /// No description provided for @notificationPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notificationPermissionAllow;

  /// No description provided for @notificationPermissionDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationPermissionDisabledTitle;

  /// No description provided for @notificationPermissionDisabledContent.
  ///
  /// In en, this message translates to:
  /// **'Please enable notifications in system settings. Open settings?'**
  String get notificationPermissionDisabledContent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @notificationAlreadyGranted.
  ///
  /// In en, this message translates to:
  /// **'Notifications are already allowed'**
  String get notificationAlreadyGranted;

  /// No description provided for @documentTypeResidenceCard.
  ///
  /// In en, this message translates to:
  /// **'Residence Card'**
  String get documentTypeResidenceCard;

  /// No description provided for @documentTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get documentTypePassport;

  /// No description provided for @documentTypeDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get documentTypeDriversLicense;

  /// No description provided for @documentTypeHealthInsurance.
  ///
  /// In en, this message translates to:
  /// **'Health Insurance Card'**
  String get documentTypeHealthInsurance;

  /// No description provided for @documentTypeMyNumber.
  ///
  /// In en, this message translates to:
  /// **'My Number Card'**
  String get documentTypeMyNumber;

  /// No description provided for @documentTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other Document'**
  String get documentTypeOther;

  /// No description provided for @reminderFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reminderFrequencyDaily;

  /// No description provided for @reminderFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reminderFrequencyWeekly;

  /// No description provided for @reminderFrequencyBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get reminderFrequencyBiweekly;

  /// No description provided for @reminderFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reminderFrequencyMonthly;

  /// No description provided for @policyNotesResidenceCard.
  ///
  /// In en, this message translates to:
  /// **'Renewal application at immigration office is available 3 months before expiration'**
  String get policyNotesResidenceCard;

  /// No description provided for @policyNotesPassport.
  ///
  /// In en, this message translates to:
  /// **'Application to receipt takes about 1 week. Apply early if you have overseas travel plans'**
  String get policyNotesPassport;

  /// No description provided for @policyNotesDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Renewal period is 1 month before and after your birthday'**
  String get policyNotesDriversLicense;

  /// No description provided for @policyNotesInsuranceCard.
  ///
  /// In en, this message translates to:
  /// **'Usually renewed automatically. If you don\'t receive a new card, contact your employer or insurer'**
  String get policyNotesInsuranceCard;

  /// No description provided for @policyNotesMynumberCard.
  ///
  /// In en, this message translates to:
  /// **'Renewal procedures can be done at municipal offices 3 months before expiration'**
  String get policyNotesMynumberCard;

  /// No description provided for @policyNotesOther.
  ///
  /// In en, this message translates to:
  /// **'Please check with the issuer for renewal details'**
  String get policyNotesOther;

  /// No description provided for @policyValidationMinDays.
  ///
  /// In en, this message translates to:
  /// **'Reminder period must be at least 1 day'**
  String get policyValidationMinDays;

  /// No description provided for @policyValidationMaxDays.
  ///
  /// In en, this message translates to:
  /// **'Reminder period must be within 365 days'**
  String get policyValidationMaxDays;

  /// No description provided for @policyDescriptionTemplate.
  ///
  /// In en, this message translates to:
  /// **'Notify {frequency} starting {days} days before expiry'**
  String policyDescriptionTemplate(Object days, Object frequency);

  /// No description provided for @errorDatabaseOperation.
  ///
  /// In en, this message translates to:
  /// **'Database operation failed'**
  String get errorDatabaseOperation;

  /// No description provided for @errorDocumentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get errorDocumentNotFound;

  /// No description provided for @errorNotificationScheduling.
  ///
  /// In en, this message translates to:
  /// **'Failed to schedule notification'**
  String get errorNotificationScheduling;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get addDocument;

  /// No description provided for @editDocument.
  ///
  /// In en, this message translates to:
  /// **'Edit Document'**
  String get editDocument;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @documentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get documentNumber;

  /// No description provided for @documentNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Document Number (Optional)'**
  String get documentNumberOptional;

  /// No description provided for @securityNotRequired.
  ///
  /// In en, this message translates to:
  /// **'For security, input is not required'**
  String get securityNotRequired;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addingDocument.
  ///
  /// In en, this message translates to:
  /// **'Adding document...'**
  String get addingDocument;

  /// No description provided for @updatingDocument.
  ///
  /// In en, this message translates to:
  /// **'Updating document...'**
  String get updatingDocument;

  /// No description provided for @documentAdded.
  ///
  /// In en, this message translates to:
  /// **'Document added'**
  String get documentAdded;

  /// No description provided for @documentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Document updated'**
  String get documentUpdated;

  /// No description provided for @pleaseSelectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Please select expiry date'**
  String get pleaseSelectExpiryDate;

  /// No description provided for @dateToSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get dateToSelect;

  /// No description provided for @selectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected Date'**
  String get selectedDate;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @reminderPeriodQuestion.
  ///
  /// In en, this message translates to:
  /// **'How far in advance would you like to receive notifications?'**
  String get reminderPeriodQuestion;

  /// No description provided for @oneMonthBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Month Before'**
  String get oneMonthBefore;

  /// No description provided for @threeMonthsBefore.
  ///
  /// In en, this message translates to:
  /// **'3 Months Before'**
  String get threeMonthsBefore;

  /// No description provided for @sixMonthsBefore.
  ///
  /// In en, this message translates to:
  /// **'6 Months Before'**
  String get sixMonthsBefore;

  /// No description provided for @oneYearBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Year Before'**
  String get oneYearBefore;

  /// No description provided for @reminderExample.
  ///
  /// In en, this message translates to:
  /// **'Notes for renewal process, etc.'**
  String get reminderExample;

  /// No description provided for @birthdayOptional.
  ///
  /// In en, this message translates to:
  /// **'Birthday (Optional)'**
  String get birthdayOptional;

  /// No description provided for @birthdayUsageHint.
  ///
  /// In en, this message translates to:
  /// **'Birthday is used for age calculation, etc.\nYou can add or change it later.'**
  String get birthdayUsageHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameExample.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get nameExample;

  /// No description provided for @relationshipType.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationshipType;

  /// No description provided for @memberInfoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member information updated'**
  String get memberInfoUpdated;

  /// No description provided for @memberAdded.
  ///
  /// In en, this message translates to:
  /// **'Member added'**
  String get memberAdded;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @addingMember.
  ///
  /// In en, this message translates to:
  /// **'Adding member...'**
  String get addingMember;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @selectBirthdayOptional.
  ///
  /// In en, this message translates to:
  /// **'Select birthday (Optional)'**
  String get selectBirthdayOptional;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @documentsFor.
  ///
  /// In en, this message translates to:
  /// **'Documents for {name}'**
  String documentsFor(Object name);

  /// No description provided for @documentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String documentsCount(Object count);

  /// No description provided for @loadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingDocuments;

  /// No description provided for @deleteDocument.
  ///
  /// In en, this message translates to:
  /// **'Delete Document'**
  String get deleteDocument;

  /// No description provided for @deleteDocumentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {documentType}?\n\nThis action cannot be undone.'**
  String deleteDocumentConfirm(Object documentType);

  /// No description provided for @deleteDocumentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this document?\n\nThis action cannot be undone.'**
  String get deleteDocumentConfirmation;

  /// No description provided for @documentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {documentType}'**
  String documentDeleted(Object documentType);

  /// No description provided for @documentsNotYetFor.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get documentsNotYetFor;

  /// No description provided for @addDocumentsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add documents for {name}\nNo more worries about expiration'**
  String addDocumentsPrompt(Object name);

  /// No description provided for @worryFreeExpiry.
  ///
  /// In en, this message translates to:
  /// **'No more worries about expiration'**
  String get worryFreeExpiry;

  /// No description provided for @documentAdding.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get documentAdding;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired ({days} days ago)'**
  String expired(Object days);

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'{days} days until expiration'**
  String expiringSoon(Object days);

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(Object days);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemaining;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry: {date}'**
  String expiryDateLabel(Object date);

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year}'**
  String dateFormat(Object day, Object month, Object year);

  /// No description provided for @numberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number: {number}'**
  String numberLabel(Object number);

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language / 语言 / 言語'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @notificationList.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationList;

  /// No description provided for @viewScheduledNotifications.
  ///
  /// In en, this message translates to:
  /// **'View scheduled notifications'**
  String get viewScheduledNotifications;

  /// No description provided for @noScheduledNotifications.
  ///
  /// In en, this message translates to:
  /// **'No scheduled notifications'**
  String get noScheduledNotifications;

  /// No description provided for @noScheduledNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications will be scheduled when you add documents'**
  String get noScheduledNotificationsDesc;

  /// No description provided for @cancelNotification.
  ///
  /// In en, this message translates to:
  /// **'Cancel Notification'**
  String get cancelNotification;

  /// No description provided for @cancelAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Cancel All'**
  String get cancelAllNotifications;

  /// No description provided for @cancelAllNotificationsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel all notifications? This action cannot be undone.'**
  String get cancelAllNotificationsConfirmation;

  /// No description provided for @allNotificationsCancelled.
  ///
  /// In en, this message translates to:
  /// **'All notifications cancelled'**
  String get allNotificationsCancelled;

  /// No description provided for @cancelNotificationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Cancel this notification?'**
  String get cancelNotificationConfirmation;

  /// No description provided for @notificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Notification cancelled'**
  String get notificationCancelled;

  /// No description provided for @notificationId.
  ///
  /// In en, this message translates to:
  /// **'Notification ID'**
  String get notificationId;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No Title'**
  String get noTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @failedToCancelNotification.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel notification'**
  String get failedToCancelNotification;

  /// No description provided for @reminderStartDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder Start Date'**
  String get reminderStartDate;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// No description provided for @addedToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Added to calendar'**
  String get addedToCalendar;

  /// No description provided for @failedToAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Failed to add to calendar'**
  String get failedToAddToCalendar;

  /// No description provided for @syncToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync to Calendar'**
  String get syncToCalendar;

  /// No description provided for @syncToCalendarDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically add reminder to calendar when saving'**
  String get syncToCalendarDescription;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @notificationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Notification Frequency'**
  String get notificationFrequency;

  /// No description provided for @databaseDebug.
  ///
  /// In en, this message translates to:
  /// **'Database Debug'**
  String get databaseDebug;

  /// No description provided for @viewDatabaseStatus.
  ///
  /// In en, this message translates to:
  /// **'View database status and data'**
  String get viewDatabaseStatus;

  /// No description provided for @residenceCard.
  ///
  /// In en, this message translates to:
  /// **'Residence Card'**
  String get residenceCard;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @driversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get driversLicense;

  /// No description provided for @insuranceCard.
  ///
  /// In en, this message translates to:
  /// **'Insurance Card'**
  String get insuranceCard;

  /// No description provided for @mynumberCard.
  ///
  /// In en, this message translates to:
  /// **'My Number Card'**
  String get mynumberCard;

  /// No description provided for @otherDocument.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherDocument;

  /// No description provided for @confirmRenewalStart.
  ///
  /// In en, this message translates to:
  /// **'Confirm Renewal Start'**
  String get confirmRenewalStart;

  /// No description provided for @renewalStartDescription.
  ///
  /// In en, this message translates to:
  /// **'Start renewal process for this document?\nNotifications will be temporarily paused.'**
  String get renewalStartDescription;

  /// No description provided for @renewalStarted.
  ///
  /// In en, this message translates to:
  /// **'✅ Renewal started. Notifications paused.'**
  String get renewalStarted;

  /// No description provided for @confirmRenewalComplete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Renewal Complete'**
  String get confirmRenewalComplete;

  /// No description provided for @renewalCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Is the renewal for this document complete?\nNotifications will be stopped.'**
  String get renewalCompleteDescription;

  /// No description provided for @renewalCompleted.
  ///
  /// In en, this message translates to:
  /// **'✅ Renewal complete! Notifications stopped.'**
  String get renewalCompleted;

  /// No description provided for @notificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notification Status'**
  String get notificationStatus;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @startRenewal.
  ///
  /// In en, this message translates to:
  /// **'Start Renewal (Pause Notifications)'**
  String get startRenewal;

  /// No description provided for @completeRenewal.
  ///
  /// In en, this message translates to:
  /// **'Complete Renewal (Stop Notifications)'**
  String get completeRenewal;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusReminding.
  ///
  /// In en, this message translates to:
  /// **'Reminding 🔔'**
  String get statusReminding;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused ⏸️'**
  String get statusPaused;

  /// No description provided for @expiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiryLabel;

  /// No description provided for @documentNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get documentNumberLabel;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Backup all data to JSON file'**
  String get exportDataDescription;

  /// No description provided for @exportDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Export all data?'**
  String get exportDataConfirm;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @shareBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Share backup file'**
  String get shareBackupFile;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully'**
  String get exportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore data from JSON file'**
  String get importDataDescription;

  /// No description provided for @importDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Importing will DELETE all existing data. Make sure you have a backup.'**
  String get importDataWarning;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import completed: {memberCount} members, {documentCount} documents'**
  String importSuccess(Object documentCount, Object memberCount);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySettings;

  /// No description provided for @securitySettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication and privacy settings'**
  String get securitySettingsDescription;

  /// No description provided for @biometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Lock with Biometrics'**
  String get biometricAuth;

  /// No description provided for @biometricAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available: {types}'**
  String biometricAvailable(String types);

  /// No description provided for @biometricNextStartup.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication will be required on next startup'**
  String get biometricNextStartup;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available'**
  String get biometricNotAvailable;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled'**
  String get biometricDisabled;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @biometricRequired.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication Required'**
  String get biometricRequired;

  /// No description provided for @biometricRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to use the app'**
  String get biometricRequiredDescription;

  /// No description provided for @authenticate.
  ///
  /// In en, this message translates to:
  /// **'Authenticate'**
  String get authenticate;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to use the app'**
  String get unlockApp;

  /// No description provided for @enableBiometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to enable biometric authentication'**
  String get enableBiometricPrompt;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data Backup'**
  String get dataBackup;

  /// No description provided for @dataBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export and import data'**
  String get dataBackupDescription;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportTitle;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'For questions or feedback, please contact us below.'**
  String get supportDescription;

  /// No description provided for @supportDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You can send feedback via GitHub or email. All messages will reach the developer.'**
  String get supportDialogContent;

  /// No description provided for @githubButton.
  ///
  /// In en, this message translates to:
  /// **'Feedback on GitHub'**
  String get githubButton;

  /// No description provided for @mailButton.
  ///
  /// In en, this message translates to:
  /// **'Contact by Email'**
  String get mailButton;

  /// No description provided for @supportMailSubject.
  ///
  /// In en, this message translates to:
  /// **'[App Inquiry]'**
  String get supportMailSubject;

  /// No description provided for @supportMailBody.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback or request.'**
  String get supportMailBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
