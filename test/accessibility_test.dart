import 'package:accessibility_test/accessibility_test.dart';
import 'package:okra/main.dart';

void main() {
  themeTest(
    'Theme accessibility',
    App.theme,
    accessibilityLevel: ThemeAccessibilityLevel.normal,
  );
}
