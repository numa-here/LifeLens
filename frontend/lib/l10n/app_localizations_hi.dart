// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'LifeLens AI';

  @override
  String get appTagline => 'दस्तावेज़ विश्लेषण और कार्रवाई योग्य कार्य';

  @override
  String get signInWithGoogle => 'Google से साइन इन करें';

  @override
  String get quickDemoMode => 'त्वरित डेमो मोड';

  @override
  String welcomeUser(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get todayBriefing => 'दैनिक AI ब्रीफिंग';

  @override
  String get briefingSubtitle => 'आज के लिए आपकी शीर्ष 3 प्राथमिकताएं';

  @override
  String get viewFullBriefing => 'पूरी ब्रीफिंग देखें';

  @override
  String get dashboardMetrics => 'अवलोकन';

  @override
  String get overdueTasks => 'अतिदेय';

  @override
  String get dueTodayTasks => 'आज देय';

  @override
  String get pendingTasks => 'लंबित';

  @override
  String get completedTasks => 'पूर्ण';

  @override
  String get analyzeDocumentCTA => 'दस्तावेज़ स्कैन और विश्लेषण करें';

  @override
  String get recentTasks => 'हाल के कार्य';

  @override
  String get viewAllTasks => 'सभी देखें';

  @override
  String get navHome => 'होम';

  @override
  String get navTasks => 'मेरे कार्य';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navSettings => 'सेटिंग्स';

  @override
  String get uploadTitle => 'दस्तावेज़ अपलोड करें';

  @override
  String get uploadSubtitle =>
      'फोटो लें, इमेज/PDF चुनें, या टेक्स्ट पेस्ट करें';

  @override
  String get tabFile => 'दस्तावेज़ / फोटो';

  @override
  String get tabPastedText => 'पेस्ट किया गया टेक्स्ट';

  @override
  String get takePhoto => 'फोटो लें (कैमरा)';

  @override
  String get chooseGallery => 'गैलरी से चुनें';

  @override
  String get chooseFile => 'PDF / दस्तावेज़ चुनें';

  @override
  String get pasteTextHint =>
      'कोई भी नोटिस, बिल, पत्र या हस्तलिखित टेक्स्ट यहाँ पेस्ट करें...';

  @override
  String get processButton => 'LifeLens AI से विश्लेषण करें';

  @override
  String get analyzingDoc => 'दस्तावेज़ का विश्लेषण हो रहा है...';

  @override
  String get recognizingHandwriting =>
      'हस्तलेखन और मुद्रित पाठ की पहचान हो रही है...';

  @override
  String get detectingLanguage => 'भाषा की पहचान और कार्य निकाले जा रहे हैं...';

  @override
  String get reviewTitle => 'समीक्षा और पुष्टि करें';

  @override
  String detectedLanguage(String lang) {
    return 'पहचानी गई भाषा: $lang';
  }

  @override
  String get ocrText => 'निकाला गया टेक्स्ट';

  @override
  String suggestedTasks(int count) {
    return 'सुझाए गए कार्य ($count)';
  }

  @override
  String get sourceEvidence => 'स्रोत साक्ष्य';

  @override
  String get uncertainDateWarning =>
      'अनिश्चित तिथि का पता चला। कृपया समय सीमा सत्यापित करें।';

  @override
  String get confirmAndSave => 'पुष्टि करें और कार्यों में सहेजें';

  @override
  String get saveSuccess => 'कार्य सफलतापूर्वक सहेजे गए!';

  @override
  String get priorityUrgent => 'अत्यावश्यक';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'निम्न';

  @override
  String get filterAll => 'सभी';

  @override
  String get historyTitle => 'स्कैन इतिहास';

  @override
  String get noHistory => 'कोई पिछला स्कैन नहीं मिला।';

  @override
  String get deleteScan => 'स्कैन हटाएं';

  @override
  String get scanDetail => 'स्कैन विवरण';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get selectLanguage => 'इंटरफ़ेस भाषा';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी (Hindi)';

  @override
  String get telugu => 'తెలుగు (Telugu)';
}
