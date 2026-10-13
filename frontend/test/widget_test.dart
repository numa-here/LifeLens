import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app.dart';
import 'package:frontend/providers/locale_provider.dart';
import 'package:frontend/providers/task_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('LifeLensApp smoke test builds login screen without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
        ],
        child: const LifeLensApp(),
      ),
    );

    // Verify LifeLens AI title is rendered on Login screen
    expect(find.text('LifeLens AI'), findsWidgets);
  });
}
