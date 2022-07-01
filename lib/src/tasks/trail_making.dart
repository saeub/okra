import 'dart:math';

import 'package:flutter/material.dart';

import 'task.dart';

class Stimulus {
  final String text;
  final Offset position;
  bool tapped;

  Stimulus(this.text, this.position) : tapped = false;
}

class TrailMaking extends Task {
  static const buttonSize = 45.0;
  static const buttonMargin = 20.0;
  static const errorIconSize = 100.0;

  late int _gridWidth;
  late int _gridHeight;
  late List<Stimulus> _stimuli;
  late int _currentStimulusIndex;
  Stimulus? _errorStimulus;

  @override
  void init(Map<String, dynamic> data) {
    _stimuli = [];
    List<String> stimulusTexts = data['stimuli'].cast<String>();
    _gridWidth = data['gridWidth'] ?? sqrt(stimulusTexts.length * 2).ceil();
    _gridHeight = data['gridHeight'] ?? sqrt(stimulusTexts.length * 2).ceil();
    var freeGridPositions = [
      for (var i = 0; i < _gridWidth; i++)
        for (var j = 0; j < _gridHeight; j++) Point(i, j)
    ];
    if (stimulusTexts.length > freeGridPositions.length) {
      throw ArgumentError(
          'Number of stimuli must not exceed ${freeGridPositions.length}');
    }

    int? randomSeed = data['randomSeed'];
    bool jiggle = data['jiggle'] ?? false;
    var random = Random(randomSeed);
    for (var text in stimulusTexts) {
      // Pop random free position
      var position =
          freeGridPositions.removeAt(random.nextInt(freeGridPositions.length));
      var jiggleOffsetX = 0.0;
      var jiggleOffsetY = 0.0;
      if (jiggle) {
        jiggleOffsetX = random.nextDouble() * buttonMargin - buttonMargin / 2;
        jiggleOffsetY = random.nextDouble() * buttonMargin - buttonMargin / 2;
      }
      _stimuli.add(
        Stimulus(
          text,
          Offset(
            buttonMargin +
                position.x * (buttonSize + buttonMargin) +
                jiggleOffsetX,
            buttonMargin +
                position.y * (buttonSize + buttonMargin) +
                jiggleOffsetY,
          ),
        ),
      );
    }
    _currentStimulusIndex = 0;

    logger.log('started task');
  }

  @override
  double? getProgress() => null;

  @override
  Widget build(BuildContext context) {
    var buttons = <Widget>[];
    for (var i = 0; i < _stimuli.length; i++) {
      var stimulus = _stimuli[i];
      buttons.add(
        Positioned(
          left: stimulus.position.dx,
          top: stimulus.position.dy,
          child: ElevatedButton(
            child: Text(stimulus.text),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              backgroundColor: MaterialStateProperty.resolveWith(((states) =>
                  !states.contains(MaterialState.disabled)
                      ? Colors.green.shade800
                      : null)),
              fixedSize:
                  MaterialStateProperty.all(const Size(buttonSize, buttonSize)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              minimumSize: MaterialStateProperty.all(Size.zero),
              textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: buttonSize - 15)),
            ),
            onPressed: stimulus.tapped ? null : () => _onStimulusTapped(i),
          ),
          key: ValueKey(i),
        ),
      );
    }
    var _errorStimulus = this._errorStimulus;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: (buttonSize + buttonMargin) * _gridWidth + buttonMargin,
            height: (buttonSize + buttonMargin) * _gridHeight + buttonMargin,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (_currentStimulusIndex == 0)
                  Positioned(
                    left: _stimuli.first.position.dx - 8,
                    top: _stimuli.first.position.dy - 8,
                    child: Container(
                      width: buttonSize + 16,
                      height: buttonSize + 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(buttonSize),
                        border: Border.all(
                            color: Colors.green.shade500, width: 4.0),
                      ),
                    ),
                  ),
                ...buttons,
                if (_errorStimulus != null)
                  Positioned(
                    left: _errorStimulus.position.dx - 50.0 + buttonSize / 2,
                    top: _errorStimulus.position.dy - 50.0 + buttonSize / 2,
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: errorIconSize,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStimulusTapped(int stimulusIndex) async {
    var stimulus = _stimuli[stimulusIndex];
    if (stimulusIndex == _currentStimulusIndex) {
      logger.log('tapped correct stimulus', {'stimulus': stimulus.text});
      setState(() {
        stimulus.tapped = true;
      });
      _currentStimulusIndex++;
      if (_currentStimulusIndex >= _stimuli.length) {
        finish();
      }
    } else {
      logger.log('tapped incorrect stimulus', {'stimulus': stimulus.text});
      setState(() {
        _errorStimulus = stimulus;
      });
      logger.log('started feedback');
      await Future.delayed(const Duration(milliseconds: 500));
      logger.log('finished feedback');
      setState(() {
        _errorStimulus = null;
      });
    }
  }
}
