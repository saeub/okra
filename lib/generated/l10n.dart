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
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
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

  /// `CANCEL`
  String get registrationQrCancel {
    return Intl.message(
      'CANCEL',
      name: 'registrationQrCancel',
      desc: '',
      args: [],
    );
  }

  /// `FLASH OFF`
  String get registrationQrFlashOff {
    return Intl.message(
      'FLASH OFF',
      name: 'registrationQrFlashOff',
      desc: '',
      args: [],
    );
  }

  /// `FLASH ON`
  String get registrationQrFlashOn {
    return Intl.message(
      'FLASH ON',
      name: 'registrationQrFlashOn',
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

  /// `Continue with the next one?`
  String get taskResultsNextTaskTitle {
    return Intl.message(
      'Continue with the next one?',
      name: 'taskResultsNextTaskTitle',
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
      Locale.fromSubtags(languageCode: 'de', countryCode: 'CH'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}