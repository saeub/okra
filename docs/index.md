> **NOTE:** This project is in alpha stage and under ongoing development. It may be subject to fundamental changes anytime.

Okra is a mobile (Android/iOS) app which allows its users to participate in psycholinguistic experiments. It receives the experiment setup and stimuli from a server of the institution conducting the experiment, presents the stimuli to the participant, collects responses and behavioral data, and sends them back to the server.

## Supported tasks

The app currently provides implementations of various types of tasks related to psycholinguistics and reading comprehension in particular:

- Cloze test
- Lexical decision task
- Multiple-choice question answering task
- *n*-back working memory task
- Picture naming task
- Reaction time test
- Simon game (working memory task)

Issues and pull requests about adding more tasks are welcome (as long as they make sense).

## Supported languages

The app is currently available in these [localizations](https://github.com/saeub/okra/tree/master/lib/l10n):

- English
- German
- German (Switzerland)

Pull requests adding more languages are welcome.

## [💻 Source code](https://github.com/saeub/okra)

## [🖼️ Screenshots](https://github.com/saeub/okra/wiki/Screenshots)

## Documentation

- [Project goals](goals.md)
- [System architecture and technical overview](architecture.md)
- [API specification](api/index.html)
- [Task specifications](tasks.md)

## Getting started

### Conducting experiments

To create and conduct experiments, you need to:

1. Set up a server that serves an API according to the [specs](api/index.html). There is an [example implementation](https://github.com/saeub/okra-server-example).
1. Create a participant ID and a registration key for each participant to authenticate them.
1. Generate QR codes from strings like this:  
   `<base-url>\n<participant-id>\n<registration-key>`
1. Give the QR codes to your participants to scan.
1. Distribute experiments and tasks using the API according to your own logic.

### Developing

Requirements:

- [Flutter](https://flutter.dev/)
- Android/iOS emulator or a real device for testing
- Flutter Intl ([extension for VS Code](https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl) or [plugin for IntelliJ](https://plugins.jetbrains.com/plugin/13666-flutter-intl)) for i18n code generation

While developing, you can use the dummy server under `dev_server/` and connect to it from the app on your emulator (`http://10.0.2.2:<port>` on Android) or device.

Running tests:

- Unit: `flutter test`
- Integration: `flutter driver --target test_driver/app.dart`

Code formatting / static analysis:

- `flutter format lib/main.dart lib/src/ test/ test_driver/`
- `flutter analyze`
- Keep translation files (`lib/i10n/*.arb`) files sorted
