// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(status) => "API error (${status})";

  static String m1(error) => "Error: ${error}";

  static String m2(howMany) =>
      "${Intl.plural(howMany, one: '1 task left', other: '${howMany} tasks left')}";

  static String m3(date, time) => "Added on ${date} ${time}";

  static String m4(howMany) =>
      "${Intl.plural(howMany, one: '1 answer', other: '${howMany} answers')} incorrect";

  static String m5(howMany) =>
      "${Intl.plural(howMany, one: '1 second', other: '${howMany} seconds')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "apiErrorConnectionFailed":
            MessageLookupByLibrary.simpleMessage("Connection failed"),
        "apiErrorGeneric": m0,
        "apiErrorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Invalid participant ID or key"),
        "apiErrorInvalidResponse":
            MessageLookupByLibrary.simpleMessage("Invalid response received"),
        "apiErrorInvalidUrl":
            MessageLookupByLibrary.simpleMessage("Invalid URL"),
        "apiErrorTimeout":
            MessageLookupByLibrary.simpleMessage("Request timed out"),
        "appName": MessageLookupByLibrary.simpleMessage("Okra"),
        "dialogNo": MessageLookupByLibrary.simpleMessage("NO"),
        "dialogOk": MessageLookupByLibrary.simpleMessage("OK"),
        "dialogYes": MessageLookupByLibrary.simpleMessage("YES"),
        "errorGeneric": m1,
        "errorRetry": MessageLookupByLibrary.simpleMessage("RETRY"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage("Unknown error"),
        "experimentsNoTasks": MessageLookupByLibrary.simpleMessage(
            "No tasks available at the moment"),
        "experimentsPageTitle":
            MessageLookupByLibrary.simpleMessage("Experiments"),
        "experimentsScanQrCode":
            MessageLookupByLibrary.simpleMessage("SCAN QR-CODE"),
        "experimentsTasksLeft": m2,
        "instructionsLoadingAudioFailed":
            MessageLookupByLibrary.simpleMessage("Loading audio failed"),
        "instructionsRestartPracticeTask":
            MessageLookupByLibrary.simpleMessage("RESTART PRACTICE TASK"),
        "instructionsStartAudio":
            MessageLookupByLibrary.simpleMessage("Read aloud"),
        "instructionsStartPracticeTask":
            MessageLookupByLibrary.simpleMessage("START PRACTICE TASK"),
        "instructionsStartTask":
            MessageLookupByLibrary.simpleMessage("START TASK"),
        "instructionsStopAudio":
            MessageLookupByLibrary.simpleMessage("Stop reading"),
        "instructionsTitle":
            MessageLookupByLibrary.simpleMessage("Instructions"),
        "registrationCameraPermissionRequired":
            MessageLookupByLibrary.simpleMessage("Camera permission required"),
        "registrationInvalidQrCode":
            MessageLookupByLibrary.simpleMessage("Invalid QR code"),
        "registrationKey":
            MessageLookupByLibrary.simpleMessage("Registration key"),
        "registrationOk": MessageLookupByLibrary.simpleMessage("OK"),
        "registrationPageTitle":
            MessageLookupByLibrary.simpleMessage("Register API"),
        "registrationParticipantId":
            MessageLookupByLibrary.simpleMessage("Participant ID"),
        "registrationQrCancel": MessageLookupByLibrary.simpleMessage("CANCEL"),
        "registrationQrFlashOff":
            MessageLookupByLibrary.simpleMessage("FLASH OFF"),
        "registrationQrFlashOn":
            MessageLookupByLibrary.simpleMessage("FLASH ON"),
        "registrationScanQrCode":
            MessageLookupByLibrary.simpleMessage("QR CODE"),
        "registrationUrl": MessageLookupByLibrary.simpleMessage("API URL"),
        "settingsAboutHeading": MessageLookupByLibrary.simpleMessage("About"),
        "settingsAboutText": MessageLookupByLibrary.simpleMessage(
            "An app for text readability and comprehension experiments"),
        "settingsAddApi": MessageLookupByLibrary.simpleMessage("Add API"),
        "settingsApiDate": m3,
        "settingsApiHeading": MessageLookupByLibrary.simpleMessage("APIs"),
        "settingsDeleteApi": MessageLookupByLibrary.simpleMessage("Delete API"),
        "settingsDeleteApiDialogTitle":
            MessageLookupByLibrary.simpleMessage("Delete API?"),
        "settingsPageTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "settingsResetTutorial":
            MessageLookupByLibrary.simpleMessage("Reset tutorial"),
        "settingsResetTutorialDialogTitle":
            MessageLookupByLibrary.simpleMessage("Reset tutorial?"),
        "settingsTutorialHeading":
            MessageLookupByLibrary.simpleMessage("Tutorial"),
        "taskAbortDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Do you really want to abort?"),
        "taskAdvance": MessageLookupByLibrary.simpleMessage("CONTINUE"),
        "taskFinish": MessageLookupByLibrary.simpleMessage("FINISH"),
        "taskLexicalDecisionNonword":
            MessageLookupByLibrary.simpleMessage("NOT A WORD"),
        "taskLexicalDecisionWord": MessageLookupByLibrary.simpleMessage("WORD"),
        "taskPracticeIndicatorSubtitle":
            MessageLookupByLibrary.simpleMessage("This task does not count"),
        "taskPracticeIndicatorTitle":
            MessageLookupByLibrary.simpleMessage("PRACTICE"),
        "taskQuestionAnsweringExpandQuestions":
            MessageLookupByLibrary.simpleMessage("Answer questions"),
        "taskReactionTimeIntro":
            MessageLookupByLibrary.simpleMessage("Pop the balloon!"),
        "taskReadingCorrect": MessageLookupByLibrary.simpleMessage("CORRECT"),
        "taskReadingCorrectionDialogText": MessageLookupByLibrary.simpleMessage(
            "Please correct your answers."),
        "taskReadingCorrectionDialogTitle": m4,
        "taskReadingIncorrect":
            MessageLookupByLibrary.simpleMessage("INCORRECT"),
        "taskResultsFinishExperiment":
            MessageLookupByLibrary.simpleMessage("FINISH EXPERIMENT"),
        "taskResultsMessage1": MessageLookupByLibrary.simpleMessage("Awesome!"),
        "taskResultsMessage2":
            MessageLookupByLibrary.simpleMessage("Well done!"),
        "taskResultsMessage3":
            MessageLookupByLibrary.simpleMessage("Great job!"),
        "taskResultsNextTask":
            MessageLookupByLibrary.simpleMessage("NEXT TASK"),
        "taskResultsNextTaskCounts":
            MessageLookupByLibrary.simpleMessage("The next task will count!"),
        "taskResultsNoNextTask": MessageLookupByLibrary.simpleMessage("LATER"),
        "taskResultsRepeatPracticeTask":
            MessageLookupByLibrary.simpleMessage("REPEAT PRACTICE TASK"),
        "taskResultsSecondsTaken": m5,
        "taskRotateLandscape": MessageLookupByLibrary.simpleMessage(
            "Rotate your phone into landscape mode"),
        "taskRotatePortrait": MessageLookupByLibrary.simpleMessage(
            "Rotate your phone into portrait mode"),
        "taskTrailMakingStart": MessageLookupByLibrary.simpleMessage("START"),
        "tutorialName": MessageLookupByLibrary.simpleMessage("Tutorial")
      };
}
