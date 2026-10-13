// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LifeLens AI';

  @override
  String get appTagline =>
      'Intelligent Document Analysis & Actionable Insights';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get quickDemoMode => 'Quick Demo Mode (Bypass Auth)';

  @override
  String welcomeUser(String name) {
    return 'Hello, $name';
  }

  @override
  String get todayBriefing => 'Daily AI Briefing';

  @override
  String get briefingSubtitle => 'Your top 3 priority actions for today';

  @override
  String get viewFullBriefing => 'View Full Briefing';

  @override
  String get dashboardMetrics => 'Overview';

  @override
  String get overdueTasks => 'Overdue';

  @override
  String get dueTodayTasks => 'Due Today';

  @override
  String get pendingTasks => 'Pending';

  @override
  String get completedTasks => 'Completed';

  @override
  String get analyzeDocumentCTA => 'Scan & Analyze Document';

  @override
  String get recentTasks => 'Recent Tasks';

  @override
  String get viewAllTasks => 'View All';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'My Tasks';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get uploadTitle => 'Upload Document';

  @override
  String get uploadSubtitle => 'Capture photo, pick image/PDF, or paste text';

  @override
  String get tabFile => 'Document / Photo';

  @override
  String get tabPastedText => 'Pasted Text';

  @override
  String get takePhoto => 'Take Photo (Camera)';

  @override
  String get chooseGallery => 'Choose Image';

  @override
  String get chooseFile => 'Pick PDF / Document';

  @override
  String get pasteTextHint =>
      'Paste any notice, bill, letter or handwritten text here...';

  @override
  String get processButton => 'Analyze with LifeLens AI';

  @override
  String get analyzingDoc => 'Analyzing Document...';

  @override
  String get recognizingHandwriting =>
      'Recognizing handwriting and printed text...';

  @override
  String get detectingLanguage => 'Detecting language and extracting tasks...';

  @override
  String get reviewTitle => 'Review & Confirm';

  @override
  String detectedLanguage(String lang) {
    return 'Detected Language: $lang';
  }

  @override
  String get ocrText => 'Extracted Text';

  @override
  String suggestedTasks(int count) {
    return 'Suggested Tasks ($count)';
  }

  @override
  String get sourceEvidence => 'Source Evidence';

  @override
  String get uncertainDateWarning =>
      'Uncertain date detected. Please verify deadline.';

  @override
  String get confirmAndSave => 'Confirm & Save to Tasks';

  @override
  String get saveSuccess => 'Tasks saved successfully!';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityLow => 'Low';

  @override
  String get filterAll => 'All';

  @override
  String get historyTitle => 'Scan History';

  @override
  String get noHistory => 'No previous scans found.';

  @override
  String get deleteScan => 'Delete Scan';

  @override
  String get scanDetail => 'Scan Details';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get selectLanguage => 'Interface Language';

  @override
  String get signOut => 'Sign Out';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी (Hindi)';

  @override
  String get telugu => 'తెలుగు (Telugu)';
}
