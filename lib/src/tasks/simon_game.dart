import 'dart:math';

import 'package:flutter/material.dart';
import 'package:okra/src/util.dart';
import 'task.dart';

class SimonGame extends Task {
  static var colors = <MaterialColor>[
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.blue,
  ];

  List<int> _sequence;
  int _highlight;
  int _currentRepetitionIndex;
  bool _feedback;
  Random _random;

  @override
  void init(Map<String, dynamic> data) {
    _random = Random();
    _sequence = [];
    _nextSequence();
  }

  @override
  double getProgress() => null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            _currentRepetitionIndex == null ? 'WATCH!' : 'REPEAT!',
            style: TextStyle(fontSize: 30.0),
          ),
          Flexible(
            child: Stack(
              children: [
                Center(
                  child: ReadingWidth(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        var size =
                            min(constraints.maxWidth, constraints.maxHeight);
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
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(colors[i]
                                              [_highlight == i ? 200 : 600]),
                                    ),
                                    onPressed: _feedback == null &&
                                            _currentRepetitionIndex != null
                                        ? () {
                                            if (i ==
                                                _sequence[
                                                    _currentRepetitionIndex]) {
                                              _currentRepetitionIndex++;
                                              if (_currentRepetitionIndex >=
                                                  _sequence.length) {
                                                setState(() {
                                                  _feedback = true;
                                                });
                                                Future.delayed(Duration(
                                                        milliseconds: 1000))
                                                    .then(
                                                        (_) => _nextSequence());
                                              }
                                            } else {
                                              setState(() {
                                                _feedback = false;
                                              });
                                              Future.delayed(Duration(
                                                      milliseconds: 1000))
                                                  .then((_) => finish());
                                            }
                                          }
                                        : null,
                                    child: Container(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _nextSequence() async {
    setState(() {
      _feedback = null;
    });
    _currentRepetitionIndex = null;
    _sequence.add(_random.nextInt(colors.length));
    await Future.delayed(Duration(milliseconds: 500));
    for (var i = 0; i < _sequence.length; i++) {
      setState(() {
        _highlight = _sequence[i];
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _highlight = null;
      });
      await Future.delayed(Duration(milliseconds: 200));
    }
    setState(() {
      _highlight = null;
    });
    _currentRepetitionIndex = 0;
  }
}
