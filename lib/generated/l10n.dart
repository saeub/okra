// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Connection failed`
  String get apiErrorConnectionFailed {
    return Intl.message(
      'Connection failed',
      name: 'apiErrorConnectionFailed',
      desc: '',
      args: [],
    );
  }

  /// `API error ({status})`
  String apiErrorGeneric(Object status) {
    return Intl.message(
      'API error ($status)',
      name: 'apiErrorGeneric',
      desc: '',
      args: [status],
    );
  }

  /// `Invalid participant ID or key`
  String get apiErrorInvalidCredentials {
    return Intl.message(
      'Invalid participant ID or key',
      name: 'apiErrorInvalidCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Invalid response received`
  String get apiErrorInvalidResponse {
    return Intl.message(
      'Invalid response received',
      name: 'apiErrorInvalidResponse',
      desc: '',
      args: [],
    );
  }

  /// `Invalid URL`
  String get apiErrorInvalidUrl {
    return Intl.message(
      'Invalid URL',
      name: 'apiErrorInvalidUrl',
      desc: '',
      args: [],
    );
  }

  /// `Request timed out`
  String get apiErrorTimeout {
    return Intl.message(
      'Request timed out',
      name: 'apiErrorTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Okra`
  String get appName {
    return Intl.message(
      'Okra',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `NO`
  String get dialogNo {
    return Intl.message(
      'NO',
      name: 'dialogNo',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get dialogOk {
    return Intl.message(
      'OK',
      name: 'dialogOk',
      desc: '',
      args: [],
    );
  }

  /// `YES`
  String get dialogYes {
    return Intl.message(
      'YES',
      name: 'dialogYes',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorGeneric(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'errorGeneric',
      desc: '',
      args: [error],
    );
  }

  /// `RETRY`
  String get errorRetry {
    return Intl.message(
      'RETRY',
      name: 'errorRetry',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error`
  String get errorUnknown {
    return Intl.message(
      'Unknown error',
      name: 'errorUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Okra is an app built at the University of Zurich. Researchers can use Okra to find out how well people can understand texts.\n\nIf you are a study participant, you should have a QR code. Scan this QR code to get your tasks.`
  String get experimentsIntro {
    return Intl.message(
      'Okra is an app built at the University of Zurich. Researchers can use Okra to find out how well people can understand texts.\n\nIf you are a study participant, you should have a QR code. Scan this QR code to get your tasks.',
      name: 'experimentsIntro',
      desc: '',
      args: [],
    );
  }

  /// `No tasks available at the moment`
  String get experimentsNoTasks {
    return Intl.message(
      'No tasks available at the moment',
      name: 'experimentsNoTasks',
      desc: '',
      args: [],
    );
  }

  /// `Experiments`
  String get experimentsPageTitle {
    return Intl.message(
      'Experiments',
      name: 'experimentsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get experimentsRefresh {
    return Intl.message(
      'Refresh',
      name: 'experimentsRefresh',
      desc: '',
      args: [],
    );
  }

  /// `SCAN QR CODE`
  String get experimentsScanQrCode {
    return Intl.message(
      'SCAN QR CODE',
      name: 'experimentsScanQrCode',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get experimentsStart {
    return Intl.message(
      'START',
      name: 'experimentsStart',
      desc: '',
      args: [],
    );
  }

  /// `{howMany, plural, one{1 task left} other{{howMany} tasks left}}`
  String experimentsTasksLeft(num howMany) {
    return Intl.plural(
      howMany,
      one: '1 task left',
      other: '$howMany tasks left',
      name: 'experimentsTasksLeft',
      desc: '',
      args: [howMany],
    );
  }

  /// `Loading audio failed`
  String get instructionsLoadingAudioFailed {
    return Intl.message(
      'Loading audio failed',
      name: 'instructionsLoadingAudioFailed',
      desc: '',
      args: [],
    );
  }

  /// `RESTART PRACTICE TASK`
  String get instructionsRestartPracticeTask {
    return Intl.message(
      'RESTART PRACTICE TASK',
      name: 'instructionsRestartPracticeTask',
      desc: '',
      args: [],
    );
  }

  /// `Read aloud`
  String get instructionsStartAudio {
    return Intl.message(
      'Read aloud',
      name: 'instructionsStartAudio',
      desc: '',
      args: [],
    );
  }

  /// `START PRACTICE TASK`
  String get instructionsStartPracticeTask {
    return Intl.message(
      'START PRACTICE TASK',
      name: 'instructionsStartPracticeTask',
      desc: '',
      args: [],
    );
  }

  /// `START TASK`
  String get instructionsStartTask {
    return Intl.message(
      'START TASK',
      name: 'instructionsStartTask',
      desc: '',
      args: [],
    );
  }

  /// `Stop reading`
  String get instructionsStopAudio {
    return Intl.message(
      'Stop reading',
      name: 'instructionsStopAudio',
      desc: '',
      args: [],
    );
  }

  /// `Instructions`
  String get instructionsTitle {
    return Intl.message(
      'Instructions',
      name: 'instructionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission required`
  String get registrationCameraPermissionRequired {
    return Intl.message(
      'Camera permission required',
      name: 'registrationCameraPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid QR code`
  String get registrationInvalidQrCode {
    return Intl.message(
      'Invalid QR code',
      name: 'registrationInvalidQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Registration key`
  String get registrationKey {
    return Intl.message(
      'Registration key',
      name: 'registrationKey',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get registrationOk {
    return Intl.message(
      'OK',
      name: 'registrationOk',
      desc: '',
      args: [],
    );
  }

  /// `Register API`
  String get registrationPageTitle {
    return Intl.message(
      'Register API',
      name: 'registrationPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Participant ID`
  String get registrationParticipantId {
    return Intl.message(
      'Participant ID',
      name: 'registrationParticipantId',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR code`
  String get registrationQrScannerTitle {
    return Intl.message(
      'Scan QR code',
      name: 'registrationQrScannerTitle',
      desc: '',
      args: [],
    );
  }

  /// `QR CODE`
  String get registrationScanQrCode {
    return Intl.message(
      'QR CODE',
      name: 'registrationScanQrCode',
      desc: '',
      args: [],
    );
  }

  /// `API URL`
  String get registrationUrl {
    return Intl.message(
      'API URL',
      name: 'registrationUrl',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get settingsAboutHeading {
    return Intl.message(
      'About',
      name: 'settingsAboutHeading',
      desc: '',
      args: [],
    );
  }

  /// `An app for text readability and comprehension experiments`
  String get settingsAboutText {
    return Intl.message(
      'An app for text readability and comprehension experiments',
      name: 'settingsAboutText',
      desc: '',
      args: [],
    );
  }

  /// `Add API`
  String get settingsAddApi {
    return Intl.message(
      'Add API',
      name: 'settingsAddApi',
      desc: '',
      args: [],
    );
  }

  /// `Added on {date} {time}`
  String settingsApiDate(Object date, Object time) {
    return Intl.message(
      'Added on $date $time',
      name: 'settingsApiDate',
      desc: '',
      args: [date, time],
    );
  }

  /// `APIs`
  String get settingsApiHeading {
    return Intl.message(
      'APIs',
      name: 'settingsApiHeading',
      desc: '',
      args: [],
    );
  }

  /// `Delete API`
  String get settingsDeleteApi {
    return Intl.message(
      'Delete API',
      name: 'settingsDeleteApi',
      desc: '',
      args: [],
    );
  }

  /// `Delete API?`
  String get settingsDeleteApiDialogTitle {
    return Intl.message(
      'Delete API?',
      name: 'settingsDeleteApiDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsPageTitle {
    return Intl.message(
      'Settings',
      name: 'settingsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset tutorial`
  String get settingsResetTutorial {
    return Intl.message(
      'Reset tutorial',
      name: 'settingsResetTutorial',
      desc: '',
      args: [],
    );
  }

  /// `Reset tutorial?`
  String get settingsResetTutorialDialogTitle {
    return Intl.message(
      'Reset tutorial?',
      name: 'settingsResetTutorialDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show completed experiments`
  String get settingsShowCompletedExperiments {
    return Intl.message(
      'Show completed experiments',
      name: 'settingsShowCompletedExperiments',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial`
  String get settingsTutorialHeading {
    return Intl.message(
      'Tutorial',
      name: 'settingsTutorialHeading',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to abort?`
  String get taskAbortDialogTitle {
    return Intl.message(
      'Do you really want to abort?',
      name: 'taskAbortDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `CONTINUE`
  String get taskAdvance {
    return Intl.message(
      'CONTINUE',
      name: 'taskAdvance',
      desc: '',
      args: [],
    );
  }

  /// `FINISH`
  String get taskFinish {
    return Intl.message(
      'FINISH',
      name: 'taskFinish',
      desc: '',
      args: [],
    );
  }

  /// `NOT A WORD`
  String get taskLexicalDecisionNonword {
    return Intl.message(
      'NOT A WORD',
      name: 'taskLexicalDecisionNonword',
      desc: '',
      args: [],
    );
  }

  /// `WORD`
  String get taskLexicalDecisionWord {
    return Intl.message(
      'WORD',
      name: 'taskLexicalDecisionWord',
      desc: '',
      args: [],
    );
  }

  /// `This task does not count`
  String get taskPracticeIndicatorSubtitle {
    return Intl.message(
      'This task does not count',
      name: 'taskPracticeIndicatorSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `PRACTICE`
  String get taskPracticeIndicatorTitle {
    return Intl.message(
      'PRACTICE',
      name: 'taskPracticeIndicatorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Answer questions`
  String get taskQuestionAnsweringExpandQuestions {
    return Intl.message(
      'Answer questions',
      name: 'taskQuestionAnsweringExpandQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Pop the balloon!`
  String get taskReactionTimeIntro {
    return Intl.message(
      'Pop the balloon!',
      name: 'taskReactionTimeIntro',
      desc: '',
      args: [],
    );
  }

  /// `CORRECT`
  String get taskReadingCorrect {
    return Intl.message(
      'CORRECT',
      name: 'taskReadingCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Please correct your answers.`
  String get taskReadingCorrectionDialogText {
    return Intl.message(
      'Please correct your answers.',
      name: 'taskReadingCorrectionDialogText',
      desc: '',
      args: [],
    );
  }

  /// `{howMany, plural, one{1 answer} other{{howMany} answers}} incorrect`
  String taskReadingCorrectionDialogTitle(num howMany) {
    return Intl.message(
      '${Intl.plural(howMany, one: '1 answer', other: '$howMany answers')} incorrect',
      name: 'taskReadingCorrectionDialogTitle',
      desc: '',
      args: [howMany],
    );
  }

  /// `INCORRECT`
  String get taskReadingIncorrect {
    return Intl.message(
      'INCORRECT',
      name: 'taskReadingIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `FINISH EXPERIMENT`
  String get taskResultsFinishExperiment {
    return Intl.message(
      'FINISH EXPERIMENT',
      name: 'taskResultsFinishExperiment',
      desc: '',
      args: [],
    );
  }

  /// `Awesome!`
  String get taskResultsMessage1 {
    return Intl.message(
      'Awesome!',
      name: 'taskResultsMessage1',
      desc: '',
      args: [],
    );
  }

  /// `Well done!`
  String get taskResultsMessage2 {
    return Intl.message(
      'Well done!',
      name: 'taskResultsMessage2',
      desc: '',
      args: [],
    );
  }

  /// `Great job!`
  String get taskResultsMessage3 {
    return Intl.message(
      'Great job!',
      name: 'taskResultsMessage3',
      desc: '',
      args: [],
    );
  }

  /// `NEXT TASK`
  String get taskResultsNextTask {
    return Intl.message(
      'NEXT TASK',
      name: 'taskResultsNextTask',
      desc: '',
      args: [],
    );
  }

  /// `The next task will count!`
  String get taskResultsNextTaskCounts {
    return Intl.message(
      'The next task will count!',
      name: 'taskResultsNextTaskCounts',
      desc: '',
      args: [],
    );
  }

  /// `LATER`
  String get taskResultsNoNextTask {
    return Intl.message(
      'LATER',
      name: 'taskResultsNoNextTask',
      desc: '',
      args: [],
    );
  }

  /// `REPEAT PRACTICE TASK`
  String get taskResultsRepeatPracticeTask {
    return Intl.message(
      'REPEAT PRACTICE TASK',
      name: 'taskResultsRepeatPracticeTask',
      desc: '',
      args: [],
    );
  }

  /// `{howMany, plural, one{1 second} other{{howMany} seconds}}`
  String taskResultsSecondsTaken(num howMany) {
    return Intl.plural(
      howMany,
      one: '1 second',
      other: '$howMany seconds',
      name: 'taskResultsSecondsTaken',
      desc: '',
      args: [howMany],
    );
  }

  /// `Rotate your phone into landscape mode`
  String get taskRotateLandscape {
    return Intl.message(
      'Rotate your phone into landscape mode',
      name: 'taskRotateLandscape',
      desc: '',
      args: [],
    );
  }

  /// `Rotate your phone into portrait mode`
  String get taskRotatePortrait {
    return Intl.message(
      'Rotate your phone into portrait mode',
      name: 'taskRotatePortrait',
      desc: '',
      args: [],
    );
  }

  /// `START`
  String get taskTrailMakingStart {
    return Intl.message(
      'START',
      name: 'taskTrailMakingStart',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial`
  String get tutorialName {
    return Intl.message(
      'Tutorial',
      name: 'tutorialName',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'CH'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'it'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
