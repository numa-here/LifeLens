import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'providers/documents_provider.dart';
import 'providers/locale_provider.dart';
import 'repositories/documents_repository.dart';
import 'services/auth_service.dart';
import 'services/prefs_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase. Gracefully runs in Demo Mode if keys are unconfigured;
  // no secrets are ever bundled into the app.
  await SupabaseService.instance.initialize();

  final authService = AuthService();
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  // Ensure prefs are primed for later reads.
  PrefsService.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => localeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => DocumentsProvider(
            DocumentsRepository(auth: authService),
          ),
        ),
      ],
      child: LifeLensApp(),
    ),
  );
}
