// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de_CH locale. All the
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
  String get localeName => 'de_CH';

  static String m0(status) => "API-Fehler (${status})";

  static String m1(error) => "Fehler: ${error}";

  static String m2(howMany) =>
      "${Intl.plural(howMany, one: '1 Aufgabe übrig', other: '${howMany} Aufgaben übrig')}";

  static String m3(date, time) => "Hinzugefügt am ${date} ${time}";

  static String m4(howMany) =>
      "${Intl.plural(howMany, one: '1 Antwort', other: '${howMany} Antworten')} falsch";

  static String m5(howMany) =>
      "${Intl.plural(howMany, one: '1 Sekunde', other: '${howMany} Sekunden')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "apiErrorConnectionFailed":
            MessageLookupByLibrary.simpleMessage("Verbindung fehlgeschlagen"),
        "apiErrorGeneric": m0,
        "apiErrorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Ungültige Teilnehmer-ID oder Schlüssel"),
        "apiErrorInvalidResponse":
            MessageLookupByLibrary.simpleMessage("Ungültige Antwort"),
        "apiErrorInvalidUrl":
            MessageLookupByLibrary.simpleMessage("Ungültige URL"),
        "apiErrorTimeout":
            MessageLookupByLibrary.simpleMessage("Zeitüberschreitung"),
        "appName": MessageLookupByLibrary.simpleMessage("Okra"),
        "dialogNo": MessageLookupByLibrary.simpleMessage("NEIN"),
        "dialogOk": MessageLookupByLibrary.simpleMessage("OK"),
        "dialogYes": MessageLookupByLibrary.simpleMessage("JA"),
        "errorGeneric": m1,
        "errorRetry": MessageLookupByLibrary.simpleMessage("ERNEUT VERSUCHEN"),
        "errorUnknown":
            MessageLookupByLibrary.simpleMessage("Unbekannter Fehler"),
        "experimentsNoTasks": MessageLookupByLibrary.simpleMessage(
            "Momentan keine Aufgaben verfügbar"),
        "experimentsPageTitle":
            MessageLookupByLibrary.simpleMessage("Experimente"),
        "experimentsScanQrCode":
            MessageLookupByLibrary.simpleMessage("QR-CODE SCANNEN"),
        "experimentsTasksLeft": m2,
        "instructionsLoadingAudioFailed":
            MessageLookupByLibrary.simpleMessage("Laden fehlgeschlagen"),
        "instructionsRestartPracticeTask": MessageLookupByLibrary.simpleMessage(
            "ÜBUNGSAUFGABE ERNEUT STARTEN"),
        "instructionsStartAudio":
            MessageLookupByLibrary.simpleMessage("Vorlesen"),
        "instructionsStartPracticeTask":
            MessageLookupByLibrary.simpleMessage("ÜBUNGSAUFGABE STARTEN"),
        "instructionsStartTask":
            MessageLookupByLibrary.simpleMessage("AUFGABE STARTEN"),
        "instructionsStopAudio":
            MessageLookupByLibrary.simpleMessage("Vorlesen stoppen"),
        "instructionsTitle": MessageLookupByLibrary.simpleMessage("Anleitung"),
        "registrationCameraPermissionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Kamera-Berechtigung erforderlich"),
        "registrationInvalidQrCode":
            MessageLookupByLibrary.simpleMessage("Ungültiger QR-Code"),
        "registrationKey":
            MessageLookupByLibrary.simpleMessage("Registrierungsschlüssel"),
        "registrationOk": MessageLookupByLibrary.simpleMessage("OK"),
        "registrationPageTitle":
            MessageLookupByLibrary.simpleMessage("API registrieren"),
        "registrationParticipantId":
            MessageLookupByLibrary.simpleMessage("Teilnehmer-ID"),
        "registrationQrScannerTitle":
            MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
        "registrationScanQrCode":
            MessageLookupByLibrary.simpleMessage("QR-CODE"),
        "registrationUrl": MessageLookupByLibrary.simpleMessage("API-URL"),
        "settingsAboutHeading": MessageLookupByLibrary.simpleMessage("Info"),
        "settingsAboutText": MessageLookupByLibrary.simpleMessage(
            "Eine App zur Überprüfung von Textlesbarkeit und -verständlichkeit"),
        "settingsAddApi":
            MessageLookupByLibrary.simpleMessage("API hinzufügen"),
        "settingsApiDate": m3,
        "settingsApiHeading": MessageLookupByLibrary.simpleMessage("APIs"),
        "settingsDeleteApi":
            MessageLookupByLibrary.simpleMessage("API löschen"),
        "settingsDeleteApiDialogTitle":
            MessageLookupByLibrary.simpleMessage("API löschen?"),
        "settingsPageTitle":
            MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "settingsResetTutorial":
            MessageLookupByLibrary.simpleMessage("Tutorial zurücksetzen"),
        "settingsResetTutorialDialogTitle":
            MessageLookupByLibrary.simpleMessage("Tutorial zurücksetzen?"),
        "settingsTutorialHeading":
            MessageLookupByLibrary.simpleMessage("Tutorial"),
        "taskAbortDialogTitle": MessageLookupByLibrary.simpleMessage(
            "Willst du wirklich abbrechen?"),
        "taskAdvance": MessageLookupByLibrary.simpleMessage("WEITER"),
        "taskFinish": MessageLookupByLibrary.simpleMessage("ABSCHLIESSEN"),
        "taskLexicalDecisionNonword":
            MessageLookupByLibrary.simpleMessage("KEIN WORT"),
        "taskLexicalDecisionWord": MessageLookupByLibrary.simpleMessage("WORT"),
        "taskPracticeIndicatorSubtitle":
            MessageLookupByLibrary.simpleMessage("Diese Aufgabe zählt nicht"),
        "taskPracticeIndicatorTitle":
            MessageLookupByLibrary.simpleMessage("ÜBUNG"),
        "taskQuestionAnsweringExpandQuestions":
            MessageLookupByLibrary.simpleMessage("Fragen beantworten"),
        "taskReactionTimeIntro":
            MessageLookupByLibrary.simpleMessage("Lass den Ballon platzen!"),
        "taskReadingCorrect": MessageLookupByLibrary.simpleMessage("RICHTIG"),
        "taskReadingCorrectionDialogText": MessageLookupByLibrary.simpleMessage(
            "Bitte korrigiere deine Antworten."),
        "taskReadingCorrectionDialogTitle": m4,
        "taskReadingIncorrect": MessageLookupByLibrary.simpleMessage("FALSCH"),
        "taskResultsFinishExperiment":
            MessageLookupByLibrary.simpleMessage("EXPERIMENT ABSCHLIESSEN"),
        "taskResultsMessage1": MessageLookupByLibrary.simpleMessage("Super!"),
        "taskResultsMessage2":
            MessageLookupByLibrary.simpleMessage("Gut gemacht!"),
        "taskResultsMessage3":
            MessageLookupByLibrary.simpleMessage("Weiter so!"),
        "taskResultsNextTask":
            MessageLookupByLibrary.simpleMessage("NÄCHSTE AUFGABE"),
        "taskResultsNextTaskCounts":
            MessageLookupByLibrary.simpleMessage("Die nächste Aufgabe zählt!"),
        "taskResultsNoNextTask": MessageLookupByLibrary.simpleMessage("SPÄTER"),
        "taskResultsRepeatPracticeTask":
            MessageLookupByLibrary.simpleMessage("ÜBUNGSAUFGABE WIEDERHOLEN"),
        "taskResultsSecondsTaken": m5,
        "taskRotateLandscape": MessageLookupByLibrary.simpleMessage(
            "Drehe dein Gerät ins Querformat"),
        "taskRotatePortrait": MessageLookupByLibrary.simpleMessage(
            "Drehe dein Gerät ins Hochformat"),
        "taskTrailMakingStart": MessageLookupByLibrary.simpleMessage("START"),
        "tutorialName": MessageLookupByLibrary.simpleMessage("Tutorial")
      };
}
