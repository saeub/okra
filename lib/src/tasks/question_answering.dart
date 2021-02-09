import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../generated/l10n.dart';
import '../util.dart';
import 'task.dart';

enum QuestionAnsweringMode {
  text,
  questions,
}

class QuestionAnswering extends Task {
  Widget _readingWidget;
  List<Question> _questions;
  QuestionAnsweringMode _mode;
  double _progress;

  @override
  void init(Map<String, dynamic> data) {
    String readingType = data['readingType'];
    String text = data['text'];
    var progressCallback = (progress) {
      setState(() {
        _progress = progress;
      });
    };
    var finishedReadingCallback = () {
      logger.log('finished reading');
      if (_questions.isNotEmpty) {
        setState(() {
          _mode = QuestionAnsweringMode.questions;
          _progress = null;
        });
        logger.log('started answering');
      } else {
        finish(data: {'chosenAnswerIndices': []});
      }
    };
    switch (readingType) {
      case 'normal':
        _readingWidget = NormalReading(
            text, logger, progressCallback, finishedReadingCallback);
        break;
      case 'self-paced':
        _readingWidget = SelfPacedReading(
            text, logger, progressCallback, finishedReadingCallback);
        _progress = 0;
        break;
      default:
        throw ArgumentError('Unknown reading type "$readingType"');
    }

    List<Map<String, dynamic>> questionData;
    if (data['questions'] != null) {
      questionData = data['questions'].cast<Map<String, dynamic>>();
    } else {
      questionData = [];
    }
    _questions = questionData.map(Question.fromJson).toList();

    _mode = QuestionAnsweringMode.text;

    logger.log('started reading');
    logger.stopwatch.start();
  }

  @override
  double getProgress() => _progress;

  @override
  // TODO: null safety
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_mode) {
      case QuestionAnsweringMode.text:
        return _readingWidget;
      case QuestionAnsweringMode.questions:
        return QuestionsWidget(_questions, logger, (answers) {
          logger.log('finished answering');
          finish(data: {'chosenAnswerIndices': answers});
        });
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

class NormalReading extends StatelessWidget {
  final String text;
  final TaskEventLogger logger;
  final Function(double progress) onProgress;
  final VoidCallback onFinishedReading;

  const NormalReading(
      this.text, this.logger, this.onProgress, this.onFinishedReading,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ReadingWidth(
            Column(
              children: [
                MarkdownBody(data: text),
                AccentButton(
                  Icons.arrow_forward,
                  S.of(context).taskAdvance,
                  onPressed: onFinishedReading,
                ),
              ],
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
  final Function(double progress) onProgress;
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
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReadingWidth(
                AnimatedSegments(
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
          Column(
            children: [
              for (var i = 0; i < widget.questions.length; i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.questions[i].question,
                        style: Theme.of(context).textTheme.headline6,
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
                                        widget
                                            .questions[i].correctAnswerIndex &&
                                    j == _chosenAnswerIndices[i])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child:
                                        Icon(Icons.check, color: Colors.green),
                                  )
                                else if (_feedbacking &&
                                    j == widget.questions[i].correctAnswerIndex)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.arrow_forward,
                                        color: Colors.red),
                                  ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Text(
                                      widget.questions[i].answers[j],
                                    ),
                                    onTap: !_feedbacking
                                        ? () => _chooseAnswer(i, j)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              AccentButton(
                Icons.arrow_forward,
                S.of(context).taskFinish,
                onPressed: !_chosenAnswerIndices.contains(null)
                    ? () {
                        if (!_feedbacking) {
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
                        } else {
                          widget.onFinishedAnswering(_chosenAnswerIndices);
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
