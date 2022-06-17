import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../util.dart';
import 'task.dart';

class Reading extends MultistageTask {
  late final String _text;
  late final List<Question> _questions;

  late final ScrollableTextStage _textStage;
  late final QuestionsStage? _questionsStage;

  @override
  void init(Map<String, dynamic> data) {
    _text = data['text'];
    double textWidth = data['textWidth'].toDouble();
    double textHeight = data['textHeight'].toDouble();
    double fontSize = data['fontSize'] ?? 20.0;
    _textStage = ScrollableTextStage(
      text: _text,
      textWidth: textWidth,
      textHeight: textHeight,
      fontSize: fontSize,
    );

    List<Map<String, dynamic>> questionData;
    if (data['questions'] != null) {
      questionData = data['questions'].cast<Map<String, dynamic>>();
      _questions = questionData.map(Question.fromJson).toList();
      _questionsStage = QuestionsStage(
        questions: _questions,
        text: _text,
        textWidth: textWidth,
        textHeight: textHeight,
        fontSize: fontSize,
      );
    } else {
      _questions = [];
      _questionsStage = null;
    }

    super.init(data);
  }

  @override
  TaskStage? getNextStage(TaskStage? previousStage) {
    if (previousStage == null) {
      return _textStage;
    } else if (previousStage == _textStage && _questionsStage != null) {
      return _questionsStage;
    }
    finish();
    return null;
  }
}

// Scrollable text

class ScrollableTextStage extends TaskStage {
  final String text;
  final double textWidth, textHeight;
  final double fontSize;
  bool _scrolledToBottom;

  ScrollableTextStage(
      {required this.text,
      required this.textWidth,
      required this.textHeight,
      required this.fontSize})
      : _scrolledToBottom = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey.shade300,
      child: Column(
        children: [
          Expanded(
            child: ReadingWidth(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Card(
                    child: ScrollableText(
                      text: text,
                      width: textWidth,
                      height: textHeight,
                      style: TextStyle(fontSize: fontSize, color: Colors.black),
                      onVisibleRangeChanged: (visibleRange) {
                        logger.log('visible range', {
                          'characterRange': [
                            visibleRange.start,
                            visibleRange.end
                          ]
                        });
                        if (!_scrolledToBottom &&
                            visibleRange.end >= text.length) {
                          setState(() {
                            _scrolledToBottom = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _scrolledToBottom,
            maintainAnimation: true,
            maintainSize: true,
            maintainState: true,
            child: ElevatedButton.icon(
              onPressed: finish,
              icon: const Icon(Icons.arrow_forward),
              label: Text(S.of(context).taskAdvance),
            ),
          )
        ],
      ),
    );
  }

  @override
  double? getProgress() => null;
}

class ScrollableText extends StatefulWidget {
  final String text;
  final double width, height;
  final double padding;
  final TextStyle? style;
  final Function(TextRange visibleRange)? onVisibleRangeChanged;

  const ScrollableText(
      {required this.text,
      required this.width,
      required this.height,
      this.padding = 8.0,
      this.style,
      this.onVisibleRangeChanged,
      Key? key})
      : super(key: key);

  @override
  State<ScrollableText> createState() => _ScrollableTextState();
}

class _ScrollableTextState extends State<ScrollableText> {
  late TextPainter _painter;
  late TextRange _visibleRange;

  @override
  void initState() {
    super.initState();
    _updatePainter();
    _visibleRange = _getVisibleRange(0, widget.height + widget.padding);
    _emitVisibleRangeChanged();
  }

  @override
  void didUpdateWidget(ScrollableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.width != oldWidget.width ||
        widget.height != oldWidget.height) {
      _updatePainter();
    }
  }

  void _updatePainter() {
    _painter = TextPainter(
        text: TextSpan(text: widget.text, style: widget.style),
        textDirection: TextDirection.ltr);
    _painter.layout(minWidth: widget.width, maxWidth: widget.width);
  }

  TextRange _getVisibleRange(double topEdge, double bottomEdge) {
    // Consider a line visible if at least 3/4 of its height is on screen
    var start = _painter.getPositionForOffset(
        Offset(0, topEdge + _painter.preferredLineHeight * 0.75));
    var end = _painter.getPositionForOffset(
        Offset(widget.width, bottomEdge - _painter.preferredLineHeight * 0.75));
    return TextRange(start: start.offset, end: end.offset);
  }

  void _emitVisibleRangeChanged() {
    var onVisibleRangeChanged = widget.onVisibleRangeChanged;
    if (onVisibleRangeChanged != null) {
      onVisibleRangeChanged(_visibleRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width + 2 * widget.padding,
      height: widget.height + 2 * widget.padding,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          var topEdge = notification.metrics.extentBefore - widget.padding;
          var bottomEdge = topEdge + notification.metrics.extentInside;
          var newVisibleRange = _getVisibleRange(topEdge, bottomEdge);
          if (newVisibleRange != _visibleRange) {
            _visibleRange = newVisibleRange;
            _emitVisibleRangeChanged();
          }
          return false;
        },
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(widget.padding),
            child: CustomPaint(
              size: Size(widget.width, _painter.height),
              painter: CustomTextPainter(_painter),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextPainter extends CustomPainter {
  final TextPainter painter;

  CustomTextPainter(this.painter);

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomTextPainter oldDelegate) {
    return painter != oldDelegate.painter;
  }
}

// Questions

@immutable
class Question {
  final String question;
  final List<String> answers;
  final int? correctAnswerIndex;

  const Question(this.question, this.answers, [this.correctAnswerIndex]);

  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      json['question'],
      json['answers'].cast<String>(),
      json['correctAnswerIndex'],
    );
  }
}

class QuestionsStage extends TaskStage {
  final List<Question> questions;
  final String? text;
  final double textWidth, textHeight;
  final double fontSize;
  late final PageController _pageController;
  int _currentQuestionIndex;
  final List<int?> _selectedAnswerIndices;
  Set<int>? _questionIndicesToCorrect;

  QuestionsStage(
      {required this.questions,
      required this.text,
      required this.textWidth,
      required this.textHeight,
      required this.fontSize})
      : _currentQuestionIndex = 0,
        _selectedAnswerIndices = [
          for (var i = 0; i < questions.length; i++) null
        ] {
    _pageController = PageController()
      ..addListener(() {
        var oldQuestionIndex = _currentQuestionIndex;
        var newQuestionIndex = _pageController.page!.round();
        if (oldQuestionIndex != newQuestionIndex) {
          setState(() {
            _currentQuestionIndex = newQuestionIndex;
          });
          logger.log(
              'turned to question', {'questionIndex': _currentQuestionIndex});
        }
      });
  }

  void _pageToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _checkAnswers(BuildContext context) {
    var questionIndicesToCorrect = <int>{};
    for (var i = 0; i < questions.length; i++) {
      var selectedAnswerIndex = _selectedAnswerIndices[i];
      var correctAnswerIndex = questions[i].correctAnswerIndex;
      if (correctAnswerIndex != null &&
          selectedAnswerIndex != correctAnswerIndex) {
        questionIndicesToCorrect.add(i);
      }
    }
    logger.log('submitted answers', {
      'answerIndices': _selectedAnswerIndices,
      'questionIndicesToCorrect': questionIndicesToCorrect.toList()
    });
    if (questionIndicesToCorrect.isNotEmpty) {
      setState(() {
        _questionIndicesToCorrect = questionIndicesToCorrect;
        _pageToQuestion(questionIndicesToCorrect.reduce(min));
      });
      logger.log('showing correction dialog');
      showDialog(
        context: context,
        builder: (context) {
          var nIncorrect = questionIndicesToCorrect.length;
          return AlertDialog(
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            title: Text('$nIncorrect incorrect'),
            content: const Text('Please correct your answers.'),
          );
        },
      ).then(
        (_) => logger.log('dismissed correction dialog'),
      );
    } else {
      finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    var text = this.text;
    var _questionIndicesToCorrect = this._questionIndicesToCorrect;
    var nToAnswerLeft = 0;
    var nToAnswerRight = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_selectedAnswerIndices[i] == null ||
          (_questionIndicesToCorrect != null &&
              _questionIndicesToCorrect.contains(i))) {
        if (i < _currentQuestionIndex) {
          nToAnswerLeft++;
        } else if (i > _currentQuestionIndex) {
          nToAnswerRight++;
        }
      }
    }

    return Container(
      alignment: Alignment.center,
      color: Colors.grey.shade300,
      child: Column(
        children: [
          if (text != null)
            Expanded(
              child: ReadingWidth(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Card(
                      child: ScrollableText(
                        text: text,
                        width: textWidth,
                        height: textHeight,
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.black),
                        onVisibleRangeChanged: (visibleRange) {
                          logger.log('visible range', {
                            'characterRange': [
                              visibleRange.start,
                              visibleRange.end
                            ]
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(
            height: 200,
            child: ReadingWidth(
              child: Row(
                children: [
                  Badge(
                    showBadge: nToAnswerLeft > 0,
                    position: BadgePosition.topStart(top: 0, start: 0),
                    // badgeContent: Text(
                    //   nToAnswerLeft.toString(),
                    //   style: const TextStyle(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    toAnimate: false,
                    child: IconButton(
                      alignment: Alignment.centerRight,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentQuestionIndex > 0
                          ? () {
                              _pageToQuestion(
                                _currentQuestionIndex - 1,
                              );
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: [
                        for (var i = 0; i < questions.length; i++)
                          QuestionCard(
                            questions[i],
                            selectedAnswerIndex: _selectedAnswerIndices[i],
                            correct: _questionIndicesToCorrect != null
                                ? _questionIndicesToCorrect.contains(i)
                                    ? false
                                    : true
                                : null,
                            onAnswerChanged: (answerIndex) {
                              setState(() {
                                _selectedAnswerIndices[i] = answerIndex;
                              });
                              logger.log('selected answer', {
                                'questionIndex': i,
                                'answerIndex': answerIndex
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  Badge(
                    showBadge: nToAnswerRight > 0,
                    position: BadgePosition.topEnd(top: 0, end: 0),
                    // badgeContent: Text(
                    //   nToAnswerRight.toString(),
                    //   style: const TextStyle(
                    //       color: Colors.white, fontWeight: FontWeight.bold),
                    // ),
                    toAnimate: false,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentQuestionIndex < questions.length - 1
                          ? () {
                              _pageToQuestion(
                                _currentQuestionIndex + 1,
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !_selectedAnswerIndices.contains(null),
            child: ElevatedButton.icon(
              onPressed: () => _checkAnswers(context),
              icon: const Icon(Icons.arrow_forward),
              label: Text(S.of(context).taskAdvance),
            ),
          )
        ],
      ),
    );
  }

  @override
  double? getProgress() => null;
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final bool? correct;
  final Function(int?) onAnswerChanged;

  const QuestionCard(this.question,
      {required this.selectedAnswerIndex,
      this.correct,
      required this.onAnswerChanged,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      var fontSize = 20.0;
      if (constraints.maxWidth < 500) {
        fontSize = 15.0;
      }
      var disabled = correct == true;

      return Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        question.question,
                        style: TextStyle(
                            fontSize: fontSize, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (correct == true)
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child:
                                Icon(Icons.check, color: Colors.green.shade700),
                          ),
                          Text(
                            'CORRECT',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else if (correct == false)
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child:
                                Icon(Icons.clear, color: Colors.red.shade700),
                          ),
                          Text(
                            'INCORRECT',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                for (var i = 0; i < question.answers.length; i++)
                  Row(
                    children: [
                      Radio(
                        value: i,
                        groupValue: selectedAnswerIndex,
                        onChanged: disabled ? null : onAnswerChanged,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: disabled ? null : () => onAnswerChanged(i),
                          child: Text(
                            question.answers[i],
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    }));
  }
}
