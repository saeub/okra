import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'task.dart';

class NBack extends Task {
  int _n;
  List<String> _stimuli;
  int _currentStimulusIndex;
  bool _stimulusVisible;
  bool _feedback;

  @override
  void init(Map<String, dynamic> data) {
    _n = data['n'];
    List<String> stimulusChoices = data['stimulusChoices'].cast<String>();
    int nStimuli = data['nStimuli'];
    int nPositives = data['nPositives'];
    _stimuli = generateStimuli(stimulusChoices, nStimuli, nPositives, _n);
    _currentStimulusIndex = 0;
    _stimulusVisible = false;
    _nextStimulus();
  }

  @override
  double getProgress() {
    return _currentStimulusIndex / _stimuli.length;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ColoredBox(
        color: _feedback == null
            ? Theme.of(context).scaffoldBackgroundColor
            : _feedback
                ? Colors.green[100]
                : Colors.red[100],
        child: SizedBox.expand(
          child: Column(
            children: [
              Spacer(flex: 1),
              Visibility(
                visible: _feedback != null,
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                child: Icon(
                  _feedback == true ? Icons.thumb_up : Icons.thumb_down,
                  color: _feedback == true ? Colors.green : Colors.red,
                ),
              ),
              Spacer(flex: 1),
              Visibility(
                visible: _stimulusVisible,
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                child: Text(
                  _stimuli[_currentStimulusIndex],
                  style: TextStyle(
                    fontSize: 50.0,
                  ),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
      onTapDown: (details) async {
        setState(() {
          if (_currentStimulusIndex >= _n &&
              _stimuli[_currentStimulusIndex] ==
                  _stimuli[_currentStimulusIndex - _n]) {
            _feedback = true;
          } else {
            _feedback = false;
          }
        });
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {
          _feedback = null;
        });
      },
    );
  }

  Future<void> _nextStimulus() async {
    if (_currentStimulusIndex < _stimuli.length - 1) {
      setState(() {
        _currentStimulusIndex++;
        _stimulusVisible = true;
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _stimulusVisible = false;
      });
      await Future.delayed(Duration(milliseconds: 2500));
      _nextStimulus(); // ignore: unawaited_futures
    } else {
      // TODO: Collect result data
      finish();
    }
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
