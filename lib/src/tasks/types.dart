import 'package:flutter/material.dart';

import 'cloze.dart';
import 'picture_naming.dart';
import 'question_answering.dart';
import 'task.dart';

typedef TaskFactory<T extends Task> = T Function(
    Map<String, dynamic> data, TaskEventLogger logger);

@immutable
class TaskType {
  final IconData icon;
  final TaskFactory taskFactory;
  final Orientation forceOrientation;

  TaskType(this.icon, this.taskFactory, {this.forceOrientation});

  static final TaskType cloze = TaskType(
    Icons.assignment,
    (data, logger) => Cloze(data, logger),
  );
  static final TaskType pictureNaming = TaskType(
    Icons.photo,
    (data, logger) => PictureNaming(data, logger),
    forceOrientation: Orientation.portrait,
  );
  static final TaskType questionAnswering = TaskType(
    Icons.question_answer,
    (data, logger) => QuestionAnswering(data, logger),
  );

  static TaskType fromString(String identifier) {
    switch (identifier) {
      case 'cloze':
        return cloze;
      case 'picture-naming':
        return pictureNaming;
      case 'question-answering':
        return questionAnswering;
      default:
        throw ArgumentError('Task type "$identifier" is not implemented');
    }
  }
}
