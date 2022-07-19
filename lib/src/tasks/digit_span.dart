import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import 'task.dart';

class DigitSpan extends Task {
  late final int _maxErrors;
  late final List<int> _digits;
  late List<int> _currentSpan;
  late int _nextSpanLength;
  late int _nErrors;
  late bool _responding;
  late final Random _random;

  @override
  void init(Map<String, dynamic> data) {
    _maxErrors = data['maxErrors'] ?? 2;
    List<int> excludeDigits = data['excludeDigits']?.cast<int>() ?? [];
    _digits = [
      for (var i = 0; i < 10; i++)
        if (!excludeDigits.contains(i)) i
    ];
    if (_digits.length < 2) {
      throw ArgumentError('At least two digits must be allowed');
    }
    _nextSpanLength = data['initialLength'] ?? 3;
    _nErrors = 0;
    _responding = false;
    _random = Random();
    _nextTrial();
  }

  void _nextTrial() {
    _currentSpan = [];
    while (_currentSpan.length < _nextSpanLength) {
      var nextDigitIndex = _random.nextInt(_digits.length);
      var nextDigit = _digits[nextDigitIndex];
      if (_currentSpan.isEmpty || nextDigit != _currentSpan.last) {
        _currentSpan.add(nextDigit);
      }
    }
    _responding = false;
    logger.log('started displaying span', {'span': _currentSpan});
  }

  @override
  double? getProgress() => null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: !_responding
            ? DigitSpanDisplay(
                _currentSpan,
                onFinished: () {
                  logger
                      .log('finished displaying span', {'span': _currentSpan});
                  setState(() {
                    _responding = true;
                  });
                },
              )
            : DigitSpanInput(
                onSubmit: (digits) {
                  logger.log('submitted response',
                      {'response': digits, 'correct': _currentSpan});
                  if (listEquals(digits, _currentSpan)) {
                    _nextSpanLength++;
                    _nErrors = 0;
                  } else {
                    _nErrors++;
                    if (_nErrors >= _maxErrors) {
                      finish();
                      return;
                    }
                  }
                  setState(() {
                    _nextTrial();
                  });
                },
              ),
      ),
    );
  }
}

class DigitSpanDisplay extends StatefulWidget {
  final List<int> span;
  final Function() onFinished;

  const DigitSpanDisplay(this.span, {required this.onFinished, Key? key})
      : super(key: key);

  @override
  State<DigitSpanDisplay> createState() => _DigitSpanDisplayState();
}

class _DigitSpanDisplayState extends State<DigitSpanDisplay> {
  int? _currentDigit;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < widget.span.length; i++) {
      setState(() {
        _currentDigit = widget.span[i];
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _currentDigit = null;
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentDigit != null ? _currentDigit.toString() : '',
      style: const TextStyle(fontSize: 50.0),
    );
  }
}

class DigitSpanInput extends StatefulWidget {
  final Function(List<int> digits) onSubmit;

  const DigitSpanInput({required this.onSubmit, Key? key}) : super(key: key);

  @override
  State<DigitSpanInput> createState() => _DigitSpanInputState();
}

class _DigitSpanInputState extends State<DigitSpanInput> {
  late final List<int> _content;

  @override
  void initState() {
    super.initState();
    _content = [];
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(_content.join(),
                    softWrap: true,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                onPressed: _content.isNotEmpty
                    ? () {
                        setState(() {
                          _content.removeLast();
                        });
                      }
                    : null,
                icon: const Icon(Icons.backspace),
              ),
            ],
          ),
          Column(
            children: [
              for (var i = 1; i <= 9; i += 3)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var j = i; j < i + 3; j++)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DigitButton(
                          j,
                          onPressed: () {
                            setState(() {
                              _content.add(j);
                            });
                          },
                        ),
                      ),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: DigitButton(
                      0,
                      onPressed: () {
                        setState(() {
                          _content.add(0);
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          ElevatedButton.icon(
            onPressed:
                _content.isNotEmpty ? () => widget.onSubmit(_content) : null,
            icon: const Icon(Icons.check),
            label: Text(S.of(context).taskAdvance),
          )
        ],
      ),
    );
  }
}

class DigitButton extends StatelessWidget {
  final int digit;
  final Function() onPressed;

  const DigitButton(this.digit, {required this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const CircleBorder()),
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade700),
        minimumSize: MaterialStateProperty.all(const Size(50.0, 50.0)),
        textStyle: MaterialStateProperty.all(const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        )),
      ),
      onPressed: onPressed,
      child: Text(digit.toString()),
    );
  }
}
