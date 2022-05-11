import 'dart:math';

import 'package:flutter/material.dart';

import 'task.dart';

class SimonGame extends Task {
  static const maxSize = 400.0;
  static const colors = <MaterialColor>[
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.blue,
  ];
  static final shapes = <Path>[
    Path()..addOval(const Rect.fromLTRB(-1.1, -1.1, 1.1, 1.1)),
    Path()
      ..addPolygon([
        const Offset(-1.0, -1.0),
        const Offset(1.0, -1.0),
        const Offset(1.0, 1.0),
        const Offset(-1.0, 1.0),
      ], true),
    Path()
      ..addPolygon([
        const Offset(0, -1.4),
        const Offset(1.4, 0),
        const Offset(0, 1.4),
        const Offset(-1.4, 0),
      ], true),
    (Path()
          ..addPolygon([
            const Offset(0, -1.4),
            Offset(1.4 * cos(pi * 1 / 6), 1.4 * sin(pi * 1 / 6)),
            Offset(-1.4 * cos(pi * 1 / 6), 1.4 * sin(pi * 1 / 6)),
          ], true))
        .shift(const Offset(0, 0.2)),
  ];

  late List<int> _sequence;
  int? _currentRepetitionIndex;
  int? _highlight;
  bool? _feedback;
  late Random _random;

  @override
  void init(Map<String, dynamic> data) {
    _random = Random();
    _sequence = [];
    _nextSequence();
  }

  @override
  double? getProgress() => null;

  @override
  Widget build(BuildContext context) {
    var _feedback = this._feedback;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                var size = min(constraints.maxWidth, constraints.maxHeight);
                if (size > maxSize) {
                  size = maxSize;
                }
                return SizedBox(
                  width: size,
                  height: size,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < colors.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            key: ValueKey(colors[i]),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  colors[i][_highlight == i ? 100 : 700]),
                            ),
                            onPressed: _feedback == null &&
                                    _currentRepetitionIndex != null
                                ? () => _onTap(i)
                                : null,
                            child: SizedBox.expand(
                              child: CustomPaint(
                                foregroundPainter: ShapePainter(shapes[i]),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_feedback != null)
            Center(
              child: Card(
                color: _feedback ? Colors.green[800] : Colors.red[800],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _feedback ? Icons.thumb_up : Icons.thumb_down,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _nextSequence() async {
    setState(() {
      _currentRepetitionIndex = null;
      _feedback = null;
    });
    int nextItem;
    do {
      nextItem = _random.nextInt(colors.length);
    } while (_sequence.isNotEmpty && nextItem == _sequence.last);
    _sequence.add(nextItem);
    logger.log(
        'started watching', {'sequence': _sequence.toList(growable: false)});
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < _sequence.length; i++) {
      setState(() {
        _highlight = _sequence[i];
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _highlight = null;
      });
      if (i < _sequence.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    logger.log('finished watching');
    setState(() {
      _currentRepetitionIndex = 0;
      _highlight = null;
    });
    logger.log(
        'started repeating', {'sequence': _sequence.toList(growable: false)});
  }

  void _onTap(int index) {
    if (index == _sequence[_currentRepetitionIndex!]) {
      _currentRepetitionIndex = _currentRepetitionIndex! + 1;
      if (_currentRepetitionIndex! >= _sequence.length) {
        logger.log('finished repeating');
        setState(() {
          _feedback = true;
        });
        logger.log('started feedback', {'feedback': _feedback});
        Future.delayed(const Duration(milliseconds: 1000)).then((_) {
          logger.log('finished feedback');
          _nextSequence();
        });
      }
    } else {
      logger.log('finished repeating');
      setState(() {
        _feedback = false;
      });
      logger.log('started feedback', {'feedback': _feedback});
      Future.delayed(const Duration(milliseconds: 1000)).then((_) {
        logger.log('finished feedback', {'feedback': _feedback});
        finish(data: {
          'maxCorrectItems': _sequence.length - 1,
        });
      });
    }
  }
}

class ShapePainter extends CustomPainter {
  final Path shape;

  ShapePainter(this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    var matrix = Matrix4.identity();
    matrix.translate(size.width / 2, size.height / 2);
    matrix.scale(size.width / 7);
    var scaledShape = shape.transform(matrix.storage);
    canvas.drawPath(scaledShape, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
