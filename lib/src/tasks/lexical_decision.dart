import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../colors.dart';
import 'task.dart';

class LexicalDecision extends Task {
  late List<String> _words;
  late int _currentWordIndex;
  String? _visibleWord;
  List<bool>? _correctAnswers;
  bool? _feedback;

  @override
  void init(Map<String, dynamic> data) {
    _words = data['words'].cast<String>();
    _currentWordIndex = -1;
    _correctAnswers = data['correctAnswers']?.cast<bool>();
    _nextWord();
  }

  void _nextWord() async {
    _currentWordIndex++;
    setState(() {
      _visibleWord = null;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _visibleWord = _words[_currentWordIndex];
    });
    logger.log('started word', {'word': _currentWordIndex});
  }

  @override
  Widget build(BuildContext context) {
    var _visibleWord = this._visibleWord;
    var buttonsEnabled = _visibleWord != null;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30.0),
                        Container(
                          constraints: const BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                          child: _visibleWord != null
                              ? Text(
                                  _visibleWord,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 40.0,
                                  ),
                                )
                              : _feedback != null
                                  ? _feedback == true
                                      ? const Icon(
                                          Icons.thumb_up,
                                          color: AppColors.positive,
                                          size: 50.0,
                                        )
                                      : const Icon(
                                          Icons.thumb_down,
                                          color: AppColors.negative,
                                          size: 50.0,
                                        )
                                  : null,
                        ),
                        Icon(Icons.arrow_drop_up,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 30.0),
                      ],
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 500.0, maxHeight: 200.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: ElevatedButton(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, size: 50.0),
                                Text(
                                  S.of(context).taskLexicalDecisionWord,
                                  style: const TextStyle(fontSize: 20.0),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(AppColors.positive),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed:
                                buttonsEnabled ? () => _onTap(true) : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: ElevatedButton(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.clear, size: 50.0),
                                Text(
                                  S.of(context).taskLexicalDecisionNonword,
                                  style: const TextStyle(fontSize: 20.0),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(AppColors.negative),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
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

  void _onTap(bool answer) async {
    logger.log('finished word', {'word': _currentWordIndex, 'answer': answer});
    _visibleWord = null;
    var _correctAnswers = this._correctAnswers;
    if (_correctAnswers != null) {
      setState(() {
        _feedback = answer == _correctAnswers[_currentWordIndex];
      });
      logger.log('started feedback',
          {'word': _currentWordIndex, 'positive': _feedback});
      await Future.delayed(const Duration(milliseconds: 600));
      _feedback = null;
      logger.log('finished feedback', {'word': _currentWordIndex});
    }
    if (_currentWordIndex < _words.length - 1) {
      _nextWord();
    } else {
      finish();
    }
  }
}
