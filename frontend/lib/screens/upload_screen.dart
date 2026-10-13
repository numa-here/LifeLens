import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/document_analysis.dart';
import '../services/auth_service.dart';
import '../services/document_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/upload_box.dart';
import 'review_screen.dart';

class UploadScreen extends StatefulWidget {
  final String? initialPastedText;

  const UploadScreen({super.key, this.initialPastedText});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final DocumentService _documentService = DocumentService();
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String? _selectedMimeType;
  bool _isAnalyzing = false;
  String? _analysisError;

  // Realistic sample texts for quick one-tap demonstration
  static const _sampleEnglish = '''MUNICIPAL WATER & PROPERTY NOTICE
Account ID: 8842-TX-2026
Notice Date: 12th Oct 2026
Subject: Urgent Verification of Property Tax and Water Meter Readings.

Action Required:
1. Submit physical declaration form with latest electricity bill photocopy by 24th October 2026.
2. Clear pending assessment charges of \$142.50 before month end (31st Oct 2026).
3. Contact Zonal Officer if discrepancy found in previous receipt #4029.

Note [Handwritten margin]: "Meeting scheduled with inspector on Friday 10 AM? Confirm date."''';

  static const _sampleHindi = '''विश्वविद्यालय परीक्षा विभाग — आवश्यक सूचना
अधिसूचना संख्या: EXAM/2026/894
दिनांक: 10 अक्टूबर 2026

सभी स्नातक एवं स्नातकोत्तर छात्रों को सूचित किया जाता है:
1. सत्र 2026 के अंतिम असाइनमेंट और परियोजना रिपोर्ट 20 अक्टूबर 2026 तक संबंधित विभाग में जमा करें।
2. ऑनलाइन परीक्षा फॉर्म सत्यापन 25 अक्टूबर 2026 से पहले पूरा करें।
3. विलंब शुल्क ₹500 प्रति दिन 25 अक्टूबर के बाद लागू होगा।

हस्तलिखित टिप्पणी: "पुस्तकालय से एनओसी (NOC) प्राप्त करना अनिवार्य है।"''';

  static const _sampleTelugu = '''తెలంగాణ రాష్ట్ర విద్యుత్ పంపిణీ సంస్థ (TSSPDCL)
సర్వీస్ నంబర్: 10482910-NZ
నోటీసు తేదీ: 11 అక్టోబర్ 2026

విషయం: మీటర్ రీడింగ్ ధృవీకరణ మరియు బకాయిల చెల్లింపు.

కీలక చర్యలు:
1. పెండింగ్‌లో ఉన్న రూ. 850 బకాయిలను అక్టోబర్ 22, 2026 లోపు చెల్లించండి.
2. సవరించిన మీటర్ రీడింగ్ స్లిప్‌ను స్థానిక సబ్-స్టేషన్‌లో సమర్పించండి.
3. గడువు ముగిసిన తర్వాత విద్యుత్ సరఫరా తాత్కాలికంగా నిలిపివేయబడుతుంది.

గమనిక: "ఆఫీస్ సమయం: ఉదయం 10:30 నుండి సాయంత్రం 4:30 వరకు."''';

  static const _sampleHandwritten = '''[Handwritten Clinic & Health Note]
Dr. K. S. Rao, MD — Health Clinic
Date: 12/10/26

Patient Follow-up & Lab Orders:
- Repeat Fasting Blood Sugar and Lipid profile after 5 days.
- Bring previous ECG report from Apollo hospital.
- Book Cardiology consultation on next Tuesday morning (10:30 AM?).
- Collect prescribed medication refill before Sunday.

Urgent: Report to clinic immediately if chest discomfort recurs.''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialPastedText != null) {
      _textController.text = widget.initialPastedText!;
      _tabController.index = 1; // Open Pasted Text tab
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickCamera() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedFileName = photo.name;
          _selectedFileBytes = bytes;
          _selectedMimeType = 'image/jpeg';
          _analysisError = null;
        });
      }
    } catch (_) {
      // Fallback for desktop/emulator where camera is unavailable
      _useSampleMockFile('camera_photo_notice.jpg');
    }
  }

  Future<void> _pickGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedFileName = image.name;
          _selectedFileBytes = bytes;
          _selectedMimeType = 'image/jpeg';
          _analysisError = null;
        });
      }
    } catch (_) {
      _useSampleMockFile('gallery_document.jpg');
    }
  }

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = file.bytes;
          _selectedMimeType = file.extension == 'pdf'
              ? 'application/pdf'
              : 'image/jpeg';
          _analysisError = null;
        });
      }
    } catch (_) {
      _useSampleMockFile('property_tax_notice.pdf');
    }
  }

  void _useSampleMockFile(String name) {
    setState(() {
      _selectedFileName = name;
      _selectedFileBytes = Uint8List.fromList([1, 2, 3, 4]);
      _selectedMimeType = 'image/jpeg';
      _analysisError = null;
    });
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFileName = null;
      _selectedFileBytes = null;
      _selectedMimeType = null;
    });
  }

  Future<void> _analyzeDocument() async {
    final isPastedTab = _tabController.index == 1;
    final textInput = _textController.text.trim();

    if (isPastedTab && textInput.isEmpty) {
      setState(() => _analysisError = 'Please paste some document text first.');
      return;
    }
    if (!isPastedTab && _selectedFileName == null && _selectedFileBytes == null) {
      setState(() => _analysisError = 'Please select a photo, image or document file.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    final user = context.read<AuthService>().currentUser;
    final userId = user?.id ?? 'demo-user-123';

    try {
      final DocumentAnalysisResult result = await _documentService.analyzeDocument(
        text: isPastedTab ? textInput : null,
        fileBytes: isPastedTab ? null : _selectedFileBytes,
        fileName: isPastedTab ? 'pasted_text.txt' : _selectedFileName,
        mimeType: _selectedMimeType,
        userId: userId,
      );

      if (mounted) {
        setState(() => _isAnalyzing = false);

        // Navigate to review screen
        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewScreen(
              initialResult: result,
              originalImageName: _selectedFileName,
            ),
          ),
        );

        if (saved == true && mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisError = 'Analysis error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.uploadTitle)),
        body: const Center(
          child: LoadingIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.image_outlined), text: l10n.tabFile),
            Tab(icon: const Icon(Icons.text_snippet_outlined), text: l10n.tabPastedText),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner if any
            if (_analysisError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _analysisError!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tab View Contents
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: Document / Photo Upload
                  Column(
                    children: [
                      UploadBox(
                        selectedFileName: _selectedFileName,
                        onCameraTap: _pickCamera,
                        onGalleryTap: _pickGallery,
                        onFileTap: _pickDocumentFile,
                        onClear: _clearSelectedFile,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Supports JPG, PNG photos, camera scans & PDF notices',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  // TAB 2: Pasted Text Input with Sample Prompts
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: l10n.pasteTextHint,
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quick Sample Documents (Tap to try):',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ActionChip(
                            label: const Text('Utility Notice (EN)', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.receipt_long, size: 14),
                            onPressed: () => setState(() => _textController.text = _sampleEnglish),
                          ),
                          ActionChip(
                            label: const Text('विश्वविद्यालय (HI)', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.school, size: 14),
                            onPressed: () => setState(() => _textController.text = _sampleHindi),
                          ),
                          ActionChip(
                            label: const Text('విద్యుత్ బిల్లు (TE)', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.bolt, size: 14),
                            onPressed: () => setState(() => _textController.text = _sampleTelugu),
                          ),
                          ActionChip(
                            label: const Text('Clinic Note (Handwritten)', style: TextStyle(fontSize: 11)),
                            avatar: const Icon(Icons.edit_note, size: 14),
                            onPressed: () => setState(() => _textController.text = _sampleHandwritten),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Analyze CTA Button
            ElevatedButton(
              onPressed: _analyzeDocument,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.processButton,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Note on AI & Omema Backend
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI model detects English, Hindi & Telugu text, recognizes handwriting, and extracts deadlines.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
