import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'task.dart';

class NBack extends Task {
  int _n;
  List<String> _stimuli;
  int _currentStimulusIndex;
  bool _stimulusVisible;
  bool _feedback, _feedbacked;
  int _nTruePositives, _nFalsePositives;

  @override
  void init(Map<String, dynamic> data) {
    _n = data['n'];
    var stimulusChoices = Set<String>.from(data['stimulusChoices']).toList();
    int nStimuli = data['nStimuli'];
    int nPositives = data['nPositives'];
    _stimuli = generateStimuli(stimulusChoices, nStimuli, nPositives, _n);
    logger.log('generated stimuli', {
      'stimuli': _stimuli,
      'positive': [
        for (int i = 0; i < _stimuli.length; i++) _isPositiveStimulus(i)
      ],
    });
    _currentStimulusIndex = -1;
    _stimulusVisible = false;
    _feedbacked = false;
    _nTruePositives = _nFalsePositives = 0;
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      _nextStimulus();
    });
  }

  @override
  double getProgress() {
    return _currentStimulusIndex / _stimuli.length;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_stimulusVisible &&
        _currentStimulusIndex >= 0 &&
        (_feedback == null || !_feedbacked)) {
      content = Text(
        _currentStimulusIndex >= 0 ? _stimuli[_currentStimulusIndex] : '',
        style: TextStyle(
          fontSize: 50.0,
        ),
      );
    } else if (_feedback != null) {
      content = Icon(
        _feedback == true ? Icons.thumb_up : Icons.thumb_down,
        color: _feedback == true ? Colors.green : Colors.red,
        size: 50.0,
      );
    }
    return GestureDetector(
      child: ColoredBox(
        color: _feedback == null
            ? Theme.of(context).scaffoldBackgroundColor
            : _feedback
                ? Colors.green[100]
                : Colors.red[100],
        child: Center(
          child: content,
        ),
      ),
      onTapDown: (details) async {
        logger.log('tapped screen', {
          'stimulus': _currentStimulusIndex,
        });
        if (_currentStimulusIndex >= 0 && !_feedbacked) {
          setState(() {
            if (_isPositiveStimulus(_currentStimulusIndex)) {
              _feedback = true;
              _nTruePositives++;
            } else {
              _feedback = false;
              _nFalsePositives++;
            }
          });
          _feedbacked = true;
          logger.log('started feedback', {
            'stimulus': _currentStimulusIndex,
            'feedback': _feedback,
          });
          await Future.delayed(Duration(milliseconds: 500));
          setState(() {
            _feedback = null;
          });
          logger.log('stopped feedback', {
            'stimulus': _currentStimulusIndex,
          });
        }
      },
    );
  }

  Future<void> _nextStimulus() async {
    _feedbacked = false;
    if (_currentStimulusIndex < _stimuli.length - 1) {
      setState(() {
        _currentStimulusIndex++;
        _stimulusVisible = true;
      });
      logger.log('started showing stimulus', {
        'stimulus': _currentStimulusIndex,
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _stimulusVisible = false;
      });
      logger.log('stopped showing stimulus', {
        'stimulus': _currentStimulusIndex,
      });
      await Future.delayed(Duration(milliseconds: 2500));
      _nextStimulus(); // ignore: unawaited_futures
    } else {
      finish(data: {
        'nTruePositives': _nTruePositives,
        'nFalsePositives': _nFalsePositives,
      });
    }
  }

  bool _isPositiveStimulus(int index) {
    return index >= _n && _stimuli[index] == _stimuli[index - _n];
  }

  static List<String> generateStimuli(
      List<String> stimulusChoices, int nStimuli, int nPositives, int n) {
    if (stimulusChoices.length <= 1) {
      throw ArgumentError('stimulusChoices must contain at least 2 stimuli');
    }
    if (nPositives > nStimuli - n) {
      throw ArgumentError('nPositives must not be larger than (nStimuli - n)');
    }
    var positiveIndices = <int>{};
    var random = Random();
    while (positiveIndices.length < nPositives) {
      int randomIndex;
      do {
        randomIndex = random.nextInt(nStimuli - n) + n;
      } while (positiveIndices.contains(randomIndex));
      positiveIndices.add(randomIndex);
    }
    var stimuli = <String>[];
    for (var i = 0; i < nStimuli; i++) {
      String stimulus;
      if (positiveIndices.contains(i)) {
        // Positive stimulus
        stimulus = stimuli[i - n];
      } else {
        // Negative stimulus
        do {
          stimulus = stimulusChoices[random.nextInt(stimulusChoices.length)];
        } while (i >= n && stimulus == stimuli[i - n]);
      }
      stimuli.add(stimulus);
    }
    return stimuli;
  }
}
