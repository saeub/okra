import 'dart:math';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../util.dart';
import 'task.dart';

class Reading extends MultistageTask {
  late final String _text;
  late final List<Question> _questions;

  late final ScrollingTextStage _textStage;
  late final QuestionsStage? _questionsStage;

  @override
  void init(Map<String, dynamic> data) {
    _text = data['text'];
    int nVisibleLines = data['nVisibleLines'];
    double fontSize = data['fontSize'] ?? 20.0;
    double lineSpacing = 1.2;
    _textStage = ScrollingTextStage(_text, nVisibleLines,
        fontSize: fontSize, lineSpacing: lineSpacing);

    List<Map<String, dynamic>> questionData;
    if (data['questions'] != null) {
      questionData = data['questions'].cast<Map<String, dynamic>>();
      _questions = questionData.map(Question.fromJson).toList();
      _questionsStage = QuestionsStage(_questions,
          text: _text,
          nVisibleLines: nVisibleLines,
          fontSize: fontSize,
          lineSpacing: lineSpacing);
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

// Scrolling text

class ScrollingTextStage extends TaskStage {
  final String text;
  final int nVisibleLines;
  final double fontSize;
  final double lineSpacing;
  bool _scrolledToBottom;

  ScrollingTextStage(this.text, this.nVisibleLines,
      {this.fontSize = 20, this.lineSpacing = 1.2})
      : _scrolledToBottom = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ReadingWidth(
                child: ScrollingLines(
                  text,
                  nVisibleLines,
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: fontSize, height: lineSpacing),
                  onScrolled: (visibleRange) {
                    logger.log('scrolled text', {
                      'visibleRange': [visibleRange.start, visibleRange.end]
                    });
                    if (!_scrolledToBottom && visibleRange.end == text.length) {
                      setState(() {
                        _scrolledToBottom = true;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Visibility(
            visible: _scrolledToBottom,
            maintainAnimation: true,
            maintainSize: true,
            maintainState: true,
            child: ElevatedButton(
                onPressed: finish, child: Text(S.of(context).taskAdvance)),
          )
        ],
      ),
    );
  }

  @override
  double? getProgress() => null;
}

class ScrollingLines extends StatefulWidget {
  final String text;
  final int nVisibleLines;
  final TextStyle style;
  final Function(TextRange visibleRange)? onScrolled;

  const ScrollingLines(this.text, this.nVisibleLines, this.style,
      {this.onScrolled, Key? key})
      : super(key: key);

  @override
  State<ScrollingLines> createState() => _ScrollingLinesState();
}

class _ScrollingLinesState extends State<ScrollingLines>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentLineIndex;
  late bool _scrollingUp, _scrollingDown;
  late int _linesLength;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _currentLineIndex = 0;
    _scrollingUp = false;
    _scrollingDown = false;
    _linesLength = 0;
    _animate();
  }

  double? _cachedMinWidth, _cachedMaxWidth;
  List<TextRange>? _cachedLineRanges;
  List<String>? _cachedLines;

  List<String> _getTextLines(double minWidth, maxWidth) {
    if (minWidth == _cachedMinWidth && maxWidth == _cachedMaxWidth) {
      return _cachedLines!;
    }
    // TODO: Generalize text direction
    var painter = TextPainter(
        text: TextSpan(text: widget.text, style: widget.style),
        textDirection: TextDirection.ltr);
    painter.layout(minWidth: minWidth, maxWidth: maxWidth);
    var lines = <String>[];
    var lineRanges = <TextRange>[];
    var offset = 0;
    while (true) {
      var range = painter.getLineBoundary(TextPosition(offset: offset + 1));
      lineRanges.add(range);
      lines.add(range.textInside(widget.text));
      offset = range.end;
      if (offset >= widget.text.length) {
        break;
      }
    }
    _cachedMinWidth = minWidth;
    _cachedMaxWidth = maxWidth;
    _cachedLineRanges = lineRanges;
    _cachedLines = lines;
    return lines;
  }

  void _animate() {
    _animation = CurveTween(curve: Curves.easeInOut).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scrollingUp = false;
          _scrollingDown = false;
        }
      });
    _controller.reset();
    if (_scrollingUp || _scrollingDown) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  void _scrollTop() {
    setState(() {
      _currentLineIndex = 0;
    });
    _emitOnScrolled();
  }

  void _scrollBottom() {
    setState(() {
      _currentLineIndex = _linesLength - widget.nVisibleLines;
    });
    _emitOnScrolled();
  }

  void _scrollUp() {
    setState(() {
      _currentLineIndex--;
      _scrollingUp = true;
      _scrollingDown = false;
    });
    _emitOnScrolled();
    _animate();
  }

  void _scrollDown() {
    setState(() {
      _currentLineIndex++;
      _scrollingUp = false;
      _scrollingDown = true;
    });
    _emitOnScrolled();
    _animate();
  }

  void _emitOnScrolled() {
    var onScrolled = widget.onScrolled;
    var _cachedLineRanges = this._cachedLineRanges;
    if (onScrolled != null && _cachedLineRanges != null) {
      var firstVisibleLineIndex = max(_currentLineIndex, 0);
      var lastVisibleLineIndex = min(
          _currentLineIndex + widget.nVisibleLines - 1,
          _cachedLineRanges.length);
      onScrolled(TextRange(
          start: _cachedLineRanges[firstVisibleLineIndex].start,
          end: _cachedLineRanges[lastVisibleLineIndex].end));
    }
  }

  @override
  Widget build(BuildContext context) {
    var scrollableUp = _currentLineIndex > 0;
    var scrollableDown =
        _currentLineIndex < _linesLength - widget.nVisibleLines;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: ReadingWidth(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var lines =
                      _getTextLines(constraints.minWidth, constraints.maxWidth);
                  if (lines.length != _linesLength) {
                    // Number of lines has changed due to layout change; try to map
                    // `_currentLineIndex` so that roughly the same text will be visible
                    // as before. This needs to be done after `build()`, as it needs to call
                    // `setState` and rebuild again.
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      setState(() {
                        if (_linesLength > 0) {
                          _currentLineIndex =
                              (_currentLineIndex / _linesLength * lines.length)
                                  .round();
                        }
                        _linesLength = lines.length;
                      });
                    });
                  }
                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      var firstLineIndex = _scrollingDown
                          ? _currentLineIndex - 1
                          : _currentLineIndex;
                      var lastLineIndex = _scrollingUp
                          ? _currentLineIndex + widget.nVisibleLines + 1
                          : _currentLineIndex + widget.nVisibleLines;
                      var visibleLines = lines.sublist(
                          firstLineIndex.clamp(0, lines.length),
                          lastLineIndex.clamp(0, lines.length));
                      if (firstLineIndex < 0) {
                        visibleLines.insertAll(0, [
                          for (var i = 0;
                              i < min(-firstLineIndex, widget.nVisibleLines);
                              i++)
                            ''
                        ]);
                      }
                      if (lastLineIndex >= lines.length) {
                        visibleLines.addAll([
                          for (var i = 0;
                              i <
                                  min(lastLineIndex - lines.length,
                                      widget.nVisibleLines);
                              i++)
                            ''
                        ]);
                      }
                      var offset = _scrollingDown
                          ? -_animation.value
                          : _animation.value - 1;
                      var firstLineOpacity = _scrollingDown
                          ? 1 - _animation.value
                          : _animation.value;
                      var lastLineOpacity = _scrollingUp
                          ? 1 - _animation.value
                          : _animation.value;
                      var linesHeight = widget.style.fontSize! *
                          widget.style.height! *
                          widget.nVisibleLines;
                      if (constraints.maxHeight < linesHeight) {
                        debugPrint('too small!');
                        // TODO: Ask to rotate device
                      }
                      return CustomPaint(
                        painter: LinePainter(visibleLines, offset,
                            firstLineOpacity, lastLineOpacity, widget.style),
                        size: Size(constraints.maxWidth, linesHeight),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: scrollableUp ? _scrollTop : null,
              icon: const Icon(Icons.vertical_align_top),
            ),
            const Spacer(),
            IconButton(
              onPressed: scrollableUp ? _scrollUp : null,
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              onPressed: scrollableDown ? _scrollDown : null,
              icon: const Icon(Icons.arrow_downward),
            ),
            const Spacer(),
            IconButton(
              onPressed: scrollableDown ? _scrollBottom : null,
              icon: const Icon(Icons.vertical_align_bottom),
            ),
          ],
        ),
        RotatedBox(
          quarterTurns: 1,
          child: AnimatedLinearProgressIndicator(
            _currentLineIndex / (_linesLength - widget.nVisibleLines),
            height: 4.0,
            duration: const Duration(milliseconds: 200),
          ),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  final List<String> lines;
  final double offset;
  final double firstLineOpacity, lastLineOpacity;
  final TextStyle style;

  LinePainter(this.lines, this.offset, this.firstLineOpacity,
      this.lastLineOpacity, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < lines.length; i++) {
      var lineStyle = style;
      if (i == 0 && firstLineOpacity != 1) {
        lineStyle = style.copyWith(
            color:
                Color.lerp(Colors.transparent, style.color, firstLineOpacity));
      } else if (i == lines.length - 1 && lastLineOpacity != 1) {
        lineStyle = style.copyWith(
            color:
                Color.lerp(Colors.transparent, style.color, lastLineOpacity));
      }
      var painter = TextPainter(
          text: TextSpan(text: lines[i], style: lineStyle),
          textDirection: TextDirection.ltr);
      painter.layout();
      var lineHeight = painter.computeLineMetrics().first.height;
      painter.paint(canvas, Offset(0, (i + offset) * lineHeight));
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return lines != oldDelegate.lines || offset != oldDelegate.offset;
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
  final int nVisibleLines;
  final double fontSize;
  final double lineSpacing;
  int _currentQuestionIndex;
  final List<int?> _selectedAnswerIndices;

  QuestionsStage(this.questions,
      {this.text,
      this.nVisibleLines = 0,
      this.fontSize = 20,
      this.lineSpacing = 1.2})
      : _currentQuestionIndex = 0,
        _selectedAnswerIndices = [
          for (var i = 0; i < questions.length; i++) null
        ];

  @override
  Widget build(BuildContext context) {
    var text = this.text;
    var pageController = PageController();
    pageController.addListener(() {
      _currentQuestionIndex = pageController.page!.round();
    });
    return Column(
      children: [
        if (text != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Center(
                child: ReadingWidth(
                  child: ScrollingLines(
                    text,
                    nVisibleLines,
                    TextStyle(
                        fontSize: fontSize,
                        height: lineSpacing,
                        color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        Container(
          color: Theme.of(context).highlightColor,
          height: 200,
          alignment: Alignment.center,
          child: ReadingWidth(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    pageController.animateToPage(
                      _currentQuestionIndex - 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: [
                      for (var i = 0; i < questions.length; i++)
                        QuestionCard(
                          questions[i],
                          selectedAnswerIndex: _selectedAnswerIndices[i],
                          onAnswerChanged: (answerIndex) {
                            setState(() {
                              _selectedAnswerIndices[i] = answerIndex;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    pageController.animateToPage(
                      _currentQuestionIndex + 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double? getProgress() => null;
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final int? selectedAnswerIndex;
  final Function(int?) onAnswerChanged;

  const QuestionCard(this.question,
      {required this.selectedAnswerIndex,
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
      return Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.bold),
                ),
                for (var i = 0; i < question.answers.length; i++)
                  Row(
                    children: [
                      Radio(
                        value: i,
                        groupValue: selectedAnswerIndex,
                        onChanged: onAnswerChanged,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onAnswerChanged(i),
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
