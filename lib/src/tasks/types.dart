import 'package:flutter/material.dart';
import 'package:okra/src/tasks/lexical_decision.dart';

import 'cloze.dart';
import 'picture_naming.dart';
import 'question_answering.dart';
import 'task.dart';

typedef TaskFactory<T extends Task> = T Function();

@immutable
class TaskType {
  final IconData icon;
  final TaskFactory taskFactory;
  final Orientation forceOrientation;

  TaskType(this.icon, this.taskFactory, {this.forceOrientation});

  static final TaskType cloze = TaskType(
    Icons.assignment,
    () => Cloze(),
  );
  static final TaskType lexicalDecision = TaskType(
    Icons.spellcheck,
    () => LexicalDecision(),
  );
  static final TaskType pictureNaming = TaskType(
    Icons.photo,
    () => PictureNaming(),
    forceOrientation: Orientation.portrait,
  );
  static final TaskType questionAnswering = TaskType(
    Icons.question_answer,
    () => QuestionAnswering(),
  );

  static TaskType fromString(String identifier) {
    switch (identifier) {
      case 'cloze':
        return cloze;
      case 'lexical-decision':
        return lexicalDecision;
      case 'picture-naming':
        return pictureNaming;
      case 'question-answering':
        return questionAnswering;
      default:
        throw ArgumentError('Task type "$identifier" is not implemented');
    }
  }
}
