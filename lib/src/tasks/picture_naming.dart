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

  @override
  void init(Map<String, dynamic> data) {
    List<Map<String, dynamic>> subtaskData =
        data['subtasks'].cast<Map<String, dynamic>>();
    _subtasks = subtaskData.map(Subtask.fromJson).toList();
    _currentSubtaskIndex = 0;
    _showQuestionMark = data['showQuestionMark'];
    _chosenIndices = [];
    logger.log('started subtask', {'subtask': _currentSubtaskIndex});
  }

  @override
  double getProgress() => _currentSubtaskIndex / _subtasks.length;

  @override
  Widget build(BuildContext context) {
    var subtask = _subtasks[_currentSubtaskIndex];
    var nCards = subtask.pictures.length;
    if (_showQuestionMark) nCards++;
    return Column(
      children: [
        Spacer(flex: 2),
        Text(
          subtask.text,
          style: TextStyle(
            fontSize: 30.0,
          ),
        ),
        Spacer(flex: 1),
        // TODO: guarantee no overflow
        ReadingWidth(
          GridView.count(
            crossAxisCount: sqrt(nCards).ceil(),
            shrinkWrap: true,
            children: [
              for (var i = 0; i < subtask.pictures.length; i++)
                Card(
                  margin: _chosenIndex == i
                      ? EdgeInsets.all(chosenCardMargin)
                      : null,
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
                          fontSize: _chosenIndex == -1
                              ? 70.0 - chosenCardMargin
                              : 70.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Spacer(flex: 1),
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
        Spacer(flex: 1),
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
