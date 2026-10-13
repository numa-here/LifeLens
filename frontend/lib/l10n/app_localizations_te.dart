// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'LifeLens AI';

  @override
  String get appTagline => 'డాక్యుమెంట్ విశ్లేషణ మరియు కార్యాచరణ అంతర్దృష్టులు';

  @override
  String get signInWithGoogle => 'Googleతో సైన్ ఇన్ చేయండి';

  @override
  String get quickDemoMode => 'డెమో మోడ్ (త్వరిత ప్రవేశం)';

  @override
  String welcomeUser(String name) {
    return 'నమస్కారం, $name';
  }

  @override
  String get todayBriefing => 'రోజువారీ AI బ్రీఫింగ్';

  @override
  String get briefingSubtitle => 'నేటి మీ అగ్ర 3 ప్రాధాన్యత చర్యలు';

  @override
  String get viewFullBriefing => 'పూర్తి బ్రీఫింగ్ చూడండి';

  @override
  String get dashboardMetrics => 'సమీక్ష';

  @override
  String get overdueTasks => 'గడువు ముగిసినవి';

  @override
  String get dueTodayTasks => 'నేడు గడువు ఉన్నవి';

  @override
  String get pendingTasks => 'పెండింగ్‌లో ఉన్నవి';

  @override
  String get completedTasks => 'పూర్తయినవి';

  @override
  String get analyzeDocumentCTA => 'పత్రం స్కాన్ & విశ్లేషించండి';

  @override
  String get recentTasks => 'ఇటీవలి పనులు';

  @override
  String get viewAllTasks => 'అన్నీ చూడండి';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navTasks => 'నా పనులు';

  @override
  String get navHistory => 'చరిత్ర';

  @override
  String get navSettings => 'సెట్టింగ్‌లు';

  @override
  String get uploadTitle => 'పత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get uploadSubtitle =>
      'ఫోటో తీయండి, చిత్రం/PDF ఎంచుకోండి, లేదా వచనాన్ని అతికించండి';

  @override
  String get tabFile => 'పత్రం / ఫోటో';

  @override
  String get tabPastedText => 'అతికించిన వచనం';

  @override
  String get takePhoto => 'ఫోటో తీయండి (కెమెరా)';

  @override
  String get chooseGallery => 'చిత్రం ఎంచుకోండి';

  @override
  String get chooseFile => 'PDF / పత్రం ఎంచుకోండి';

  @override
  String get pasteTextHint =>
      'నోటీసు, బిల్లు, లేఖ లేదా చేతివ్రాత వచనాన్ని ఇక్కడ అతికించండి...';

  @override
  String get processButton => 'LifeLens AIతో విశ్లేషించండి';

  @override
  String get analyzingDoc => 'పత్రం విశ్లేషించబడుతోంది...';

  @override
  String get recognizingHandwriting =>
      'చేతివ్రాత మరియు ముద్రిత వచనాన్ని గుర్తిస్తోంది...';

  @override
  String get detectingLanguage => 'భాష గుర్తింపు & పనుల విభజన జరుగుతోంది...';

  @override
  String get reviewTitle => 'సమీక్షించి నిర్ధారించండి';

  @override
  String detectedLanguage(String lang) {
    return 'గుర్తించిన భాష: $lang';
  }

  @override
  String get ocrText => 'వెలికితీసిన వచనం';

  @override
  String suggestedTasks(int count) {
    return 'సూచించిన పనులు ($count)';
  }

  @override
  String get sourceEvidence => 'మూల ఆధారాలు';

  @override
  String get uncertainDateWarning =>
      'అనిశ్చిత తేదీ గుర్తించబడింది. దయచేసి గడువును సరిచూడండి.';

  @override
  String get confirmAndSave => 'నిర్ధారించి పనులలో భద్రపరచండి';

  @override
  String get saveSuccess => 'పనులు విజయవంతంగా భద్రపరచబడ్డాయి!';

  @override
  String get priorityUrgent => 'అత్యవసరం';

  @override
  String get priorityHigh => 'అధిక';

  @override
  String get priorityMedium => 'మధ్యస్థం';

  @override
  String get priorityLow => 'తక్కువ';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get historyTitle => 'స్కాన్ చరిత్ర';

  @override
  String get noHistory => 'మునుపటి స్కాన్లు ఏవీ కనుగొనబడలేదు.';

  @override
  String get deleteScan => 'స్కాన్ తొలగించు';

  @override
  String get scanDetail => 'స్కాన్ వివరాలు';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get selectLanguage => 'యాప్ భాష';

  @override
  String get signOut => 'సైన్ అవుట్';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी (Hindi)';

  @override
  String get telugu => 'తెలుగు (Telugu)';
}
