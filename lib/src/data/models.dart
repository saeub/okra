import 'package:flutter/material.dart';

import '../tasks/types.dart';
import 'api.dart';

@immutable
class Experiment {
  final Api api;
  final String id;
  final TaskType type;
  final String title, instructions;
  final String? coverImageUrl, instructionsAudioUrl;
  final int nTasks, nTasksDone;
  final bool hasPracticeTask;
  final List<TaskRating>? ratings;

  Experiment(this.api, this.id,
      {required this.type,
      required this.title,
      this.coverImageUrl,
      required this.instructions,
      this.instructionsAudioUrl,
      required this.nTasks,
      required this.nTasksDone,
      required this.hasPracticeTask,
      this.ratings});

  static Experiment fromJson(Api api, Map<String, dynamic> json) {
    List<Map<String, dynamic>>? ratingsData =
        json['ratings']?.cast<Map<String, dynamic>>();
    return Experiment(
      api,
      json['id'],
      type: TaskType.fromString(json['type']),
      title: json['title'],
      coverImageUrl: json['coverImageUrl'],
      instructions: json['instructions'],
      instructionsAudioUrl: json['instructionsAudioUrl'],
      nTasks: json['nTasks'],
      nTasksDone: json['nTasksDone'],
      hasPracticeTask: json['hasPracticeTask'],
      ratings: ratingsData?.map(TaskRating.fromJson).toList(),
    );
  }
}

@immutable
class TaskData {
  final String id;
  final Map<String, dynamic> data;

  TaskData(this.id, this.data);

  static TaskData fromJson(Map<String, dynamic> json) {
    return TaskData(
      json['id'],
      json['data'],
    );
  }
}

@immutable
class TaskRating {
  static const Map<String, TaskRatingType> typeMap = {
    'emoticon': TaskRatingType.emoticon,
    'emoticon-reversed': TaskRatingType.emoticonReversed,
    'radio': TaskRatingType.radio,
    'slider': TaskRatingType.slider,
  };

  /// Icons used for `emoticon` type ratings
  static const List<IconData> emoticons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  /// Number of levels for `radio` type ratings
  static const int radioLevels = 5;

  final String question;
  final TaskRatingType type;
  final String? lowExtreme, highExtreme;

  TaskRating(this.question, this.type, {this.lowExtreme, this.highExtreme});

  static TaskRating fromJson(Map<String, dynamic> json) {
    var type = typeMap[json['type']];
    if (type == null) {
      throw ArgumentError('Unknown rating type "${json['type']}"');
    }
    return TaskRating(
      json['question'],
      type,
      lowExtreme: json['lowExtreme'],
      highExtreme: json['highExtreme'],
    );
  }
}

enum TaskRatingType {
  emoticon,
  emoticonReversed,
  radio,
  slider,
}

class TaskResults {
  Map<String, dynamic>? data;
  List<TaskEvent> events;
  String? message;
  List<num>? ratingAnswers;

  TaskResults({
    this.data,
    this.events = const [],
    this.message,
    this.ratingAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'events': events.map((event) => event.toJson()).toList(),
      'message': message,
      'ratingAnswers': ratingAnswers,
    };
  }
}

@immutable
class TaskEvent {
  final DateTime time;
  final String label;
  final Map<String, dynamic>? data;

  TaskEvent(this.time, this.label, [this.data]);

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'label': label,
      'data': data,
    };
  }
}
