import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../generated/l10n.dart';
import '../data/models.dart';
import '../pages/task.dart';
import '../util.dart';
import 'task.dart';

enum _QuestionAnsweringStage {
  textOnly,
  ratingsBeforeQuestions,
  textAndQuestions,
}

class QuestionAnswering extends Task {
  List<Question> _questions;
  List<TaskRating> _ratingsBeforeQuestions;
  List<num> _ratingsBeforeQuestionsAnswers;
  _QuestionAnsweringStage _stage;
  bool _questionsExpanded;
  double _progress;
  Widget _firstStageReadingWidget, _readingWidget, _questionsWidget;

  @override
  void init(Map<String, dynamic> data) {
    String readingType = data['readingType'];
    String text = data['text'];

    List<Map<String, dynamic>> questionData;
    if (data['questions'] != null) {
      questionData = data['questions'].cast<Map<String, dynamic>>();
    } else {
      questionData = [];
    }
    _questions = questionData.map(Question.fromJson).toList();

    List<Map<String, dynamic>> ratingsBeforeQuestionsData =
        data['ratingsBeforeQuestions']?.cast<Map<String, dynamic>>();
    _ratingsBeforeQuestions =
        ratingsBeforeQuestionsData?.map(TaskRating.fromJson)?.toList();
    if (_ratingsBeforeQuestions != null) {
      _stage = _QuestionAnsweringStage.textOnly;
    } else {
      _stage = _QuestionAnsweringStage.textAndQuestions;
    }

    _questionsExpanded = false;

    // TODO: Refactor widget building
    var focusCallback = () {
      setState(() {
        _questionsExpanded = false;
      });
    };
    var progressCallback = (progress) {
      setState(() {
        _progress = progress;
      });
    };
    Function() finishedReadingCallback;
    if (_questions.isEmpty) {
      finishedReadingCallback = () {
        logger.log('finished reading', {'stage': 1});
        finish(data: {
          'chosenAnswerIndices': [],
          'ratingsBeforeQuestionsAnswers': _ratingsBeforeQuestionsAnswers,
        });
      };
    }
    var firstStageFinishedReadingCallback = () {
      logger.log('finished reading', {'stage': 0});
      setState(() {
        _stage = _QuestionAnsweringStage.ratingsBeforeQuestions;
        _progress = null;
      });
      logger.log('started ratings before questions');
    };
    switch (readingType) {
      case 'normal':
        _firstStageReadingWidget = NormalReading(
            text, logger, null, firstStageFinishedReadingCallback);
        _readingWidget =
            NormalReading(text, logger, focusCallback, finishedReadingCallback);
        break;
      case 'self-paced':
        _firstStageReadingWidget = SelfPacedReading(
            text, logger, progressCallback, firstStageFinishedReadingCallback);
        _readingWidget = SelfPacedReading(
            text, logger, progressCallback, finishedReadingCallback);
        _progress = 0;
        break;
      default:
        throw ArgumentError('Unknown reading type "$readingType"');
    }

    _questionsWidget = QuestionsWidget(_questions, logger, (answers) {
      finish(data: {
        'chosenAnswerIndices': answers,
        'ratingsBeforeQuestionsAnswers': _ratingsBeforeQuestionsAnswers,
      });
    });

    logger.log('started reading',
        {'stage': _stage == _QuestionAnsweringStage.textOnly ? 0 : 1});
    logger.stopwatch.start();
  }

  @override
  double getProgress() => _progress;

  @override
  // FIXME: null-safety
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_stage) {
      case _QuestionAnsweringStage.textOnly:
        return _firstStageReadingWidget;

      case _QuestionAnsweringStage.ratingsBeforeQuestions:
        return RatingsWidget(
          _ratingsBeforeQuestions,
          onFinished: (answers) {
            logger.log('finished ratings before questions');
            _ratingsBeforeQuestionsAnswers = answers;
            setState(() {
              _stage = _QuestionAnsweringStage.textAndQuestions;
              if (_readingWidget is SelfPacedReading) {
                _progress = 0;
              }
            });
            logger.log('started reading', {'stage': 1});
          },
        );

      case _QuestionAnsweringStage.textAndQuestions:
        return LayoutBuilder(
          builder: (context, constraints) {
            // Small screens
            if (constraints.maxWidth < 1000) {
              return Column(
                children: [
                  Expanded(child: _readingWidget),
                  if (_questions.isNotEmpty)
                    ExpansionPanelList(
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          _questionsExpanded = !isExpanded;
                        });
                        logger.log(_questionsExpanded
                            ? 'expanded questions'
                            : 'collapsed questions');
                      },
                      children: [
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                                title: Text(S
                                    .of(context)
                                    .taskQuestionAnsweringExpandQuestions));
                          },
                          body: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight - 250.0,
                            ),
                            child: _questionsWidget,
                          ),
                          isExpanded: _questionsExpanded,
                        ),
                      ],
                    ),
                ],
              );
            }
            // Large screens
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _readingWidget,
                ),
                if (_questions.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Material(elevation: 5.0, child: _questionsWidget),
                  ),
              ],
            );
          },
        );
    }
  }
}

@immutable
class Question {
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;

  Question(this.question, this.answers, [this.correctAnswerIndex]);

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      json['question'],
      json['answers'].cast<String>(),
      json['correctAnswerIndex'],
    );
  }
}

class NormalReading extends StatefulWidget {
  final String text;
  final TaskEventLogger logger;
  final void Function() onFocus;
  final VoidCallback onFinishedReading;

  const NormalReading(
      this.text, this.logger, this.onFocus, this.onFinishedReading,
      {Key key})
      : super(key: key);

  @override
  _NormalReadingState createState() => _NormalReadingState();
}

class _NormalReadingState extends State<NormalReading> {
  static const logScrollDistanceThreshold = 50.0;

  double _distanceScrolled;

  @override
  void initState() {
    super.initState();
    _distanceScrolled = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFocus,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          _distanceScrolled += notification.scrollDelta.abs();
          if (_distanceScrolled >= logScrollDistanceThreshold) {
            widget.logger.log('scrolled text', {
              'extentBefore': notification.metrics.extentBefore,
              'extentInside': notification.metrics.extentInside,
              'extentAfter': notification.metrics.extentAfter,
            });
            while (_distanceScrolled >= logScrollDistanceThreshold) {
              _distanceScrolled -= logScrollDistanceThreshold;
            }
          }
          widget.onFocus();
          return false;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ReadingWidth(
                child: Column(
                  children: [
                    MarkdownBody(
                      data: widget.text,
                      styleSheet: MarkdownStyleSheet(
                        textScaleFactor: 1.3,
                        p: TextStyle(height: 1.5),
                      ),
                    ),
                    if (widget.onFinishedReading != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.arrow_forward),
                          label: Text(S.of(context).taskFinish),
                          onPressed: widget.onFinishedReading,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelfPacedReading extends StatefulWidget {
  final String text;
  final TaskEventLogger logger;
  final void Function(double progress) onProgress;
  final VoidCallback onFinishedReading;

  const SelfPacedReading(
      this.text, this.logger, this.onProgress, this.onFinishedReading,
      {Key key})
      : super(key: key);

  @override
  _SelfPacedReadingState createState() => _SelfPacedReadingState();
}

class _SelfPacedReadingState extends State<SelfPacedReading> {
  List<String> _segments;
  int _currentSegmentIndex;

  @override
  void initState() {
    super.initState();
    _segments = widget.text.trim().split('\n');
    _currentSegmentIndex = 0;
    widget.logger.log('started segment', {
      'segments': [_currentSegmentIndex]
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_currentSegmentIndex < _segments.length) {
          setState(() {
            _currentSegmentIndex++;
          });
          widget.logger.log('started segment', {
            'segments': [
              _currentSegmentIndex - 1,
              if (_currentSegmentIndex < _segments.length) _currentSegmentIndex,
            ]
          });
          widget.onProgress(_currentSegmentIndex / _segments.length);
        } else {
          widget.onFinishedReading();
        }
      },
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadingWidth(
                child: AnimatedSegments(
                  _currentSegmentIndex > 0
                      ? _segments[_currentSegmentIndex - 1]
                      : '',
                  _currentSegmentIndex < _segments.length
                      ? _segments[_currentSegmentIndex]
                      : '',
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class AnimatedSegments extends StatefulWidget {
  final String previousSegment, currentSegment;
  final TextStyle previousSegmentStyle, currentSegmentStyle;
  final double segmentHeight;
  final Duration duration;

  const AnimatedSegments(this.previousSegment, this.currentSegment,
      {this.previousSegmentStyle = const TextStyle(
        fontSize: 20.0,
        color: Colors.grey,
      ),
      this.currentSegmentStyle = const TextStyle(
        fontSize: 20.0,
        color: Colors.black,
      ),
      this.segmentHeight = 150.0,
      this.duration = const Duration(milliseconds: 200),
      Key key})
      : super(key: key);

  @override
  _AnimatedSegmentsState createState() => _AnimatedSegmentsState();
}

class _AnimatedSegmentsState extends State<AnimatedSegments>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  void _startAnimation() {
    _controller.reset();
    _animation = CurveTween(curve: Curves.easeInOut)
        .chain(Tween<double>(begin: 1.0, end: 0.0))
        .animate(_controller)
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _startAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(AnimatedSegments oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO: also animate for equal strings
    if (widget.previousSegment != oldWidget.previousSegment ||
        widget.currentSegment != oldWidget.currentSegment) {
      _startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 2 * widget.segmentHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: _animation.value * widget.segmentHeight,
                left: 0,
                right: 0,
                height: widget.segmentHeight,
                child: AutoSizeText(
                  widget.previousSegment,
                  style: TextStyle.lerp(widget.previousSegmentStyle,
                      widget.currentSegmentStyle, _animation.value),
                ),
              ),
              Positioned(
                top: widget.segmentHeight +
                    _animation.value * widget.segmentHeight,
                left: 0,
                right: 0,
                height: widget.segmentHeight,
                child: Opacity(
                  opacity: 1.0 - _animation.value,
                  child: AutoSizeText(
                    widget.currentSegment,
                    style: widget.currentSegmentStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

typedef FinishedAnsweringCallback = void Function(List<int> answers);

class QuestionsWidget extends StatefulWidget {
  final List<Question> questions;
  final TaskEventLogger logger;
  final FinishedAnsweringCallback onFinishedAnswering;

  const QuestionsWidget(this.questions, this.logger, this.onFinishedAnswering,
      {Key key})
      : super(key: key);

  @override
  _QuestionsWidgetState createState() => _QuestionsWidgetState();
}

class _QuestionsWidgetState extends State<QuestionsWidget> {
  List<int> _chosenAnswerIndices;
  bool _feedbacking;

  @override
  void initState() {
    super.initState();
    _chosenAnswerIndices = [for (Question _ in widget.questions) null];
    _feedbacking = false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ReadingWidth(
          child: Column(
            children: [
              for (var i = 0; i < widget.questions.length; i++)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            widget.questions[i].question,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Column(
                          children: [
                            for (var j = 0;
                                j < widget.questions[i].answers.length;
                                j++)
                              Row(
                                children: [
                                  Radio(
                                    value: j,
                                    groupValue: _chosenAnswerIndices[i],
                                    onChanged: !_feedbacking
                                        ? (_) => _chooseAnswer(i, j)
                                        : null,
                                  ),
                                  if (_feedbacking &&
                                      j ==
                                          widget.questions[i]
                                              .correctAnswerIndex &&
                                      j == _chosenAnswerIndices[i])
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.check,
                                          color: Colors.green),
                                    )
                                  else if (_feedbacking &&
                                      j ==
                                          widget
                                              .questions[i].correctAnswerIndex)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.arrow_forward,
                                          color: Colors.red),
                                    ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: !_feedbacking
                                          ? () => _chooseAnswer(i, j)
                                          : null,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Text(
                                          widget.questions[i].answers[j],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ElevatedButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text(S.of(context).taskFinish),
                onPressed: !_chosenAnswerIndices.contains(null)
                    ? () {
                        if (_feedbacking) {
                          widget.logger.log('finished feedback');
                          widget.onFinishedAnswering(_chosenAnswerIndices);
                        } else {
                          widget.logger.log('finished reading', {'stage': 1});
                          for (var i = 0; i < widget.questions.length; i++) {
                            if (widget.questions[i].correctAnswerIndex !=
                                null) {
                              _feedbacking = true;
                              widget.logger.log('started feedback');
                              break;
                            }
                          }
                          setState(() {});
                          if (!_feedbacking) {
                            widget.onFinishedAnswering(_chosenAnswerIndices);
                          }
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _chooseAnswer(int questionIndex, int answerIndex) {
    widget.logger.log(
        'chose answer', {'question': questionIndex, 'answer': answerIndex});
    setState(() {
      _chosenAnswerIndices[questionIndex] = answerIndex;
    });
  }
}
