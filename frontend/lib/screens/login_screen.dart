import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final authService = context.watch<AuthService>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language selector pills at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.language, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: localeProvider.locale.languageCode,
                          icon: const Icon(Icons.arrow_drop_down, size: 20),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.english, style: const TextStyle(fontSize: 13)),
                            ),
                            DropdownMenuItem(
                              value: 'hi',
                              child: Text(l10n.hindi, style: const TextStyle(fontSize: 13)),
                            ),
                            DropdownMenuItem(
                              value: 'te',
                              child: Text(l10n.telugu, style: const TextStyle(fontSize: 13)),
                            ),
                          ],
                          onChanged: (code) {
                            if (code != null) {
                              localeProvider.setLanguageCode(code);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // App Logo & Badge
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.tertiary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Title & Tagline
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Features Highlights Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(80),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureRow(
                          icon: Icons.document_scanner_outlined,
                          title: 'AI Document & Notice OCR',
                          subtitle: 'Extract text, bills, forms & official notices',
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureRow(
                          icon: Icons.edit_note_rounded,
                          title: 'Handwriting Recognition',
                          subtitle: 'Read handwritten notes & detect uncertain dates',
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureRow(
                          icon: Icons.translate_rounded,
                          title: 'Multilingual Support',
                          subtitle: 'English, हिन्दी (Hindi) & తెలుగు (Telugu)',
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureRow(
                          icon: Icons.auto_awesome,
                          title: 'Daily AI Briefing',
                          subtitle: 'Summarizes deadlines & top 3 action items',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error message if any
                  if (authService.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authService.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sign In with Google Button
                  ElevatedButton(
                    onPressed: authService.isLoading
                        ? null
                        : () async {
                            await authService.signInWithGoogle();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authService.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.g_mobiledata_rounded,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.signInWithGoogle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Demo Mode Button (1-tap bypass for Numa & Judges)
                  OutlinedButton.icon(
                    onPressed: authService.isLoading
                        ? null
                        : () async {
                            await authService.signInWithGoogle();
                          },
                    icon: const Icon(Icons.flash_on_rounded, size: 18),
                    label: Text(l10n.quickDemoMode),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(120),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subtitle / Team Attribution
                  Text(
                    'Built by Numa (Frontend) & Omema (Backend)\nReady for Supabase OAuth & Edge Functions',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
