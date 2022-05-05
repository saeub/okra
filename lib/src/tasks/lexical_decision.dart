import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import 'task.dart';

class LexicalDecision extends Task {
  late List<String> _words;
  late int _currentWordIndex;
  List<bool>? _correctAnswers;
  late int _countdown;
  bool? _feedback;
  late DateTime _answerStart;
  late List<bool> _answers;
  late List<Duration> _answerDurations;

  @override
  void init(Map<String, dynamic> data) {
    _words = data['words'].cast<String>();
    _currentWordIndex = -1;
    _correctAnswers = data['correctAnswers']?.cast<bool>();
    _answers = [];
    _answerDurations = [];
    _startCountdown().then((_) {
      logger.log('finished countdown');
      setState(() {
        _currentWordIndex = 0;
        _answerStart = DateTime.now();
      });
      logger.log('started word', {'word': _currentWordIndex});
    });
  }

  @override
  double? getProgress() => _feedback == null
      ? _currentWordIndex / _words.length
      : (_currentWordIndex + 1) / _words.length;

  @override
  Widget build(BuildContext context) {
    var buttonsEnabled = _currentWordIndex >= 0 && _feedback == null;
    // TODO: Fix layout (buttons change size when feedback appears)
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Spacer(),
                _currentWordIndex == -1
                    ? Text(
                        _countdown.toString(),
                        style: const TextStyle(
                          fontSize: 30.0,
                        ),
                      )
                    : _feedback == null
                        ? Text(
                            _words[_currentWordIndex],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30.0,
                            ),
                          )
                        : _feedback == true
                            ? const Icon(
                                Icons.thumb_up,
                                color: Colors.green,
                                size: 50.0,
                              )
                            : const Icon(
                                Icons.thumb_down,
                                color: Colors.red,
                                size: 50.0,
                              ),
                const Spacer(),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(S.of(context).taskLexicalDecisionWord),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            onPressed:
                                buttonsEnabled ? () => _onTap(true) : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.clear),
                            label:
                                Text(S.of(context).taskLexicalDecisionNonword),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed:
                                buttonsEnabled ? () => _onTap(false) : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startCountdown() async {
    logger.log('started countdown');
    _countdown = 4;
    while (_countdown > 1) {
      setState(() {
        _countdown--;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _onTap(bool answer) async {
    _answerDurations.add(DateTime.now().difference(_answerStart));
    logger.log('finished word', {'word': _currentWordIndex, 'answer': answer});
    _answers.add(answer);
    var _correctAnswers = this._correctAnswers;
    if (_correctAnswers != null) {
      logger.log('started feedback', {'word': _currentWordIndex});
      setState(() {
        _feedback = answer == _correctAnswers[_currentWordIndex];
      });
      await Future.delayed(const Duration(milliseconds: 600));
      logger.log('finished feedback', {'word': _currentWordIndex});
      _feedback = null;
    }
    if (_currentWordIndex < _words.length - 1) {
      setState(() {
        _currentWordIndex++;
        _answerStart = DateTime.now();
        logger.log('started word', {'word': _currentWordIndex});
      });
    } else {
      finish(data: {
        'answers': _answers,
        'durations': _answerDurations
            .map((duration) => duration.inMilliseconds / 1000)
            .toList(),
      });
    }
  }
}
