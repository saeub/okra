import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

SerializableFinder findTextAncestor(String text, String type) {
  return find.ancestor(of: find.text(text), matching: find.byType(type));
}

void main() {
  group('API registration', () {
    late FlutterDriver driver;

    var findApiUrl = findTextAncestor('API URL', 'TextField');
    var findParticipantId = findTextAncestor('Participant ID', 'TextField');
    var findRegistrationKey = findTextAncestor('Registration key', 'TextField');

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('rejects invalid URL', () async {
      await driver.tap(find.byTooltip('Settings'));
      await driver.tap(find.text('Add API'));
      await driver.tap(findApiUrl);
      await driver.enterText('this is not a url');
      await driver.tap(findParticipantId);
      await driver.enterText('foo');
      await driver.tap(findRegistrationKey);
      await driver.enterText('bar');
      await driver.tap(find.text('OK'));
      await driver.waitFor(find.text('Invalid URL'));
      await driver.tap(find.byTooltip('Back'));
    });

    test('rejects invalid participant credentials', () async {
      await driver.tap(find.text('Add API'));
      await driver.tap(findApiUrl);
      await driver.enterText('https://mock.api');
      await driver.tap(findParticipantId);
      await driver.enterText('invalid_participant');
      await driver.tap(findRegistrationKey);
      await driver.enterText('invalid_key');
      await driver.tap(find.text('OK'));
      await driver.waitFor(find.text('Invalid participant ID or key'));
      await driver.tap(find.byTooltip('Back'));
    });

    test('accepts valid credentials', () async {
      await driver.tap(find.text('Add API'));
      await driver.tap(findApiUrl);
      await driver.enterText('https://mock.api');
      await driver.tap(findParticipantId);
      await driver.enterText('mock_participant');
      await driver.tap(findRegistrationKey);
      await driver.enterText('mock_key');
      await driver.tap(find.text('OK'));
      await driver.waitFor(find.text('Mock API (https://mock.api)'));
      await driver.tap(find.byTooltip('Delete API'));
      await driver.tap(find.text('YES'));
      await driver.tap(find.byTooltip('Back'));
    });
  });

  group('Task', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('shows up in list', () async {
      await driver.tap(find.byTooltip('Settings'));
      await driver.tap(find.text('Add API'));
      await driver.tap(findTextAncestor('API URL', 'TextField'));
      await driver.enterText('https://mock.api');
      await driver.tap(findTextAncestor('Participant ID', 'TextField'));
      await driver.enterText('mock_participant');
      await driver.tap(findTextAncestor('Registration key', 'TextField'));
      await driver.enterText('mock_key');
      await driver.tap(find.text('OK'));
      await driver.tap(find.byTooltip('Back'));
      await driver.waitFor(find.text('Mock API'));
      await driver.waitFor(find.text('Mock experiment'));
      await driver.waitFor(find.text('2 tasks left'));
    });

    test('can be completed', () async {
      await driver.tap(findTextAncestor('Mock experiment', 'Card'));
      await driver.tap(find.text('START'));
      await driver.tap(find.text('CONTINUE'));
      await driver.waitFor(find.text('What was this?'));
      await driver.tap(find.text('A test task'));
      await driver.scrollIntoView(find.text('FINISH'));
      await driver.tap(find.text('FINISH'));
      await driver.waitFor(find.text("What's this now?"));
      await driver.tap(find.text('An apple'));
      await Future.delayed(Duration(seconds: 1));
      await driver.scrollIntoView(find.text('FINISH'));
      await driver.tap(find.text('FINISH'));
      await driver.waitFor(find.text('NEXT TASK'));
      await driver.tap(find.text('LATER'));
      await driver.waitFor(findTextAncestor('Mock experiment', 'Card'));
      await driver.tap(find.byTooltip('Settings'));
      await driver.tap(find.byTooltip('Delete API'));
      await driver.tap(find.text('YES'));
      await driver.tap(find.byTooltip('Back'));
    });
  });
}
