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
      "${Intl.plural(howMany, one: '1 risposta sbagliata', other: '${howMany} risposte sbagliate')}";

  static String m5(howMany) =>
      "${Intl.plural(howMany, one: '1 secondo', other: '${howMany} secondi')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "apiErrorConnectionFailed":
            MessageLookupByLibrary.simpleMessage("Connessione fallita"),
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
            "Okra è un\'app dell\'Università di Zurigo. Con Okra, i ricercatori possono scoprire se le persone capiscono un testo o no.\n\nSe partecipi a uno studio dovresti avere un QR code. Scannerizza questo QR code per vedere i tuoi compiti."),
        "experimentsNoTasks": MessageLookupByLibrary.simpleMessage(
            "Nessun compito disponibile al momento"),
        "experimentsPageTitle":
            MessageLookupByLibrary.simpleMessage("Esperimenti"),
        "experimentsRefresh":
            MessageLookupByLibrary.simpleMessage("Aggiornare"),
        "experimentsScanQrCode":
            MessageLookupByLibrary.simpleMessage("SCANNERIZZA IL QR CODE"),
        "experimentsStart": MessageLookupByLibrary.simpleMessage("INIZIARE"),
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
            MessageLookupByLibrary.simpleMessage("QR code invalido"),
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
            MessageLookupByLibrary.simpleMessage("QR CODE"),
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
        "settingsShowCompletedExperiments":
            MessageLookupByLibrary.simpleMessage(
                "Mostrare gli esperimenti terminati"),
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
        "taskReadingCorrect": MessageLookupByLibrary.simpleMessage("CORRETTO"),
        "taskReadingCorrectionDialogText": MessageLookupByLibrary.simpleMessage(
            "Per favore correggi le tue risposte."),
        "taskReadingCorrectionDialogTitle": m4,
        "taskReadingIncorrect":
            MessageLookupByLibrary.simpleMessage("SBAGLIATO"),
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
            MessageLookupByLibrary.simpleMessage("PIÙ TARDI"),
        "taskResultsRepeatPracticeTask":
            MessageLookupByLibrary.simpleMessage("RIPETI ESERCIZIO"),
        "taskResultsSecondsTaken": m5,
        "taskRotateLandscape": MessageLookupByLibrary.simpleMessage(
            "Gira il tuo telefono in orizzontale"),
        "taskRotatePortrait": MessageLookupByLibrary.simpleMessage(
            "Gira il tuo telefono in verticale"),
        "taskTrailMakingStart":
            MessageLookupByLibrary.simpleMessage("INIZIARE"),
        "tutorialName": MessageLookupByLibrary.simpleMessage("Tutorial")
      };
}
