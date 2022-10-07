import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../../generated/l10n.dart';
import '../colors.dart';
import '../data/models.dart';
import '../pages/task.dart';
import '../util.dart';
import 'task.dart';

class Reading extends MultistageTask {
  late final String _text;

  late final IntroStage? _introStage;
  late final ScrollableTextStage _textStage;
  late final RatingsStage? _ratingsStage;
  late final QuestionsStage? _questionsStage;

  @override
  get backgroundColor {
    return currentStage == _textStage || currentStage == _questionsStage
        ? Colors.grey.shade300
        : null;
  }

  @override
  void init(Map<String, dynamic> data) {
    if (data['intro'] != null) {
      _introStage = IntroStage(markdown: data['intro']);
    } else {
      _introStage = null;
    }

    _text = data['text'];
    double textWidth = data['textWidth'].toDouble();
    double textHeight = data['textHeight'].toDouble();
    double fontSize = (data['fontSize'] ?? 20.0).toDouble();
    double lineHeight = (data['lineHeight'] ?? 1.5).toDouble();
    _textStage = ScrollableTextStage(
      text: _text,
      textWidth: textWidth,
      textHeight: textHeight,
      fontSize: fontSize,
      lineHeight: lineHeight,
    );

    if (data['ratings'] != null) {
      List<Map<String, dynamic>> ratingsData =
          data['ratings'].cast<Map<String, dynamic>>();
      List<TaskRating> ratings = ratingsData.map(TaskRating.fromJson).toList();
      _ratingsStage = RatingsStage(ratings: ratings);
    } else {
      _ratingsStage = null;
    }

    if (data['questions'] != null) {
      List<Map<String, dynamic>> questionsData =
          data['questions'].cast<Map<String, dynamic>>();
      var questions = questionsData.map(Question.fromJson).toList();
      _questionsStage = QuestionsStage(
        questions: questions,
        text: _text,
        textWidth: textWidth,
        textHeight: textHeight,
        fontSize: fontSize,
      );
    } else {
      _questionsStage = null;
    }

    super.init(data);
  }

  @override
  TaskStage? getNextStage(TaskStage? previousStage) {
    if (previousStage == null) {
      if (_introStage != null) {
        return _introStage;
      } else {
        return _textStage;
      }
    } else if (previousStage == _introStage) {
      return _textStage;
    } else if (previousStage == _textStage && _ratingsStage != null) {
      return _ratingsStage;
    } else if ((previousStage == _textStage ||
            previousStage == _ratingsStage) &&
        _questionsStage != null) {
      return _questionsStage;
    }
    finish();
    return null;
  }
}

// Intro

class IntroStage extends TaskStage {
  final String markdown;

  IntroStage({required this.markdown});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ReadingWidth(
            child: Column(
              children: [
                MarkdownBody(
                  data: markdown,
                  fitContent: false,
                  styleSheet: MarkdownStyleSheet(
                    textScaleFactor: 1.3,
                    p: const TextStyle(height: 1.5),
                  ),
                ),
                ElevatedButton.icon(
                  label: Text(S.of(context).taskAdvance),
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: finish,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Scrollable text

class ScrollableTextStage extends TaskStage {
  final String text;
  final double textWidth, textHeight;
  final double fontSize, lineHeight;
  bool _scrolledToBottom;
  String? _loggedText;

  ScrollableTextStage(
      {required this.text,
      required this.textWidth,
      required this.textHeight,
      required this.fontSize,
      required this.lineHeight})
      : _scrolledToBottom = false;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    style: TextStyle(fontSize: fontSize, color: Colors.black, height: lineHeight, leadingDistribution: TextLeadingDistribution.even),
                    onVisibleRangeChanged: (text, visibleRange) {
                      if (text != _loggedText) {
                        logger.log('text changed', {
                          'text': text,
                        });
                        _loggedText = text;
                      }
                      logger.log('visible range changed', {
                        'characterRange': [
                          visibleRange.start,
                          visibleRange.end
                        ],
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: finish,
              icon: const Icon(Icons.arrow_forward),
              label: Text(S.of(context).taskAdvance),
            ),
          ),
        )
      ],
    );
  }
}

class ScrollableText extends StatefulWidget {
  final String text;
  final double width, height;
  final double padding;
  final TextStyle style;
  final double paragraphSpacing;
  final Function(String text, TextRange visibleRange)? onVisibleRangeChanged;

  const ScrollableText(
      {required this.text,
      required this.width,
      required this.height,
      required this.style,
      this.paragraphSpacing = 16.0,
      this.padding = 8.0,
      this.onVisibleRangeChanged,
      Key? key})
      : super(key: key);

  @override
  State<ScrollableText> createState() => _ScrollableTextState();
}

class _Paragraph {
  final TextPainter painter;
  final String text;
  final double lineHeight;
  final double verticalOffset;

  _Paragraph(this.painter, this.verticalOffset)
      : text = painter.text!.toPlainText(),
        lineHeight = painter.computeLineMetrics().first.height;
}

class _ScrollableTextState extends State<ScrollableText>
    implements MarkdownBuilderDelegate {
  late List<_Paragraph> _paragraphs;
  String? _text;
  late double _topEdge, _bottomEdge;
  late TextRange _visibleRange;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paragraphs = [];
    _topEdge = 0;
    _bottomEdge = widget.height + widget.padding;
    _updateParagraphs(emitEvent: false);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _emitVisibleRangeChanged();
    });
  }

  @override
  void didUpdateWidget(ScrollableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.width != oldWidget.width ||
        widget.height != oldWidget.height ||
        widget.style != oldWidget.style ||
        widget.paragraphSpacing != oldWidget.paragraphSpacing) {
      _updateParagraphs();
    }
  }

  TextSpan _nodeToSpan(md.Node node) {
    if (node is md.Element) {
      TextStyle style;
      // TODO: Support all generated tags
      switch (node.tag) {
        case 'h1':
          style = TextStyle(
              fontSize: widget.style.fontSize! * 2,
              fontWeight: FontWeight.bold);
          break;
        case 'h2':
          style = TextStyle(
              fontSize: widget.style.fontSize! * 1.6,
              fontWeight: FontWeight.bold);
          break;
        case 'h3':
          style = TextStyle(
              fontSize: widget.style.fontSize! * 1.3,
              fontWeight: FontWeight.bold);
          break;
        case 'h4':
          style = TextStyle(
              fontSize: widget.style.fontSize! * 1.2,
              fontWeight: FontWeight.bold);
          break;
        case 'h5':
          style = const TextStyle(fontWeight: FontWeight.bold);
          break;
        case 'h6':
          style = const TextStyle(fontStyle: FontStyle.italic);
          break;
        case 'em':
          style = const TextStyle(fontStyle: FontStyle.italic);
          break;
        case 'strong':
          style = const TextStyle(fontWeight: FontWeight.bold);
          break;
        default:
          style = const TextStyle();
      }
      return TextSpan(children: [
        for (var child in node.children ?? <md.Node>[]) _nodeToSpan(child)
      ], style: style);
    } else if (node is md.Text) {
      var text = node.text.replaceAll(RegExp(r'\n'), ' ');
      return TextSpan(text: text);
    } else {
      throw ArgumentError('$node is neither an Element nor a Text');
    }
  }

  void _updateParagraphs({bool emitEvent = true}) {
    var document = md.Document();
    var lines = const LineSplitter().convert(widget.text);
    var astNodes = document.parseLines(lines);
    _paragraphs = [];
    var offset = 0.0;
    for (var node in astNodes) {
      var painter = TextPainter(
          text: TextSpan(children: [_nodeToSpan(node)], style: widget.style),
          textDirection: TextDirection.ltr);
      painter.layout(minWidth: widget.width, maxWidth: widget.width);
      _paragraphs.add(_Paragraph(painter, offset));
      offset += painter.height + widget.paragraphSpacing;
    }
    var newText = _paragraphs.map((paragraph) => paragraph.text).join('\n');
    if (newText != _text) {
      _text = newText;
      _updateVisibleRange(textChanged: true, emitEvent: emitEvent);
    }
  }

  void _updateVisibleRange({bool textChanged = false, bool emitEvent = true}) {
    int? rangeStart, rangeEnd;
    var textOffset = -1;
    for (var paragraph in _paragraphs) {
      textOffset += 1; // newline between paragraphs
      // Consider a line visible if at least 1/2 of its height is on screen
      var minVisibleLineRatio = 1 / 2;
      // Screen edges relative to paragraph
      var relativeTopEdge = _topEdge -
          paragraph.verticalOffset +
          paragraph.lineHeight * minVisibleLineRatio;
      var relativeBottomEdge = _bottomEdge -
          paragraph.verticalOffset -
          paragraph.lineHeight * minVisibleLineRatio;
      if (relativeTopEdge < paragraph.painter.height &&
          relativeBottomEdge > 0) {
        // Calculate visible range within paragraph
        var paragraphRangeStart = paragraph.painter
            .getPositionForOffset(Offset(0, relativeTopEdge))
            .offset;
        var paragraphRangeEnd = paragraph.painter
            .getPositionForOffset(Offset(widget.width, relativeBottomEdge))
            .offset;
        // Update visible range within entire text
        rangeStart ??= textOffset + paragraphRangeStart;
        rangeEnd = textOffset + paragraphRangeEnd;
      }
      textOffset += paragraph.text.length;
    }

    var newVisibleRange = TextRange(start: rangeStart ?? 0, end: rangeEnd ?? 0);
    if ((textChanged || newVisibleRange != _visibleRange)) {
      _visibleRange = newVisibleRange;
      if (emitEvent) {
        _emitVisibleRangeChanged();
      }
    }
  }

  void _emitVisibleRangeChanged() {
    var onVisibleRangeChanged = widget.onVisibleRangeChanged;
    if (onVisibleRangeChanged != null) {
      onVisibleRangeChanged(_text ?? '', _visibleRange);
    }
  }

  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    return TapGestureRecognizer();
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    return TextSpan(text: code);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width + 2 * widget.padding,
      height: widget.height + 2 * widget.padding,
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          _topEdge = notification.metrics.extentBefore - widget.padding;
          _bottomEdge = _topEdge + notification.metrics.extentInside;
          _updateVisibleRange();
          return false;
        },
        child: Scrollbar(
          // TODO: Use ListView, optimize for long texts
          child: SingleChildScrollView(
            padding: EdgeInsets.all(widget.padding),
            child: Column(
              children: [
                for (var i = 0; i < _paragraphs.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        top: i > 0 ? widget.paragraphSpacing : 0),
                    child: CustomPaint(
                      size: Size(widget.width, _paragraphs[i].painter.height),
                      painter: CustomTextPainter(_paragraphs[i].painter),
                    ),
                  ),
              ],
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
  String? _loggedText;

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

  void _checkAnswers(BuildContext context) async {
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
    });
    if (questionIndicesToCorrect.isNotEmpty) {
      setState(() {
        _questionIndicesToCorrect = questionIndicesToCorrect;
        _pageToQuestion(questionIndicesToCorrect.reduce(min));
      });
      logger.log('showing correction dialog');
      await showDialog(
        context: context,
        builder: (context) {
          var nIncorrect = questionIndicesToCorrect.length;
          return AlertDialog(
            actions: [
              TextButton(
                child: Text(S.of(context).dialogOk),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            title: Text(
                S.of(context).taskReadingCorrectionDialogTitle(nIncorrect)),
            content: Text(S.of(context).taskReadingCorrectionDialogText),
          );
        },
      );
      logger.log('started answer correction', {
        'questionIndicesToCorrect': questionIndicesToCorrect.toList(),
      });
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
                        onVisibleRangeChanged: (text, visibleRange) {
                          if (text != _loggedText) {
                            logger.log('text changed', {
                              'text': text,
                            });
                            _loggedText = text;
                          }
                          logger.log('visible range changed', {
                            'characterRange': [
                              visibleRange.start,
                              visibleRange.end
                            ],
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
                  Visibility(
                    visible: _currentQuestionIndex > 0,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        child: const Icon(Icons.arrow_back),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size.fromWidth(40.0)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            backgroundColor: MaterialStateProperty.all(
                                nToAnswerLeft > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary),
                            elevation: MaterialStateProperty.all(
                                nToAnswerLeft > 0 ? null : 0.0)),
                        onPressed: () {
                          _pageToQuestion(
                            _currentQuestionIndex - 1,
                          );
                        },
                      ),
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
                  Visibility(
                    visible: _currentQuestionIndex < questions.length - 1,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        child: const Icon(Icons.arrow_forward),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size.fromWidth(40.0)),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            backgroundColor: MaterialStateProperty.all(
                                nToAnswerRight > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary),
                            elevation: MaterialStateProperty.all(
                                nToAnswerRight > 0 ? null : 0.0)),
                        onPressed: () {
                          _pageToQuestion(
                            _currentQuestionIndex + 1,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: !_selectedAnswerIndices.contains(null),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () => _checkAnswers(context),
                icon: const Icon(Icons.arrow_forward),
                label: Text(S.of(context).taskAdvance),
              ),
            ),
          )
        ],
      ),
    );
  }
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
                            child: Icon(Icons.check,
                                color: AppColors.positive.shade700,
                                size: fontSize + 4.0),
                          ),
                          Text(
                            S.of(context).taskReadingCorrect,
                            style: TextStyle(
                              color: AppColors.positive.shade700,
                              fontSize: fontSize,
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
                            child: Icon(Icons.clear,
                                color: AppColors.negative.shade700,
                                size: fontSize + 4.0),
                          ),
                          Text(
                            S.of(context).taskReadingIncorrect,
                            style: TextStyle(
                              color: AppColors.negative.shade700,
                              fontSize: fontSize,
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

// Ratings

// TODO: Advance ratings here, report progress
class RatingsStage extends TaskStage {
  final List<TaskRating> ratings;

  RatingsStage({required this.ratings});

  @override
  Widget build(BuildContext context) {
    return RatingsWidget(
      ratings,
      onFinished: (answers) {
        logger.log('finished ratings', {'answers': answers});
        finish();
      },
    );
  }
}
