// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(status) => "Erreur d\'API (${status})";

  static String m1(error) => "Erreur: ${error}";

  static String m2(howMany) =>
      "${Intl.plural(howMany, one: '1 tache restante', other: '${howMany} taches restantes')}";

  static String m3(date, time) => "Ajouté le ${date} ${time}";

  static String m4(howMany) =>
      "${Intl.plural(howMany, one: '1 answer', other: '${howMany} answers')} incorrect";

  static String m5(howMany) =>
      "${Intl.plural(howMany, one: '1 seconde', other: '${howMany} secondes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "apiErrorConnectionFailed":
            MessageLookupByLibrary.simpleMessage("Échec de la connexion"),
        "apiErrorGeneric": m0,
        "apiErrorInvalidCredentials": MessageLookupByLibrary.simpleMessage(
            "Nom d\'utilisateur ou clé invalide"),
        "apiErrorInvalidResponse":
            MessageLookupByLibrary.simpleMessage("Réponse invalide"),
        "apiErrorInvalidUrl":
            MessageLookupByLibrary.simpleMessage("URL invalide"),
        "apiErrorTimeout":
            MessageLookupByLibrary.simpleMessage("Délai de réponse dépassé"),
        "appName": MessageLookupByLibrary.simpleMessage("Okra"),
        "dialogNo": MessageLookupByLibrary.simpleMessage("NON"),
        "dialogOk": MessageLookupByLibrary.simpleMessage("OK"),
        "dialogYes": MessageLookupByLibrary.simpleMessage("OUI"),
        "errorGeneric": m1,
        "errorRetry": MessageLookupByLibrary.simpleMessage("RECOMMENCER"),
        "errorUnknown": MessageLookupByLibrary.simpleMessage("Erreur inconnue"),
        "experimentsIntro": MessageLookupByLibrary.simpleMessage(
            "Okra est une application de l\'Université de Zurich. Avec Okra, les scientifiques peuvent découvrir si les personnes comprennent un texte ou pas.\n\nSi tu participes à une étude, tu devrais avoir un QR code. Scanne ce QR code pour voir tes tâches."),
        "experimentsNoTasks": MessageLookupByLibrary.simpleMessage(
            "Aucune tache disponible pour l\'instant"),
        "experimentsPageTitle":
            MessageLookupByLibrary.simpleMessage("Expérimentations"),
        "experimentsRefresh":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "experimentsScanQrCode":
            MessageLookupByLibrary.simpleMessage("SCANNER LE QR CODE"),
        "experimentsStart": MessageLookupByLibrary.simpleMessage("COMMENCER"),
        "experimentsTasksLeft": m2,
        "instructionsLoadingAudioFailed":
            MessageLookupByLibrary.simpleMessage("Échec du chargement du son"),
        "instructionsRestartPracticeTask":
            MessageLookupByLibrary.simpleMessage("RECOMMENCER L\'EXERCICE"),
        "instructionsStartAudio":
            MessageLookupByLibrary.simpleMessage("Lire à voix haute"),
        "instructionsStartPracticeTask":
            MessageLookupByLibrary.simpleMessage("DÉMARRER L\'EXERCICE"),
        "instructionsStartTask":
            MessageLookupByLibrary.simpleMessage("COMMENCER LA TACHE"),
        "instructionsStopAudio":
            MessageLookupByLibrary.simpleMessage("Arrêter la lecture"),
        "instructionsTitle":
            MessageLookupByLibrary.simpleMessage("Instructions"),
        "registrationCameraPermissionRequired":
            MessageLookupByLibrary.simpleMessage(
                "Autoriser l\'utilisation de la caméra"),
        "registrationInvalidQrCode":
            MessageLookupByLibrary.simpleMessage("QR Code invalide"),
        "registrationKey":
            MessageLookupByLibrary.simpleMessage("Clé d\'enregistrement"),
        "registrationOk": MessageLookupByLibrary.simpleMessage("OK"),
        "registrationPageTitle":
            MessageLookupByLibrary.simpleMessage("Enregistrer l\'API"),
        "registrationParticipantId":
            MessageLookupByLibrary.simpleMessage("Nom d\'utilisateur"),
        "registrationQrScannerTitle":
            MessageLookupByLibrary.simpleMessage("ANNULER"),
        "registrationScanQrCode":
            MessageLookupByLibrary.simpleMessage("QR CODE"),
        "registrationUrl":
            MessageLookupByLibrary.simpleMessage("URL de l\'API"),
        "settingsAboutHeading": MessageLookupByLibrary.simpleMessage("Infos"),
        "settingsAboutText": MessageLookupByLibrary.simpleMessage(
            "Une application pour tester la lisibilité et la compréhension des textes"),
        "settingsAddApi":
            MessageLookupByLibrary.simpleMessage("Ajouter un API"),
        "settingsApiDate": m3,
        "settingsApiHeading": MessageLookupByLibrary.simpleMessage("APIs"),
        "settingsDeleteApi":
            MessageLookupByLibrary.simpleMessage("Supprimer l\'API"),
        "settingsDeleteApiDialogTitle":
            MessageLookupByLibrary.simpleMessage("Veux-tu supprimer l\'API ?"),
        "settingsPageTitle": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "settingsResetTutorial":
            MessageLookupByLibrary.simpleMessage("Relancer le tutoriel"),
        "settingsResetTutorialDialogTitle":
            MessageLookupByLibrary.simpleMessage(
                "Veux-tu relancer le tutoriel ?"),
        "settingsShowCompletedExperiments":
            MessageLookupByLibrary.simpleMessage(
                "Afficher les expérimentations terminées"),
        "settingsTutorialHeading":
            MessageLookupByLibrary.simpleMessage("Tutoriel"),
        "taskAbortDialogTitle":
            MessageLookupByLibrary.simpleMessage("Veux-tu vraiment annuler ?"),
        "taskAdvance": MessageLookupByLibrary.simpleMessage("SUITE"),
        "taskFinish": MessageLookupByLibrary.simpleMessage("TERMINER"),
        "taskLexicalDecisionNonword":
            MessageLookupByLibrary.simpleMessage("PAS DE MOT"),
        "taskLexicalDecisionWord": MessageLookupByLibrary.simpleMessage("MOT"),
        "taskPracticeIndicatorSubtitle": MessageLookupByLibrary.simpleMessage(
            "Cette tache n\'est pas prise en compte"),
        "taskPracticeIndicatorTitle":
            MessageLookupByLibrary.simpleMessage("EXERCICE"),
        "taskQuestionAnsweringExpandQuestions":
            MessageLookupByLibrary.simpleMessage("Répondre aux questions"),
        "taskReactionTimeIntro":
            MessageLookupByLibrary.simpleMessage("Éclate le ballon !"),
        "taskReadingCorrect": MessageLookupByLibrary.simpleMessage("CORRECT"),
        "taskReadingCorrectionDialogText": MessageLookupByLibrary.simpleMessage(
            "Corrige tes réponses, s\'il te plaît."),
        "taskReadingCorrectionDialogTitle": m4,
        "taskReadingIncorrect": MessageLookupByLibrary.simpleMessage("FAUX"),
        "taskResultsFinishExperiment":
            MessageLookupByLibrary.simpleMessage("TERMINER L\'EXPERIMENTATION"),
        "taskResultsMessage1": MessageLookupByLibrary.simpleMessage("Super !"),
        "taskResultsMessage2": MessageLookupByLibrary.simpleMessage("Bravo !"),
        "taskResultsMessage3":
            MessageLookupByLibrary.simpleMessage("Beau travail !"),
        "taskResultsNextTask":
            MessageLookupByLibrary.simpleMessage("TACHE SUIVANTE"),
        "taskResultsNextTaskCounts": MessageLookupByLibrary.simpleMessage(
            "La prochaine tache sera prise en compte !"),
        "taskResultsNoNextTask":
            MessageLookupByLibrary.simpleMessage("PLUS TARD"),
        "taskResultsRepeatPracticeTask":
            MessageLookupByLibrary.simpleMessage("RÉPÉTER L\'EXERCICE"),
        "taskResultsSecondsTaken": m5,
        "taskRotateLandscape": MessageLookupByLibrary.simpleMessage(
            "Fais pivoter ton téléphone en mode paysage"),
        "taskRotatePortrait": MessageLookupByLibrary.simpleMessage(
            "Fais pivoter ton téléphone en mode portrait"),
        "taskTrailMakingStart":
            MessageLookupByLibrary.simpleMessage("COMMENCER"),
        "tutorialName": MessageLookupByLibrary.simpleMessage("Tutoriel")
      };
}
