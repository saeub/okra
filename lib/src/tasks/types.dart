import 'package:flutter/material.dart';
import 'lexical_decision.dart';
import 'reaction_time.dart';

import 'cloze.dart';
import 'n_back.dart';
import 'picture_naming.dart';
import 'simon_game.dart';
import 'reading.dart';
import 'digit_span.dart';
import 'task.dart';
import 'trail_making.dart';

typedef TaskFactory<T extends Task> = T Function();

@immutable
class TaskType {
  final IconData icon;
  final TaskFactory taskFactory;
  final Orientation? forceOrientation;

  const TaskType(this.icon, this.taskFactory, {this.forceOrientation});

  static final TaskType cloze = TaskType(
    Icons.description,
    () => Cloze(),
  );
  static final TaskType digitSpan = TaskType(
    Icons.pin,
    () => DigitSpan(),
  );
  static final TaskType lexicalDecision = TaskType(
    Icons.spellcheck,
    () => LexicalDecision(),
  );
  static final TaskType nBack = TaskType(
    Icons.psychology,
    () => NBack(),
  );
  static final TaskType pictureNaming = TaskType(
    Icons.photo,
    () => PictureNaming(),
    forceOrientation: Orientation.portrait,
  );
  static final TaskType reactionTime = TaskType(
    Icons.offline_bolt,
    () => ReactionTime(),
    // TODO: Lock initial orientation instead of enforcing one
    // (balloons can go off-screen when rotating device)
  );
  static final TaskType reading = TaskType(
    Icons.abc,
    () => Reading(),
  );
  static final TaskType simonGame = TaskType(
    Icons.grid_view,
    () => SimonGame(),
  );
  static final TaskType trailMaking = TaskType(
    Icons.scatter_plot,
    () => TrailMaking(),
  );

  static TaskType fromString(String identifier) {
    switch (identifier) {
      case 'cloze':
        return cloze;
      case 'digit-span':
        return digitSpan;
      case 'lexical-decision':
        return lexicalDecision;
      case 'n-back':
        return nBack;
      case 'picture-naming':
        return pictureNaming;
      case 'reaction-time':
        return reactionTime;
      case 'reading':
        return reading;
      case 'simon-game':
        return simonGame;
      case 'trail-making':
        return trailMaking;
      default:
        throw ArgumentError('Task type "$identifier" is not implemented');
    }
  }
}
