import 'dart:math';

import 'package:flutter/src/widgets/framework.dart';
import 'package:okra/src/tasks/task.dart';

class NBack extends Task {
  int _n;
  List<String> _stimulusChoices;
  List<String> _stimuli;
  int _currentStimulusIndex;

  @override
  void init(Map<String, dynamic> data) {
    _n = data['n'];
    _stimulusChoices = data['stimulusChoices'];
    var nStimuli = data['nStimuli'];
    var nPositives = data['nPositives'];
    _stimuli = [];
  }

  @override
  double getProgress() {
    return _currentStimulusIndex / _stimuli.length;
  }

  @override
  Widget build(BuildContext context) {
    // TODO
    throw UnimplementedError();
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
