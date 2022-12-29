import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';
import 'task.dart';

class ReactionTime extends Task {
  static const maxWidth = 600.0;
  static const maxHeight = 600.0;

  late Stimulus _stimulus;
  Offset? _stimulusPosition;
  late bool _stimulusTapped;
  late int _nStimuli, _nStimuliDone;
  late int _minMillisecondsBetweenStimuli, _maxMillisecondsBetweenStimuli;
  late bool _starting;
  late Random _random;

  @override
  void init(Map<String, dynamic> data) {
    _stimulusTapped = false;
    _nStimuli = data['nStimuli'];
    _nStimuliDone = 0;

    num minSecondsBetweenStimuli = data['minSecondsBetweenStimuli'];
    _minMillisecondsBetweenStimuli = (minSecondsBetweenStimuli * 1000).round();
    num maxSecondsBetweenStimuli = data['maxSecondsBetweenStimuli'];
    _maxMillisecondsBetweenStimuli = (maxSecondsBetweenStimuli * 1000).round();

    _starting = true;
    _random = Random(data['randomSeed']);

    logger.log('started stimulus', {'stimulus': null});
  }

  @override
  Future<void> loadAssets() async {
    var balloon = await loadImage('assets/images/balloon.png');
    var balloonPopped = await loadImage('assets/images/balloon_popped.png');
    var stimulusWidth = 100.0;
    var scale = stimulusWidth / balloon.width;
    _stimulus = Stimulus(
      balloon,
      balloonPopped,
      width: stimulusWidth,
      centerOffset: const Offset(50, 40),
      hitbox: Rect.fromLTWH(99 * scale, 34 * scale, 312 * scale, 393 * scale),
    );
  }

  @override
  double? getProgress() => _nStimuliDone / _nStimuli;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: LayoutBuilder(builder: (context, constraints) {
          if (_starting) {
            this._stimulusPosition =
                Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          }
          var _stimulusPosition = this._stimulusPosition;
          return GestureDetector(
            onTapDown: (details) async {
              logger.log('tapped screen', {
                'position': {
                  'x': details.localPosition.dx,
                  'y': details.localPosition.dy,
                },
                'stimulus': _starting ? null : _nStimuliDone,
              });
              var hitbox = getStimulusHitbox();
              if (hitbox != null && hitbox.contains(details.localPosition)) {
                logger.log('tapped stimulus',
                    {'stimulus': _starting ? null : _nStimuliDone});
                setState(() {
                  _stimulusTapped = true;
                  if (_starting) {
                    _starting = false;
                  } else {
                    _nStimuliDone++;
                  }
                });
                await Future.delayed(const Duration(milliseconds: 100));
                setState(() {
                  _stimulusTapped = false;
                  this._stimulusPosition = null;
                });
                if (_nStimuliDone < _nStimuli) {
                  await Future.delayed(generateRandomStimulusDelay());
                  setState(() {
                    randomizeStimulusPosition(constraints);
                  });
                  logger.log('started stimulus', {
                    'stimulus': _nStimuliDone,
                    'hitbox': {
                      'left': hitbox.left,
                      'top': hitbox.top,
                      'right': hitbox.right,
                      'bottom': hitbox.bottom,
                    }
                  });
                } else {
                  finish();
                }
              }
            },
            child: Stack(
              children: [
                if (_starting)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120.0),
                      child: Text(
                        S.of(context).taskReactionTimeIntro,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                if (_stimulusPosition != null)
                  CustomPaint(
                    painter: StimulusPainter(
                      _stimulus,
                      _stimulusPosition,
                      tapped: _stimulusTapped,
                    ),
                    size: constraints.biggest,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<ui.Image> loadImage(String key) async {
    var imageData = await rootBundle.load(key);
    var codec =
        await ui.instantiateImageCodec(Uint8List.view(imageData.buffer));
    return (await codec.getNextFrame()).image;
  }

  Rect? getStimulusHitbox() {
    var _stimulusPosition = this._stimulusPosition;
    if (_stimulusPosition != null) {
      return Rect.fromLTWH(
        _stimulusPosition.dx -
            _stimulus.centerOffset.dx +
            _stimulus.hitbox.left,
        _stimulusPosition.dy - _stimulus.centerOffset.dy + _stimulus.hitbox.top,
        _stimulus.hitbox.width,
        _stimulus.hitbox.height,
      );
    }
    return null;
  }

  void randomizeStimulusPosition(BoxConstraints constraints) {
    _stimulusPosition = Offset(
      _random.nextDouble() * (constraints.maxWidth - _stimulus.hitbox.width) +
          (_stimulus.centerOffset.dx - _stimulus.hitbox.left),
      _random.nextDouble() * (constraints.maxHeight - _stimulus.hitbox.height) +
          (_stimulus.centerOffset.dy - _stimulus.hitbox.top),
    );
  }

  Duration generateRandomStimulusDelay() {
    if (_minMillisecondsBetweenStimuli >= _maxMillisecondsBetweenStimuli) {
      return Duration(milliseconds: _minMillisecondsBetweenStimuli);
    }
    return Duration(
        milliseconds: _random.nextInt(_maxMillisecondsBetweenStimuli -
                _minMillisecondsBetweenStimuli) +
            _minMillisecondsBetweenStimuli);
  }
}

class Stimulus {
  final ui.Image image, tappedImage;
  late final double width, height;
  late final Offset centerOffset;
  late final Rect hitbox;

  Stimulus(this.image, this.tappedImage,
      {double? width, double? height, Offset? centerOffset, Rect? hitbox}) {
    this.width = width ??
        (height != null
            ? image.width * height / image.height
            : image.width.toDouble());
    this.height = height ?? image.height * this.width / image.width;
    this.centerOffset = centerOffset ?? Offset(this.width / 2, this.height / 2);
    this.hitbox = hitbox ?? Rect.fromLTWH(0, 0, this.width, this.height);
  }
}

class StimulusPainter extends CustomPainter {
  final Stimulus stimulus;
  final Offset position;
  final bool tapped;

  const StimulusPainter(this.stimulus, this.position, {this.tapped = false});

  @override
  void paint(Canvas canvas, Size size) {
    var topLeft = position - stimulus.centerOffset;
    canvas.drawImageRect(
      tapped ? stimulus.tappedImage : stimulus.image,
      Rect.fromLTWH(
        0,
        0,
        stimulus.image.width.toDouble(),
        stimulus.image.height.toDouble(),
      ),
      Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        stimulus.width,
        stimulus.height,
      ),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(StimulusPainter oldDelegate) {
    return stimulus != oldDelegate.stimulus ||
        position != oldDelegate.position ||
        tapped != oldDelegate.tapped;
  }
}
