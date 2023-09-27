// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(status) => "Errore API  (${status})";

  static String m1(error) => "Errore: ${error}";

  static String m2(howMany) =>
      "${Intl.plural(howMany, one: '1 compito rimanente', other: '${howMany} compiti rimanenti')}";

  static String m3(date, time) => "Aggiunto il ${date} ${time}";

  static String m4(howMany) =>
      "${Intl.plural(howMany, one: '1 answer', other: '${howMany} answers')} incorrect";

  static String m5(howMany) =>
      "${Intl.plural(howMany, one: '1 secondo', other: '${howMany} secondi')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "apiErrorConnectionFailed":
            MessageLookupByLibrary.simpleMessage("Connessione falita"),
        "apiErrorGeneric": m0,
        "apiErrorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
            "ID utilizzatore o chiave invalida"),
        "apiErrorInvalidResponse":
            MessageLookupByLibrary.simpleMessage("Risposta invalida"),
        "apiErrorInvalidUrl":
            MessageLookupByLibrary.simpleMessage("URL invalida"),
        "apiErrorTimeout":
            MessageLookupByLibrary.simpleMessage("Tempo di risposta scaduto"),
        "appName": MessageLookupByLibrary.simpleMessage("Okra"),
        "dialogNo": MessageLookupByLibrary.simpleMessage("NO"),
        "dialogOk": MessageLookupByLibrary.simpleMessage("OK"),
        "dialogYes": MessageLookupByLibrary.simpleMessage("SÌ"),
        "errorGeneric": m1,
        "errorRetry": MessageLookupByLibrary.simpleMessage("RIPROVARE"),
        "errorUnknown":
            MessageLookupByLibrary.simpleMessage("Errore sconosciuto"),
        "experimentsIntro": MessageLookupByLibrary.simpleMessage(
            "Okra is an app built at the University of Zurich. Researchers can use Okra to find out how well people can understand texts.\n\nIf you are a study participant, you should have a QR code. Scan this QR code to get your tasks."),
        "experimentsNoTasks": MessageLookupByLibrary.simpleMessage(
            "Nessun compito disponibile al momento"),
        "experimentsPageTitle":
            MessageLookupByLibrary.simpleMessage("Esperimenti"),
        "experimentsScanQrCode":
            MessageLookupByLibrary.simpleMessage("SCANNERIZZA IL QR-CODE"),
        "experimentsTasksLeft": m2,
        "instructionsLoadingAudioFailed":
            MessageLookupByLibrary.simpleMessage("Caricamento audio fallito"),
        "instructionsRestartPracticeTask":
            MessageLookupByLibrary.simpleMessage("RICOMINCIA L\'ESERCIZIO"),
        "instructionsStartAudio":
            MessageLookupByLibrary.simpleMessage("Leggi ad alta voce"),
        "instructionsStartPracticeTask":
            MessageLookupByLibrary.simpleMessage("INIZIA L\'ESERCIZIO"),
        "instructionsStartTask":
            MessageLookupByLibrary.simpleMessage("INIZIA IL COMPITO"),
        "instructionsStopAudio":
            MessageLookupByLibrary.simpleMessage("Interrompere la lettura"),
        "instructionsTitle": MessageLookupByLibrary.simpleMessage("Istruzioni"),
        "registrationCameraPermissionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Autorizzazione camera richiesta"),
        "registrationInvalidQrCode":
            MessageLookupByLibrary.simpleMessage("QR-Code invalido"),
        "registrationKey":
            MessageLookupByLibrary.simpleMessage("Chiave di registrazione"),
        "registrationOk": MessageLookupByLibrary.simpleMessage("OK"),
        "registrationPageTitle":
            MessageLookupByLibrary.simpleMessage("Registrare API"),
        "registrationParticipantId":
            MessageLookupByLibrary.simpleMessage("ID utilizzatore"),
        "registrationQrScannerTitle":
            MessageLookupByLibrary.simpleMessage("Scan QR code"),
        "registrationScanQrCode":
            MessageLookupByLibrary.simpleMessage("QR-CODE"),
        "registrationUrl": MessageLookupByLibrary.simpleMessage("API URL"),
        "settingsAboutHeading": MessageLookupByLibrary.simpleMessage("Info"),
        "settingsAboutText": MessageLookupByLibrary.simpleMessage(
            "Un\'app per testare la leggibilità e la comprensibilità di testi"),
        "settingsAddApi": MessageLookupByLibrary.simpleMessage("Aggiungi API"),
        "settingsApiDate": m3,
        "settingsApiHeading": MessageLookupByLibrary.simpleMessage("APIs"),
        "settingsDeleteApi":
            MessageLookupByLibrary.simpleMessage("Cancellare API"),
        "settingsDeleteApiDialogTitle":
            MessageLookupByLibrary.simpleMessage("Cancellare API?"),
        "settingsPageTitle":
            MessageLookupByLibrary.simpleMessage("Impostazioni"),
        "settingsResetTutorial":
            MessageLookupByLibrary.simpleMessage("Riavviare il tutorial"),
        "settingsResetTutorialDialogTitle":
            MessageLookupByLibrary.simpleMessage("Riavviare il tutorial?"),
        "settingsTutorialHeading":
            MessageLookupByLibrary.simpleMessage("Tutorial"),
        "taskAbortDialogTitle":
            MessageLookupByLibrary.simpleMessage("Vuoi veramente uscire?"),
        "taskAdvance": MessageLookupByLibrary.simpleMessage("CONTINUA"),
        "taskFinish": MessageLookupByLibrary.simpleMessage("TERMINARE"),
        "taskLexicalDecisionNonword":
            MessageLookupByLibrary.simpleMessage("NESSUNA PAROLA"),
        "taskLexicalDecisionWord":
            MessageLookupByLibrary.simpleMessage("PAROLA"),
        "taskPracticeIndicatorSubtitle":
            MessageLookupByLibrary.simpleMessage("Questo compito non conta"),
        "taskPracticeIndicatorTitle":
            MessageLookupByLibrary.simpleMessage("ESERCIZIO"),
        "taskQuestionAnsweringExpandQuestions":
            MessageLookupByLibrary.simpleMessage("Rispondere alle domande"),
        "taskReactionTimeIntro": MessageLookupByLibrary.simpleMessage(
            "Fai scoppiare il palloncino!"),
        "taskReadingCorrect": MessageLookupByLibrary.simpleMessage("CORRECT"),
        "taskReadingCorrectionDialogText": MessageLookupByLibrary.simpleMessage(
            "Please correct your answers."),
        "taskReadingCorrectionDialogTitle": m4,
        "taskReadingIncorrect":
            MessageLookupByLibrary.simpleMessage("INCORRECT"),
        "taskResultsFinishExperiment":
            MessageLookupByLibrary.simpleMessage("TERMINARE L\'ESPERIMENTO"),
        "taskResultsMessage1": MessageLookupByLibrary.simpleMessage("Super!"),
        "taskResultsMessage2":
            MessageLookupByLibrary.simpleMessage("Ben fatto!"),
        "taskResultsMessage3":
            MessageLookupByLibrary.simpleMessage("Bel lavoro!"),
        "taskResultsNextTask":
            MessageLookupByLibrary.simpleMessage("PROSSIMO COMPITO"),
        "taskResultsNextTaskCounts":
            MessageLookupByLibrary.simpleMessage("Il prossimo compito conta!"),
        "taskResultsNoNextTask":
            MessageLookupByLibrary.simpleMessage("PIU\' TARDI"),
        "taskResultsRepeatPracticeTask":
            MessageLookupByLibrary.simpleMessage("RIPETI ESERCIZIO"),
        "taskResultsSecondsTaken": m5,
        "taskRotateLandscape": MessageLookupByLibrary.simpleMessage(
            "Gira il tuo telefono in orizzontale"),
        "taskRotatePortrait": MessageLookupByLibrary.simpleMessage(
            "Gira il tuo telefono in verticale"),
        "taskTrailMakingStart": MessageLookupByLibrary.simpleMessage("START"),
        "tutorialName": MessageLookupByLibrary.simpleMessage("Tutorial")
      };
}
