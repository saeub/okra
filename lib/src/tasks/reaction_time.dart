import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';
import '../../main.dart';
import 'task.dart';

class ReactionTime extends Task {
  static const maxWidth = 600.0;
  static const maxHeight = 600.0;

  Stimulus _stimulus;
  Offset _stimulusPosition;
  bool _stimulusTapped;
  int _nStimuli, _nStimuliDone;
  int _minMillisecondsBetweenStimuli, _maxMillisecondsBetweenStimuli;
  bool _starting;
  Random _random;
  DateTime _stimulusStart;
  List<Duration> _reactionTimes;

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
    _random = Random();
    _reactionTimes = [];

    logger.log('started stimulus', {'stimulus': null});
  }

  @override
  Future<void> loadAssets() async {
    if (testMode) {
      _stimulus = Stimulus(null, null, width: 100, height: 100);
    } else {
      var balloon = await loadImage('assets/images/balloon.png');
      var balloonPopped = await loadImage('assets/images/balloon_popped.png');
      var stimulusWidth = 100.0;
      var scale = stimulusWidth / balloon.width;
      _stimulus = Stimulus(
        balloon,
        balloonPopped,
        width: stimulusWidth,
        centerOffset: Offset(50, 40),
        hitbox: Rect.fromLTWH(99 * scale, 34 * scale, 312 * scale, 393 * scale),
      );
    }
  }

  @override
  double getProgress() => _nStimuliDone / _nStimuli;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: LayoutBuilder(builder: (context, constraints) {
          if (_starting) {
            _stimulusPosition =
                Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          }
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
              if (hitbox.contains(details.localPosition)) {
                if (_stimulusStart != null) {
                  _reactionTimes.add(DateTime.now().difference(_stimulusStart));
                  _stimulusStart = null;
                }
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
                await Future.delayed(Duration(milliseconds: 100));
                setState(() {
                  _stimulusTapped = false;
                  _stimulusPosition = null;
                });
                if (_nStimuliDone < _nStimuli) {
                  await Future.delayed(generateRandomStimulusDelay());
                  setState(() {
                    randomizeStimulusPosition(constraints);
                  });
                  _stimulusStart = DateTime.now();
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
                  finish(data: {
                    'reactionTimes': _reactionTimes
                        .map((duration) => duration.inMilliseconds / 1000)
                        .toList(),
                  });
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
                        style: TextStyle(
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

  Rect getStimulusHitbox() {
    return Rect.fromLTWH(
      _stimulusPosition.dx - _stimulus.centerOffset.dx + _stimulus.hitbox.left,
      _stimulusPosition.dy - _stimulus.centerOffset.dy + _stimulus.hitbox.top,
      _stimulus.hitbox.width,
      _stimulus.hitbox.height,
    );
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
  double width, height;
  Offset centerOffset;
  Rect hitbox;

  Stimulus(this.image, this.tappedImage,
      {this.width, this.height, this.centerOffset, this.hitbox}) {
    if (width == null) {
      if (height != null) {
        width = image.width * height / image.height;
      } else {
        width = image.width.toDouble();
      }
    }
    if (height == null) {
      if (width != null) {
        height = image.height * width / image.width;
      } else {
        height = image.height.toDouble();
      }
    }
    centerOffset ??= Offset(width / 2, height / 2);
    hitbox ??= Rect.fromLTWH(0, 0, width, height);
  }
}

class StimulusPainter extends CustomPainter {
  final Stimulus stimulus;
  final Offset position;
  final bool tapped;

  const StimulusPainter(this.stimulus, this.position, {this.tapped = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (stimulus.image != null) {
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
  }

  @override
  bool shouldRepaint(StimulusPainter oldPainter) {
    return stimulus != oldPainter.stimulus ||
        position != oldPainter.position ||
        tapped != oldPainter.tapped;
  }
}
