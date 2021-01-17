import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../util.dart';
import 'task.dart';

class PictureNaming extends Task {
  static const double chosenCardMargin = 16.0;

  List<Subtask> _subtasks;
  int _currentSubtaskIndex;
  bool _showQuestionMark;
  int _chosenIndex;
  List<int> _chosenIndices;

  PictureNaming(Map<String, dynamic> data, TaskEventLogger logger)
      : super(logger) {
    List<Map<String, dynamic>> subtaskData =
        data['subtasks'].cast<Map<String, dynamic>>();
    _subtasks = subtaskData.map(Subtask.fromJson).toList();
    _currentSubtaskIndex = 0;
    _showQuestionMark = data['showQuestionMark'];
    _chosenIndices = [];
    logger.log('started subtask', {'subtask': _currentSubtaskIndex});
  }

  @override
  Widget build(BuildContext context) {
    var subtask = _subtasks[_currentSubtaskIndex];
    var nCards = subtask.pictures.length;
    if (_showQuestionMark) nCards++;
    return Column(
      children: [
        Spacer(),
        Text(
          subtask.text,
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
        Spacer(),
        // TODO: guarantee no overflow
        GridView.count(
          crossAxisCount: sqrt(nCards).ceil(),
          shrinkWrap: true,
          children: [
            for (var i = 0; i < subtask.pictures.length; i++)
              Card(
                margin:
                    _chosenIndex == i ? EdgeInsets.all(chosenCardMargin) : null,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: FittedBox(
                        child: subtask.pictures[i],
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          onTap: () {
                            _onTap(i);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_showQuestionMark)
              Card(
                margin: _chosenIndex == -1
                    ? EdgeInsets.all(chosenCardMargin)
                    : null,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () {
                    _onTap(-1);
                  },
                  child: Center(
                    child: Text(
                      '?',
                      style: TextStyle(
                        fontSize:
                            _chosenIndex == -1 ? 70.0 - chosenCardMargin : 70.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Spacer(),
        Visibility(
          visible: _chosenIndex != null,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: AccentButton(
            Icons.arrow_forward,
            S.of(context).taskAdvance,
            onPressed: () {
              logger.log('finished subtask', {'subtask': _currentSubtaskIndex});
              _chosenIndices.add(_chosenIndex);
              _chosenIndex = null;
              if (_currentSubtaskIndex < _subtasks.length - 1) {
                setState(() {
                  _currentSubtaskIndex++;
                });
                logger
                    .log('started subtask', {'subtask': _currentSubtaskIndex});
              } else {
                finish(data: {'chosenIndices': _chosenIndices});
              }
            },
          ),
        ),
        AnimatedLinearProgressIndicator(
            _currentSubtaskIndex / _subtasks.length),
      ],
    );
  }

  void _onTap(int pictureIndex) {
    logger.log('chose picture',
        {'subtask': _currentSubtaskIndex, 'picture': pictureIndex});
    setState(() {
      _chosenIndex = pictureIndex;
    });
  }
}

@immutable
class Subtask {
  final String text;
  final List<Image> pictures;

  Subtask(this.text, this.pictures);

  static Subtask fromJson(Map<String, dynamic> json) {
    List<String> pictures = json['pictures'].cast<String>();
    return Subtask(
      json['text'],
      pictures.map(_imageFromBase64).toList(),
    );
  }

  static Image _imageFromBase64(String data) {
    var bytes = base64Decode(data);
    return Image.memory(bytes);
  }
}
