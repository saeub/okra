import 'dart:math';

import 'package:flutter/material.dart';

import '../util.dart';
import 'task.dart';

class Reading extends MultistageTask {
  late final String _text;
  late final ScrollingTextStage _textStage;

  @override
  void init(Map<String, dynamic> data) {
    _text = data['text'];
    _textStage = ScrollingTextStage(_text, data['nVisibleLines'],
        fontSize: data['fontSize'] ?? 20.0, lineSpacing: 1.2);
    super.init(data);
  }

  @override
  TaskStage? getNextStage(TaskStage? previousStage) {
    if (previousStage == null) {
      return _textStage;
    }
    finish();
    return null;
  }
}

class ScrollingTextStage extends TaskStage {
  final String text;
  final int nVisibleLines;
  final double fontSize;
  final double lineSpacing;

  ScrollingTextStage(this.text, this.nVisibleLines,
      {this.fontSize = 20, this.lineSpacing = 1.2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Expanded(
            child: ScrollingLines(
                text,
                nVisibleLines,
                Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: fontSize, height: lineSpacing)),
          ),
          TextButton(onPressed: finish, child: const Text('DONE'))
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

  const ScrollingLines(this.text, this.nVisibleLines, this.style, {Key? key})
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
    var offset = 0;
    while (true) {
      var position = painter.getLineBoundary(TextPosition(offset: offset + 1));
      lines.add(position.textInside(widget.text));
      offset = position.end;
      if (offset >= widget.text.length) {
        break;
      }
    }
    _cachedMinWidth = minWidth;
    _cachedMaxWidth = maxWidth;
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
  }

  void _scrollBottom() {
    setState(() {
      _currentLineIndex = _linesLength - widget.nVisibleLines;
    });
  }

  void _scrollUp() {
    setState(() {
      _currentLineIndex--;
      _scrollingUp = true;
      _scrollingDown = false;
    });
    _animate();
  }

  void _scrollDown() {
    setState(() {
      _currentLineIndex++;
      _scrollingUp = false;
      _scrollingDown = true;
    });
    _animate();
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300.0),
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
                      return CustomPaint(
                        painter: LinePainter(visibleLines, offset,
                            firstLineOpacity, lastLineOpacity, widget.style),
                        size: Size(
                            constraints.maxWidth,
                            widget.style.fontSize! *
                                widget.style.height! *
                                widget.nVisibleLines),
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
