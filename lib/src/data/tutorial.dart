import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../tasks/types.dart';
import 'api.dart';
import 'models.dart';
import 'storage.dart';

class _TutorialExperiment {
  final TutorialApi api;
  final String id;
  final TaskType type;
  final String title;
  final String instructions;
  final List<TaskRating> ratings;
  final List<TaskData> tasks;
  int progress;

  _TutorialExperiment(this.api, this.id,
      {@required this.type,
      @required this.title,
      @required this.instructions,
      @required this.ratings,
      @required this.tasks,
      @required this.progress});

  Experiment toExperiment() {
    return Experiment(
      api,
      id,
      type: type,
      title: title,
      coverImageUrl: null,
      instructions: instructions,
      instructionsAudioUrl: null,
      nTasks: tasks.length,
      nTasksDone: progress,
      hasPracticeTask: false,
      ratings: ratings,
    );
  }

  bool hasTask(String taskId) {
    return tasks.where((task) => task.id == taskId).isNotEmpty;
  }
}

class TutorialApi extends Api {
  final Storage storage;
  Map<String, _TutorialExperiment> _experiments;

  TutorialApi(this.storage, [Map<String, int> progress]) {
    progress ??= {};
    // TODO: Translate
    _experiments = {
      '1': _TutorialExperiment(
        this,
        '1',
        type: TaskType.questionAnswering,
        title: 'What is Okra?',
        instructions: '''
# What you will learn in this tutorial:

- What is Okra and what is it for?
- What types of experiments does it include?
- How can you participate in experiments?

The tutorial itself is framed as a reading task, so you can see how it's going
to work. You will read a text sentence by sentence. **Tap the screen to advance
to the next sentence.**

## Press the button below to start!
          ''',
        ratings: [
          TaskRating(
            'How difficult was the text?',
            TaskRatingType.slider,
            lowExtreme: 'easy',
            highExtreme: 'hard',
          ),
          TaskRating(
            'How difficult were the questions?',
            TaskRatingType.slider,
            lowExtreme: 'easy',
            highExtreme: 'hard',
          ),
          TaskRating(
            'How much did you enjoy reading the text?',
            TaskRatingType.emoticon,
          ),
        ],
        progress: progress['1'] ?? 0,
        tasks: [
          TaskData(
            '1',
            {
              'readingType': 'self-paced',
              'text': 'Using Okra, we want to discover how easy texts are for humans to read,\n'
                  'and which parts of language are more difficult to process and understand.\n'
                  'This is important to know for authors and translators to write simpler texts.\n'
                  'It is also relevant for linguists and scientists working with text simplification.\n'
                  'To find out these things, we can show texts to humans and observe how they read them,\n'
                  'let them solve specific tasks, or just ask them questions about the texts.\n'
                  '\n'
                  'In Okra, you can participate in experiments like these,\n'
                  'and help us understand better how different humans read texts.\n'
                  'Right now, you are solving a task called “self-paced reading”.\n'
                  'By reading at the speed you are most comfortable with,\n'
                  'you can help us find out which parts of this text are easier or more difficult.\n'
                  'Other tasks could be: multiple-choice comprehension questions,\n'
                  'quizzes with words and pictures, fill-in-the-blank texts, and many more.\n'
                  '\n'
                  'If you have installed Okra, somebody probably already gave a QR code to register.\n'
                  'To start solving tasks, you need to scan this QR code in Okra first.\n'
                  'If you have any questions, ask the person who gave you the QR code!\n'
                  '\n'
                  'You are almost at the end of this tutorial!\n'
                  'Now, we want ask you a few questions about the text you just read,\n'
                  'and get your opinion on how easy this text was to read.\n',
              'questions': [
                {
                  'question': 'What is the task called you just completed?',
                  'answers': [
                    'fill-in-the-blanks',
                    'self-paced reading',
                    'text simplification',
                    'attention-based reading',
                  ],
                },
                {
                  'question': 'What do you have to do to get started?',
                  'answers': [
                    'Draw a QR code on your phone',
                    'Read a text and say how difficult it was',
                    'Fill in the registration forms',
                    'Scan the QR code',
                  ],
                },
                {
                  'question':
                      'Who could be interested in knowing about the difficulty of a text?',
                  'answers': [
                    'Translators, authors and scientists',
                    'Students, teachers and tutors',
                    'Parents and friends',
                    'Programmers, engineers and technicians',
                  ],
                },
              ],
            },
          ),
        ],
      ),
    };
  }

  static TutorialApi fromJson(Map<String, dynamic> json, Storage storage) {
    return TutorialApi(
      storage,
      Map<String, int>.from(json['progress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'progress': _experiments.map<String, dynamic>(
          (id, experiment) => MapEntry(id, experiment.progress))
    };
  }

  @override
  String getName() {
    return S.current.tutorialName;
  }

  @override
  Image getIcon() {
    return null;
  }

  @override
  Future<List<Experiment>> getExperiments() async {
    return _experiments.values
        .map((experiment) => experiment.toExperiment())
        .toList();
  }

  @override
  Future<Experiment> getExperiment(String experimentId) async {
    return _experiments[experimentId].toExperiment();
  }

  @override
  Future<TaskData> startTask(String experimentId, {bool practice = false}) async {
    var taskId = _experiments[experimentId].progress;
    return _experiments[experimentId].tasks[taskId];
  }

  @override
  Future<void> finishTask(String taskId, TaskResults results) async {
    var experiment = _experiments.values
        .firstWhere((experiment) => experiment.hasTask(taskId));
    experiment.progress++;
    storage.saveTutorial();
  }

  void resetProgress() {
    for (var experiment in _experiments.values) {
      experiment.progress = 0;
    }
  }

  bool isResettable() {
    return _experiments.values.any((experiment) => experiment.progress > 0);
  }
}
