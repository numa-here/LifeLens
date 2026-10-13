import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LifeLens AI'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Intelligent Document Analysis & Actionable Insights'**
  String get appTagline;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @quickDemoMode.
  ///
  /// In en, this message translates to:
  /// **'Quick Demo Mode (Bypass Auth)'**
  String get quickDemoMode;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String welcomeUser(String name);

  /// No description provided for @todayBriefing.
  ///
  /// In en, this message translates to:
  /// **'Daily AI Briefing'**
  String get todayBriefing;

  /// No description provided for @briefingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your top 3 priority actions for today'**
  String get briefingSubtitle;

  /// No description provided for @viewFullBriefing.
  ///
  /// In en, this message translates to:
  /// **'View Full Briefing'**
  String get viewFullBriefing;

  /// No description provided for @dashboardMetrics.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardMetrics;

  /// No description provided for @overdueTasks.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTasks;

  /// No description provided for @dueTodayTasks.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueTodayTasks;

  /// No description provided for @pendingTasks.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingTasks;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasks;

  /// No description provided for @analyzeDocumentCTA.
  ///
  /// In en, this message translates to:
  /// **'Scan & Analyze Document'**
  String get analyzeDocumentCTA;

  /// No description provided for @recentTasks.
  ///
  /// In en, this message translates to:
  /// **'Recent Tasks'**
  String get recentTasks;

  /// No description provided for @viewAllTasks.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllTasks;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get navTasks;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @uploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadTitle;

  /// No description provided for @uploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture photo, pick image/PDF, or paste text'**
  String get uploadSubtitle;

  /// No description provided for @tabFile.
  ///
  /// In en, this message translates to:
  /// **'Document / Photo'**
  String get tabFile;

  /// No description provided for @tabPastedText.
  ///
  /// In en, this message translates to:
  /// **'Pasted Text'**
  String get tabPastedText;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo (Camera)'**
  String get takePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseGallery;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Pick PDF / Document'**
  String get chooseFile;

  /// No description provided for @pasteTextHint.
  ///
  /// In en, this message translates to:
  /// **'Paste any notice, bill, letter or handwritten text here...'**
  String get pasteTextHint;

  /// No description provided for @processButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze with LifeLens AI'**
  String get processButton;

  /// No description provided for @analyzingDoc.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Document...'**
  String get analyzingDoc;

  /// No description provided for @recognizingHandwriting.
  ///
  /// In en, this message translates to:
  /// **'Recognizing handwriting and printed text...'**
  String get recognizingHandwriting;

  /// No description provided for @detectingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detecting language and extracting tasks...'**
  String get detectingLanguage;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & Confirm'**
  String get reviewTitle;

  /// No description provided for @detectedLanguage.
  ///
  /// In en, this message translates to:
  /// **'Detected Language: {lang}'**
  String detectedLanguage(String lang);

  /// No description provided for @ocrText.
  ///
  /// In en, this message translates to:
  /// **'Extracted Text'**
  String get ocrText;

  /// No description provided for @suggestedTasks.
  ///
  /// In en, this message translates to:
  /// **'Suggested Tasks ({count})'**
  String suggestedTasks(int count);

  /// No description provided for @sourceEvidence.
  ///
  /// In en, this message translates to:
  /// **'Source Evidence'**
  String get sourceEvidence;

  /// No description provided for @uncertainDateWarning.
  ///
  /// In en, this message translates to:
  /// **'Uncertain date detected. Please verify deadline.'**
  String get uncertainDateWarning;

  /// No description provided for @confirmAndSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Save to Tasks'**
  String get confirmAndSave;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tasks saved successfully!'**
  String get saveSuccess;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get historyTitle;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No previous scans found.'**
  String get noHistory;

  /// No description provided for @deleteScan.
  ///
  /// In en, this message translates to:
  /// **'Delete Scan'**
  String get deleteScan;

  /// No description provided for @scanDetail.
  ///
  /// In en, this message translates to:
  /// **'Scan Details'**
  String get scanDetail;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get selectLanguage;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get hindi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు (Telugu)'**
  String get telugu;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
