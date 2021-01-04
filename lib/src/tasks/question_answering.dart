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

  QuestionAnswering(Map<String, dynamic> data, TaskEventLogger logger)
      : super(logger) {
    String readingType = data['readingType'];
    String text = data['text'];
    VoidCallback finishedReadingCallback = () {
      logger.log('finished reading');
      if (_questions.isNotEmpty) {
        setState(() {
          _mode = QuestionAnsweringMode.questions;
        });
        logger.log('started answering');
      } else {
        finish(this);
      }
    };
    switch (readingType) {
      case 'normal':
        _readingWidget = NormalReading(text, logger, finishedReadingCallback);
        break;
      case 'self-paced':
        _readingWidget =
            SelfPacedReading(text, logger, finishedReadingCallback);
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
  // TODO: null safety
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_mode) {
      case QuestionAnsweringMode.text:
        return _readingWidget;
      case QuestionAnsweringMode.questions:
        return QuestionsWidget(_questions, logger, (answers) {
          logger.log('finished answering');
          finish(this);
        });
    }
  }
}

@immutable
class Question {
  final String question;
  final List<String> answers;

  Question(this.question, this.answers);

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      json['question'],
      json['answers'].cast<String>(),
    );
  }
}

class NormalReading extends StatelessWidget {
  final String text;
  final TaskEventLogger logger;
  final VoidCallback onFinishedReading;

  const NormalReading(this.text, this.logger, this.onFinishedReading, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
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
    );
  }
}

class SelfPacedReading extends StatefulWidget {
  final String text;
  final TaskEventLogger logger;
  final VoidCallback onFinishedReading;

  const SelfPacedReading(this.text, this.logger, this.onFinishedReading,
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
        color: Colors.white,
        child: Column(
          children: [
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedSegments(
                _currentSegmentIndex > 0
                    ? _segments[_currentSegmentIndex - 1]
                    : '',
                _currentSegmentIndex < _segments.length
                    ? _segments[_currentSegmentIndex]
                    : '',
              ),
            ),
            Spacer(),
            AnimatedLinearProgressIndicator(
                _currentSegmentIndex / _segments.length),
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
  List<int> _answers;

  @override
  void initState() {
    super.initState();
    _answers = [for (Question _ in widget.questions) null];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            for (int i = 0; i < widget.questions.length; i++)
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
                        for (int j = 0;
                            j < widget.questions[i].answers.length;
                            j++)
                          Row(
                            children: [
                              Radio(
                                value: j,
                                groupValue: _answers[i],
                                onChanged: (value) {
                                  widget.logger.log('chose answer',
                                      {'question': i, 'answer': j});
                                  setState(() {
                                    _answers[i] = j;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                    child: Text(
                                      widget.questions[i].answers[j],
                                    ),
                                    onTap: () {
                                      widget.logger.log('chose answer',
                                          {'question': i, 'answer': j});
                                      setState(() {
                                        _answers[i] = j;
                                      });
                                    }),
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
              onPressed: !_answers.contains(null)
                  ? () {
                      widget.onFinishedAnswering(_answers);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
