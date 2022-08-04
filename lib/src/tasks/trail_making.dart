import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../colors.dart';
import 'task.dart';

class Stimulus {
  final String text;
  final Color color;
  final Color textColor;
  final bool outline;
  final Offset position;
  bool tapped;

  Stimulus(this.text, this.color, this.position)
      : tapped = false,
        textColor =
            color.computeLuminance() < 0.5 ? Colors.white : Colors.black,
        outline = color.computeLuminance() > 0.8;
}

class TrailMaking extends Task {
  static const buttonSize = 45.0;
  static const buttonMargin = 20.0;
  static const errorIconSize = 100.0;

  late int _gridWidth;
  late int _gridHeight;
  late List<Stimulus> _stimuli;
  late List<Stimulus> _distractors;
  late int _currentStimulusIndex;
  Stimulus? _errorStimulus;

  @override
  void init(Map<String, dynamic> data) {
    List<String> stimulusTexts = data['stimuli'].cast<String>();

    bool jiggle = data['jiggle'] ?? false;
    int nDistractors = data['nDistractors'] ?? 0;

    _gridWidth = data['gridWidth'] ??
        sqrt((stimulusTexts.length + nDistractors) * 2).ceil();
    _gridHeight = data['gridHeight'] ??
        sqrt((stimulusTexts.length + nDistractors) * 2).ceil();
    var freeGridPositions = [
      for (var i = 0; i < _gridWidth; i++)
        for (var j = 0; j < _gridHeight; j++) Point(i, j)
    ];
    if (stimulusTexts.length + nDistractors > freeGridPositions.length) {
      throw ArgumentError(
          'Number of stimuli and distractors must not exceed grid size (${freeGridPositions.length})');
    }

    List<String>? colorCodes = data['colors']?.cast<String>();
    var colors = <Color>[];
    if (colorCodes != null) {
      for (var colorCode in colorCodes) {
        var colorInt = 0xFF000000 + int.parse(colorCode, radix: 16);
        colors.add(Color(colorInt));
      }
    } else {
      colors.add(AppColors.primary.shade800);
    }
    if (nDistractors > 0 && colors.length < 2) {
      throw ArgumentError(
          'Distractors can only be used if there are at least 2 stimulus colors');
    }

    var random = Random(data['randomSeed']);
    Offset generatePosition() {
      // Pop random free position
      var gridPosition =
          freeGridPositions.removeAt(random.nextInt(freeGridPositions.length));
      var jiggleOffsetX = 0.0;
      var jiggleOffsetY = 0.0;
      if (jiggle) {
        jiggleOffsetX = random.nextDouble() * buttonMargin - buttonMargin / 2;
        jiggleOffsetY = random.nextDouble() * buttonMargin - buttonMargin / 2;
      }
      return Offset(
        buttonMargin +
            gridPosition.x * (buttonSize + buttonMargin) +
            jiggleOffsetX,
        buttonMargin +
            gridPosition.y * (buttonSize + buttonMargin) +
            jiggleOffsetY,
      );
    }

    // Generate stimuli
    _stimuli = [];
    for (var i = 0; i < stimulusTexts.length; i++) {
      var text = stimulusTexts[i];
      var color = colors[i % colors.length];
      var position = generatePosition();
      _stimuli.add(
        Stimulus(
          text,
          color,
          position,
        ),
      );
    }

    // Generate distractors
    _distractors = [];
    var shuffledStimulusIndices = [for (var i = 0; i < _stimuli.length; i++) i]
      ..shuffle(random);
    for (var i = 0; i < nDistractors; i++) {
      var stimulusIndex = shuffledStimulusIndices[i % _stimuli.length];
      var text = stimulusTexts[stimulusIndex];
      var colorIndex = (stimulusIndex + random.nextInt(colors.length - 1) + 1) %
          colors.length;
      var color = colors[colorIndex];
      var position = generatePosition();
      _distractors.add(
        Stimulus(
          text,
          color,
          position,
        ),
      );
    }

    _currentStimulusIndex = 0;
    logger.log('started task');
  }

  @override
  Widget build(BuildContext context) {
    var buttonsForeground = <Widget>[];
    var buttonsBackground = <Widget>[];
    for (var i = 0; i < _stimuli.length; i++) {
      var stimulus = _stimuli[i];
      var widget = Positioned(
        left: stimulus.position.dx,
        top: stimulus.position.dy,
        child: StimulusButton(stimulus, onTapped: () => _onStimulusTapped(i)),
        key: ValueKey(stimulus),
      );
      if (stimulus.tapped) {
        buttonsBackground.add(widget);
      } else {
        buttonsForeground.add(widget);
      }
    }
    for (var i = 0; i < _distractors.length; i++) {
      var distractor = _distractors[i];
      buttonsForeground.add(
        Positioned(
          left: distractor.position.dx,
          top: distractor.position.dy,
          child: StimulusButton(distractor,
              onTapped: () => _onDistractorTapped(i)),
          key: ValueKey(distractor),
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
                // Start indicator
                if (_currentStimulusIndex == 0)
                  Positioned(
                    left: _stimuli.first.position.dx - 8,
                    top: _stimuli.first.position.dy - 8,
                    child: SizedBox(
                      width: buttonSize + 16,
                      child: Column(
                        children: [
                          Container(
                            width: buttonSize + 16,
                            height: buttonSize + 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(buttonSize),
                              border: Border.all(
                                  color: AppColors.primary.shade500,
                                  width: 4.0),
                            ),
                          ),
                          Text(
                            S.of(context).taskTrailMakingStart,
                            style: TextStyle(
                              color: AppColors.primary.shade500,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Buttons already tapped
                ...buttonsBackground,
                // Trail
                CustomPaint(
                  painter: TrailPainter([
                    for (var i = 0; i < _currentStimulusIndex; i++)
                      _stimuli[i].position +
                          const Offset(buttonSize / 2, buttonSize / 2)
                  ]),
                ),
                // Buttons not yet tapped
                ...buttonsForeground,
                // Error indicator
                if (_errorStimulus != null)
                  Positioned(
                    left: _errorStimulus.position.dx - 50.0 + buttonSize / 2,
                    top: _errorStimulus.position.dy - 50.0 + buttonSize / 2,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.negative,
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
      // Don't finish feedback if another incorrect stimulus has been tapped in the meantime
      if (_errorStimulus == stimulus) {
        logger.log('finished feedback');
        setState(() {
          _errorStimulus = null;
        });
      }
    }
  }

  void _onDistractorTapped(int distractorIndex) async {
    var distractor = _distractors[distractorIndex];
    logger.log('tapped distractor', {'stimulus': distractor.text});
    setState(() {
      _errorStimulus = distractor;
    });
    logger.log('started feedback');
    await Future.delayed(const Duration(milliseconds: 500));
    // Don't finish feedback if another incorrect stimulus has been tapped in the meantime
    if (_errorStimulus == distractor) {
      setState(() {
        logger.log('finished feedback');
        _errorStimulus = null;
      });
    }
  }
}

class StimulusButton extends StatelessWidget {
  final Stimulus stimulus;
  final Function() onTapped;

  const StimulusButton(this.stimulus, {required this.onTapped, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(stimulus.text),
      style: ButtonStyle(
        shape: MaterialStateProperty.resolveWith(((states) =>
            !states.contains(MaterialState.disabled)
                ? CircleBorder(
                    side: stimulus.outline
                        ? const BorderSide(width: 2.0)
                        : BorderSide.none)
                : const CircleBorder())),
        backgroundColor: MaterialStateProperty.resolveWith(((states) =>
            !states.contains(MaterialState.disabled) ? stimulus.color : null)),
        foregroundColor: MaterialStateProperty.resolveWith(((states) =>
            !states.contains(MaterialState.disabled)
                ? stimulus.textColor
                : null)),
        fixedSize: MaterialStateProperty.all(
            const Size(TrailMaking.buttonSize, TrailMaking.buttonSize)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        minimumSize: MaterialStateProperty.all(Size.zero),
        textStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: TrailMaking.buttonSize - 15)),
      ),
      onPressed: onTapped,
    );
  }
}

class TrailPainter extends CustomPainter {
  final List<Offset> points;
  final Paint _paint;

  TrailPainter(this.points)
      : _paint = Paint()
          ..color = AppColors.primary
          ..strokeWidth = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5.0, _paint);
      if (i > 0) {
        canvas.drawLine(points[i - 1], points[i], _paint);
      }
    }
  }

  @override
  bool shouldRepaint(TrailPainter oldDelegate) {
    return !listEquals(points, oldDelegate.points);
  }
}
