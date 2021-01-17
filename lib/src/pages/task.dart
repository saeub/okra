import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';

import '../../generated/l10n.dart';
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

  TaskPage(this.experiment);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TaskPageMode _mode;
  String _taskId;
  TaskEventLogger _logger;
  TaskResults _results;
  Future<TaskData> _taskFuture;
  Future<void> _taskFinishedFuture;

  @override
  void initState() {
    super.initState();
    _mode = TaskPageMode.instructions;
  }

  void startTask() {
    setState(() {
      _mode = TaskPageMode.task;
      _taskId = null;
      _logger = TaskEventLogger();
      _results = null;
      _taskFuture = widget.experiment.api.startTask(widget.experiment.id);
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
        _taskId,
        _results,
      );
    });
    _taskFinishedFuture.then((_) {
      setState(() {
        _mode = TaskPageMode.results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_mode) {
      case TaskPageMode.instructions:
        content = InstructionsWidget(
          text: widget.experiment.instructions,
          audioUrl: widget.experiment.instructionsAudioUrl,
          onStartPressed: startTask,
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
                  snapshot.data.data,
                  _logger,
                  ({data, message}) {
                    _logger.stopwatch.stop();
                    _taskId = snapshot.data.id;
                    _results = TaskResults(
                      data: data,
                      events: _logger.events,
                      message: message,
                    );
                    if (widget.experiment.ratings != null &&
                        widget.experiment.ratings.isNotEmpty) {
                      startRatings();
                    } else {
                      finishTask();
                    }
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            } else if (snapshot.hasError) {
              return Center(
                child: ErrorMessage(
                  S.of(context).errorGeneric(snapshot.error),
                  retry: () {
                    setState(() {
                      _taskFuture =
                          widget.experiment.api.startTask(widget.experiment.id);
                    });
                  },
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
        break;

      case TaskPageMode.ratings:
        content = RatingsWidget(
          widget.experiment.ratings,
          onFinished: (answers) {
            _results.ratingAnswers = answers;
            finishTask();
          },
        );
        break;

      case TaskPageMode.results:
        content = ResultsWidget(
          experiment: widget.experiment,
          message: _results.message,
          onContinuePressed: startTask,
        );
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          child: OrientationBuilder(builder: (context, orientation) {
            var forceOrientation = widget.experiment.type.forceOrientation;
            if (forceOrientation != null && orientation != forceOrientation) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
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
          onWillPop: () async {
            if (_mode == TaskPageMode.task || _mode == TaskPageMode.ratings) {
              _logger.log('aborting task');
              return await showDialog<bool>(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(S.of(context).taskAbortDialogTitle),
                  actions: [
                    FlatButton(
                      child: Text(S.of(context).dialogNo),
                      onPressed: () {
                        _logger.log('declined aborting task');
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text(S.of(context).dialogYes),
                      onPressed: () {
                        _logger.log('confirmed aborting task');
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              );
            } else {
              return true;
            }
          },
        ),
      ),
    );
  }
}

class ReadAloudWidget extends StatefulWidget {
  final String audioUrl;

  const ReadAloudWidget(this.audioUrl, {Key key}) : super(key: key);

  @override
  _ReadAloudWidgetState createState() => _ReadAloudWidgetState();
}

class _ReadAloudWidgetState extends State<ReadAloudWidget> {
  bool _playing;
  AudioPlayer _player;
  Future<Duration> _loadingFuture;

  Future<Duration> loadAudio() async {
    return _player.setUrl(widget.audioUrl);
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
          return FlatButton.icon(
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
          return FlatButton.icon(
            icon: Container(
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
  final String text;
  final String audioUrl;
  final VoidCallback onStartPressed;

  const InstructionsWidget(
      {this.text, this.audioUrl, this.onStartPressed, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Center(
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
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: MarkdownBody(
                  data: text,
                  fitContent: false,
                ),
              ),
              AccentButton(
                Icons.arrow_forward,
                S.of(context).instructionsStartTask,
                onPressed: onStartPressed,
              ),
            ],
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

  const TaskWidget(this.taskFactory, this.data, this.logger, this.onFinished,
      {Key key})
      : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.taskFactory(widget.data, widget.logger);
    _task.setState = setState;
    _task.finish = widget.onFinished;
  }

  @override
  Widget build(BuildContext context) {
    return _task.build(context);
  }
}

class RatingsWidget extends StatefulWidget {
  final List<TaskRating> ratings;
  final void Function(List<num> answers) onFinished;

  const RatingsWidget(this.ratings, {this.onFinished, Key key})
      : super(key: key);

  @override
  _RatingsWidgetState createState() => _RatingsWidgetState();
}

class _RatingsWidgetState extends State<RatingsWidget> {
  int _currentRatingIndex;
  List<num> _answers;

  static Color getEmoticonColor(int index, int variant) {
    return HSVColor.lerp(
      HSVColor.fromColor(Colors.red[variant]),
      HSVColor.fromColor(Colors.green[variant]),
      index / TaskRating.emoticons.length,
    ).toColor();
  }

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                rating.question,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              if (rating.type == TaskRatingType.emoticon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < TaskRating.emoticons.length; i++)
                      IconButton(
                        icon: DecoratedBox(
                          decoration: _answers[_currentRatingIndex] == i
                              ? BoxDecoration(
                                  border: Border.all(
                                      color: getEmoticonColor(i, 900),
                                      width: 4.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: getEmoticonColor(i, 200),
                                )
                              : BoxDecoration(),
                          child: Icon(TaskRating.emoticons[i]),
                        ),
                        iconSize: 40.0,
                        color: getEmoticonColor(
                            i, _answers[_currentRatingIndex] == i ? 900 : 700),
                        onPressed: () {
                          setState(() {
                            _answers[_currentRatingIndex] = i;
                          });
                        },
                      ),
                  ],
                )
              else if (rating.type == TaskRatingType.radio)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < TaskRating.radioLevels; i++)
                      Radio(
                        value: i,
                        groupValue: _answers[_currentRatingIndex],
                        onChanged: (value) {
                          setState(() {
                            _answers[_currentRatingIndex] = value;
                          });
                        },
                      ),
                  ],
                )
              else if (rating.type == TaskRatingType.slider)
                Slider(
                  value: _answers[_currentRatingIndex],
                  onChanged: (value) {
                    setState(() {
                      _answers[_currentRatingIndex] = value;
                    });
                  },
                ),
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
        AccentButton(
          Icons.arrow_forward,
          S.of(context).taskAdvance,
          onPressed: _answers[_currentRatingIndex] != null
              ? () {
                  if (_currentRatingIndex < widget.ratings.length - 1) {
                    setState(() {
                      _currentRatingIndex++;
                    });
                  } else {
                    widget.onFinished(_answers);
                  }
                }
              : null,
        ),
      ],
    );
  }
}

class ResultsWidget extends StatefulWidget {
  final Experiment experiment;
  final String message;
  final VoidCallback onContinuePressed;

  const ResultsWidget({
    this.experiment,
    this.message,
    this.onContinuePressed,
    Key key,
  }) : super(key: key);

  @override
  _ResultsWidgetState createState() => _ResultsWidgetState();
}

class _ResultsWidgetState extends State<ResultsWidget> {
  String _message;
  Future<Experiment> _experimentFuture;

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
            Spacer(flex: 2),
            Text(
              _message,
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).accentColor,
              ),
            ),
            Spacer(flex: 1),
            FutureBuilder<Experiment>(
              future: _experimentFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.nTasksDone < snapshot.data.nTasks) {
                    // Still tasks left
                    return Column(
                      children: [
                        Text(
                          S.of(context).taskResultsNextTaskTitle,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AccentButton(
                              Icons.schedule,
                              S.of(context).taskResultsNoNextTask,
                              color: Colors.grey,
                              onPressed: Navigator.of(context).pop,
                            ),
                            AccentButton(
                              Icons.arrow_forward,
                              S.of(context).taskResultsNextTask,
                              onPressed: widget.onContinuePressed,
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // No tasks left
                    return AccentButton(
                      Icons.check,
                      S.of(context).taskResultsFinishExperiment,
                      onPressed: Navigator.of(context).pop,
                    );
                  }
                } else if (snapshot.hasError) {
                  return ErrorMessage(
                    S.of(context).errorGeneric(snapshot.error),
                    retry: () {
                      setState(() {
                        _experimentFuture = loadUpdatedExperiment();
                      });
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
