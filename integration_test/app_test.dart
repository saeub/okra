import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localstorage/localstorage.dart';
import 'package:okra/main.dart' as app;
import 'package:okra/src/data/storage.dart';

import 'mock.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  mockApiClient();

  setUp(() async {
    // Clear local storage
    var storage = LocalStorage(Storage.storageName);
    var ready = await storage.ready;
    expect(ready, true);
    await storage.clear();
  });

  group('API registration', () {
    var findApiUrl = find.widgetWithText(TextField, 'API URL');
    var findParticipantId = find.widgetWithText(TextField, 'Participant ID');
    var findRegistrationKey = find.widgetWithText(TextField, 'Registration key');

    testWidgets('allows adding and removing APIs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add API'));
      await tester.pumpAndSettle();
      await tester.enterText(findApiUrl, 'https://mock.api');
      await tester.enterText(findParticipantId, 'mock_participant');
      await tester.enterText(findRegistrationKey, 'mock_key');
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Mock API (https://mock.api)'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete API'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('YES'));
      await tester.pumpAndSettle();
      expect(find.text('Mock API (https://mock.api)'), findsNothing);
    });

    testWidgets('rejects invalid URL', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add API'));
      await tester.pumpAndSettle();
      await tester.enterText(findApiUrl, '::not a url::');
      await tester.enterText(findParticipantId, 'foo');
      await tester.enterText(findRegistrationKey, 'bar');
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid URL'), findsOneWidget);
    });

    testWidgets('rejects invalid participant credentials',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add API'));
      await tester.pumpAndSettle();
      await tester.enterText(findApiUrl, 'https://mock.api');
      await tester.enterText(findParticipantId, 'invalid_participant');
      await tester.enterText(findRegistrationKey, 'invalid_key');
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid participant ID or key'), findsOneWidget);
    });
  });

  group('Task', () {
    Future<void> registerApi(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add API'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'API URL'), 'https://mock.api');
      await tester.enterText(find.widgetWithText(TextField, 'Participant ID'), 'mock_participant');
      await tester.enterText(find.widgetWithText(TextField, 'Registration key'), 'mock_key');
      await tester.ensureVisible(find.text('OK'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows up in list', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await registerApi(tester);
      expect(find.text('Mock API'), findsOneWidget);
      expect(find.text('Mock experiment'), findsOneWidget);
      expect(find.text('2 tasks left'), findsOneWidget);
    });

    testWidgets('can be completed', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await registerApi(tester);
      await tester.tap(find.widgetWithText(Card, 'Mock experiment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('START TASK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('This is an '), findsOneWidget);
      await tester.tap(find.text('example'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('NEXT TASK'), findsOneWidget);
      await tester.tap(find.text('LATER'));
      await tester.pumpAndSettle();
      expect(find.text('Mock experiment'), findsOneWidget);
    });
  });
}
