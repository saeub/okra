import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';

import '../../generated/l10n.dart';
import '../colors.dart';
import '../data/models.dart';
import '../tasks/task.dart';
import '../tasks/types.dart';
import '../util.dart';

enum TaskPageMode {
  instructions,
  task,
  ratings,
  results,
}

class TaskPage extends StatefulWidget {
  final Experiment experiment;

  const TaskPage(this.experiment, {Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TaskPageMode _mode;
  String? _taskId;
  late TaskEventLogger _logger;
  TaskResults? _results;
  late bool _practicing;
  Future<TaskData>? _taskFuture;
  Future<void>? _taskFinishedFuture;

  @override
  void initState() {
    super.initState();
    _mode = TaskPageMode.instructions;
  }

  void startTask(bool practicing) {
    setState(() {
      _mode = TaskPageMode.task;
      _taskId = null;
      _logger = TaskEventLogger();
      _results = null;
      _practicing = practicing;
      _taskFuture = widget.experiment.api
          .startTask(widget.experiment.id, practice: _practicing);
      _taskFinishedFuture = null;
    });
  }

  void startRatings() {
    setState(() {
      _mode = TaskPageMode.ratings;
    });
  }

  void finishTask() {
    setState(() {
      _taskFinishedFuture = widget.experiment.api.finishTask(
        _taskId!,
        _results!,
      );
      _mode = TaskPageMode.results;
    });
    _taskFinishedFuture!.then((_) {
      setState(() {
        _mode = TaskPageMode.results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Refactor into several widgets to avoid modes and excessive non-null assertions
    Widget content;
    switch (_mode) {
      case TaskPageMode.instructions:
        content = InstructionsWidget(
          experiment: widget.experiment,
          onStartPressed: () {
            startTask(false);
          },
          onStartPracticePressed: () {
            startTask(true);
          },
        );
        break;

      case TaskPageMode.task:
        content = FutureBuilder<TaskData>(
          future: _taskFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_taskFinishedFuture == null) {
                return TaskWidget(
                  widget.experiment.type.taskFactory,
                  snapshot.data!.data,
                  _logger,
                  ({data, message}) {
                    _logger.stopwatch.stop();
                    _taskId = snapshot.data!.id;
                    _results = TaskResults(
                      data: data,
                      events: _logger.events,
                      message: message,
                    );
                    var ratings = widget.experiment.ratings;
                    if (ratings != null && ratings.isNotEmpty && !_practicing) {
                      startRatings();
                    } else {
                      finishTask();
                    }
                  },
                  practice: _practicing,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            } else if (snapshot.hasError) {
              return Center(
                child: ErrorMessage(
                  S.of(context).errorGeneric(snapshot.error!),
                  retry: () => startTask(_practicing),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
        break;

      case TaskPageMode.ratings:
        content = RatingsWidget(
          widget.experiment.ratings!,
          onFinished: (answers) {
            _results!.ratingAnswers = answers;
            finishTask();
          },
        );
        break;

      case TaskPageMode.results:
        content = FutureBuilder(
          future: _taskFinishedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              return ResultsWidget(
                experiment: widget.experiment,
                message: _results!.message,
                practice: _practicing,
                onContinuePressed: () => startTask(false),
                onRepeatPracticePressed: () => startTask(true),
              );
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasError) {
              return Center(
                child: ErrorMessage(
                  S.of(context).errorGeneric(snapshot.error!),
                  retry: () => finishTask(),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
        break;
    }

    return Scaffold(
      appBar: (_mode == TaskPageMode.instructions)
          ? AppBar(title: Text(widget.experiment.title))
          : null,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (_mode == TaskPageMode.task || _mode == TaskPageMode.ratings) {
              _logger.log('aborting task');
              return await showDialog<bool>(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(S.of(context).taskAbortDialogTitle),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _logger.log('declined aborting task');
                            Navigator.of(context).pop(false);
                          },
                          child: Text(S.of(context).dialogNo),
                        ),
                        TextButton(
                          onPressed: () {
                            _logger.log('confirmed aborting task');
                            Navigator.of(context).pop(true);
                            // TODO: Send aborted task
                          },
                          child: Text(S.of(context).dialogYes),
                        ),
                      ],
                    ),
                  ) ??
                  false;
            } else {
              return true;
            }
          },
          child: OrientationBuilder(builder: (context, orientation) {
            var forceOrientation = widget.experiment.type.forceOrientation;
            if (forceOrientation != null && orientation != forceOrientation) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.screen_rotation,
                      size: 50.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(forceOrientation == Orientation.portrait
                          ? S.of(context).taskRotatePortrait
                          : S.of(context).taskRotateLandscape),
                    ),
                  ],
                ),
              );
            }
            return content;
          }),
        ),
      ),
    );
  }
}

class ReadAloudWidget extends StatefulWidget {
  final String audioUrl;

  const ReadAloudWidget(this.audioUrl, {Key? key}) : super(key: key);

  @override
  _ReadAloudWidgetState createState() => _ReadAloudWidgetState();
}

class _ReadAloudWidgetState extends State<ReadAloudWidget> {
  late bool _playing;
  late AudioPlayer _player;
  late Future<void> _loadingFuture;

  Future<void> loadAudio() async {
    await _player.setUrl(widget.audioUrl);
  }

  @override
  void initState() {
    super.initState();
    _playing = false;
    _player = AudioPlayer();
    _loadingFuture = loadAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return TextButton.icon(
            icon: Icon(_playing ? Icons.stop : Icons.volume_up),
            label: Text(_playing
                ? S.of(context).instructionsStopAudio
                : S.of(context).instructionsStartAudio),
            onPressed: () {
              setState(() {
                if (_playing) {
                  _playing = false;
                  _player.stop();
                } else {
                  _playing = true;
                  _player.play().then((_) {
                    setState(() {
                      _playing = false;
                      _player.stop();
                    });
                  });
                }
              });
            },
          );
        } else if (snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: ErrorMessage(
              S.of(context).instructionsLoadingAudioFailed,
              retry: () {
                setState(() {
                  _loadingFuture = loadAudio();
                });
              },
            ),
          );
        } else {
          return TextButton.icon(
            icon: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).iconTheme.color),
              ),
            ),
            label: Text(S.of(context).instructionsStartAudio),
            onPressed: null,
          );
        }
      },
    );
  }
}

class InstructionsWidget extends StatelessWidget {
  final Experiment experiment;
  final VoidCallback onStartPressed;
  final VoidCallback? onStartPracticePressed;

  const InstructionsWidget(
      {required this.experiment,
      required this.onStartPressed,
      this.onStartPracticePressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var audioUrl = experiment.instructionsAudioUrl;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ReadingWidth(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    S.of(context).instructionsTitle,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                if (audioUrl != null) ReadAloudWidget(audioUrl),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: MarkdownBody(
                    data: experiment.instructions,
                    fitContent: false,
                    styleSheet: MarkdownStyleSheet(
                      textScaleFactor: 1.3,
                      p: const TextStyle(height: 1.5),
                    ),
                  ),
                ),
                if (experiment.hasPracticeTask && experiment.nTasksDone == 0)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.sports_tennis),
                    label: Text(S.of(context).instructionsStartPracticeTask),
                    onPressed: onStartPracticePressed,
                  )
                else if (experiment.hasPracticeTask)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.sports_tennis),
                        label:
                            Text(S.of(context).instructionsRestartPracticeTask),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.secondary),
                        ),
                        onPressed: onStartPracticePressed,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(S.of(context).instructionsStartTask),
                        onPressed: onStartPressed,
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(S.of(context).instructionsStartTask),
                    onPressed: onStartPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskWidget extends StatefulWidget {
  final TaskFactory taskFactory;
  final Map<String, dynamic> data;
  final TaskEventLogger logger;
  final FinishCallback onFinished;
  final bool practice;

  const TaskWidget(this.taskFactory, this.data, this.logger, this.onFinished,
      {this.practice = false, Key? key})
      : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  late Task _task;
  late Future<void> _taskLoadingFuture;

  @override
  void initState() {
    super.initState();
    _task = widget.taskFactory();
    _task.injectDependencies(widget.logger, setState, widget.onFinished);
    _task.init(widget.data);
    _taskLoadingFuture = _task.loadAssets();
    // TODO: Add a Task.start() method which is called as soon as everything is ready
    // (and maybe replace Task.init()?)
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _taskLoadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          var backgroundColor = _task.backgroundColor;
          var practiceIndicatorColor =
              (backgroundColor?.computeLuminance() ?? 1.0) < 0.5
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary;
          var progress = _task.getProgress();
          var content = Column(
            children: [
              if (progress != null) AnimatedLinearProgressIndicator(progress),
              if (widget.practice)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.sports_tennis,
                              size: 30.0,
                              color: practiceIndicatorColor,
                            ),
                          ),
                          Text(
                            S.of(context).taskPracticeIndicatorTitle,
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              color: practiceIndicatorColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        S.of(context).taskPracticeIndicatorSubtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: practiceIndicatorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              Flexible(child: _task.build(context)),
            ],
          );
          if (backgroundColor != null) {
            return ColoredBox(color: backgroundColor, child: content);
          }
          return content;
        } else if (snapshot.hasError) {
          return Center(
            child: ErrorMessage(
              S.of(context).errorGeneric(snapshot.error!),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class RatingsWidget extends StatefulWidget {
  final List<TaskRating> ratings;
  final void Function(List<num> answers) onFinished;

  const RatingsWidget(this.ratings, {required this.onFinished, Key? key})
      : super(key: key);

  @override
  _RatingsWidgetState createState() => _RatingsWidgetState();
}

class _RatingsWidgetState extends State<RatingsWidget> {
  late int _currentRatingIndex;
  late List<num?> _answers;

  @override
  void initState() {
    super.initState();
    _currentRatingIndex = 0;
    _answers = [
      for (var rating in widget.ratings)
        rating.type == TaskRatingType.slider ? 0.5 : null
    ];
  }

  @override
  Widget build(BuildContext context) {
    var rating = widget.ratings[_currentRatingIndex];
    Widget inputWidget;

    switch (rating.type) {
      case TaskRatingType.emoticon:
        inputWidget = _getEmoticons();
        break;

      case TaskRatingType.emoticonReversed:
        inputWidget = _getEmoticons(reversed: true);
        break;

      case TaskRatingType.radio:
        inputWidget = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < TaskRating.radioLevels; i++)
              Radio<num>(
                value: i,
                groupValue: _answers[_currentRatingIndex],
                onChanged: (value) {
                  setState(() {
                    _answers[_currentRatingIndex] = value;
                  });
                },
              ),
          ],
        );
        break;

      case TaskRatingType.slider:
        inputWidget = Slider(
          value: _answers[_currentRatingIndex]!.toDouble(),
          onChanged: (value) {
            setState(() {
              _answers[_currentRatingIndex] = value;
            });
          },
        );
        break;
    }

    return Column(
      children: [
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      rating.question,
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  inputWidget,
                  if (rating.lowExtreme != null || rating.highExtreme != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rating.lowExtreme ?? ''),
                          Text(rating.highExtreme ?? ''),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
        ElevatedButton.icon(
          icon: const Icon(Icons.arrow_forward),
          label: Text(S.of(context).taskAdvance),
          onPressed: _answers[_currentRatingIndex] != null
              ? () {
                  if (_currentRatingIndex < widget.ratings.length - 1) {
                    setState(() {
                      _currentRatingIndex++;
                    });
                  } else {
                    widget.onFinished(_answers.cast<num>());
                  }
                }
              : null,
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Color _getEmoticonColor(int index, int variant) {
    return Color.lerp(
      AppColors.negative[variant]!,
      AppColors.positive[variant]!,
      index / (TaskRating.emoticons.length - 1),
    )!;
  }

  Widget _getEmoticons({bool reversed = false}) {
    var emoticonIndices = [
      for (var i = 0; i < TaskRating.emoticons.length; i++) i
    ];
    if (reversed) {
      emoticonIndices = emoticonIndices.reversed.toList();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < emoticonIndices.length; i++)
          IconButton(
            icon: DecoratedBox(
              decoration: _answers[_currentRatingIndex] == i
                  ? BoxDecoration(
                      border: Border.all(
                          color: _getEmoticonColor(emoticonIndices[i], 900),
                          width: 6.0),
                      borderRadius: BorderRadius.circular(20.0),
                      color: _getEmoticonColor(emoticonIndices[i], 200),
                    )
                  : const BoxDecoration(),
              child: Icon(TaskRating.emoticons[emoticonIndices[i]]),
            ),
            iconSize: 40.0,
            color: _getEmoticonColor(emoticonIndices[i],
                _answers[_currentRatingIndex] == i ? 900 : 700),
            onPressed: () {
              setState(() {
                _answers[_currentRatingIndex] = i;
              });
            },
          ),
      ],
    );
  }
}

class ResultsWidget extends StatefulWidget {
  final Experiment experiment;
  final String? message;
  final bool practice;
  final VoidCallback onContinuePressed;
  final VoidCallback? onRepeatPracticePressed;

  const ResultsWidget({
    required this.experiment,
    this.message,
    this.practice = false,
    required this.onContinuePressed,
    this.onRepeatPracticePressed,
    Key? key,
  }) : super(key: key);

  @override
  _ResultsWidgetState createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  late String _message;
  late Future<Experiment> _experimentFuture;

  /// Reload and return the experiment for checking the new `nTasksDone`
  Future<Experiment> loadUpdatedExperiment() {
    return widget.experiment.api.getExperiment(widget.experiment.id);
  }

  @override
  void initState() {
    super.initState();
    var defaultMessages = <String>[
      S.current.taskResultsMessage1,
      S.current.taskResultsMessage2,
      S.current.taskResultsMessage3,
    ];
    _message = widget.message ??
        defaultMessages[Random().nextInt(defaultMessages.length)];
    _experimentFuture = loadUpdatedExperiment();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Text(
              _message,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Spacer(flex: 1),
            FutureBuilder<Experiment>(
              future: _experimentFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.nTasksDone < snapshot.data!.nTasks) {
                    // Still tasks left
                    return Column(
                      children: [
                        if (widget.practice)
                          Text(S.of(context).taskResultsNextTaskCounts,
                              style: Theme.of(context).textTheme.headline6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.schedule),
                                label:
                                    Text(S.of(context).taskResultsNoNextTask),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<
                                          Color>(
                                      Theme.of(context).colorScheme.secondary),
                                ),
                                onPressed: Navigator.of(context).pop,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(S.of(context).taskResultsNextTask),
                                onPressed: widget.onContinuePressed,
                              ),
                            ),
                          ],
                        ),
                        if (widget.practice)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.sports_tennis),
                              label: Text(
                                  S.of(context).taskResultsRepeatPracticeTask),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    Theme.of(context).colorScheme.secondary),
                              ),
                              onPressed: widget.onRepeatPracticePressed,
                            ),
                          ),
                      ],
                    );
                  } else {
                    // No tasks left
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(S.of(context).taskResultsFinishExperiment),
                      onPressed: Navigator.of(context).pop,
                    );
                  }
                } else if (snapshot.hasError) {
                  return ErrorMessage(
                    S.of(context).errorGeneric(snapshot.error!),
                    retry: () {
                      setState(() {
                        _experimentFuture = loadUpdatedExperiment();
                      });
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
