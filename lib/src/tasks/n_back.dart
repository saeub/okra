import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'task.dart';

class NBack extends Task {
  static const initialDelayDuration = Duration(milliseconds: 500);
  static const feedbackDuration = Duration(milliseconds: 500);

  int _n;
  Duration _stimulusDuration, _betweenStimuliDuration;
  List<String> _stimuli;
  int _currentStimulusIndex;
  bool _stimulusVisible;
  bool _feedback, _feedbacked;
  int _nTruePositives, _nFalsePositives;

  @override
  void init(Map<String, dynamic> data) {
    _n = data['n'];
    num secondsShowingStimulus = data['secondsShowingStimulus'] ?? 0.5;
    _stimulusDuration =
        Duration(milliseconds: (secondsShowingStimulus * 1000).round());
    num secondsBetweenStimuli = data['secondsBetweenStimuli'] ?? 2.5;
    _betweenStimuliDuration =
        Duration(milliseconds: (secondsBetweenStimuli * 1000).round());

    var stimulusChoices = Set<String>.from(data['stimulusChoices']).toList();
    int nStimuli = data['nStimuli'];
    int nPositives = data['nPositives'];
    _stimuli = generateStimuli(stimulusChoices, nStimuli, nPositives, _n);
    logger.log('generated stimuli', {
      'stimuli': _stimuli.toList(growable: false),
      'positive': [
        for (int i = 0; i < _stimuli.length; i++) _isPositiveStimulus(i)
      ],
    });
    _currentStimulusIndex = -1;
    _stimulusVisible = false;
    _feedbacked = false;
    _nTruePositives = _nFalsePositives = 0;
    Future.delayed(initialDelayDuration).then((_) {
      _nextStimulus();
    });
  }

  @override
  double getProgress() {
    return _currentStimulusIndex / _stimuli.length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          await Future.delayed(feedbackDuration);
          setState(() {
            _feedback = null;
          });
          logger.log('finished feedback', {
            'stimulus': _currentStimulusIndex,
          });
        }
      },
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: _feedback != null,
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                child: Icon(
                  _feedback == true ? Icons.thumb_up : Icons.thumb_down,
                  color: _feedback == true ? Colors.green : Colors.red,
                  size: 50.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 66.0),
                child: Visibility(
                  visible: _currentStimulusIndex >= 0 && _stimulusVisible,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Text(
                    _currentStimulusIndex >= 0
                        ? _stimuli[_currentStimulusIndex]
                        : '',
                    style: TextStyle(
                      fontSize: 50.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      await Future.delayed(_stimulusDuration);
      setState(() {
        _stimulusVisible = false;
      });
      logger.log('finished showing stimulus', {
        'stimulus': _currentStimulusIndex,
      });
      await Future.delayed(_betweenStimuliDuration);
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
