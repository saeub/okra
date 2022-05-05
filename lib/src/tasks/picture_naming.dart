import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../util.dart';
import 'task.dart';

class PictureNaming extends Task {
  static const double chosenCardMargin = 16.0;

  late List<Subtask> _subtasks;
  late int _currentSubtaskIndex;
  late bool _showQuestionMark;
  late bool _feedbacking;
  int? _chosenPictureIndex;
  late List<int> _chosenPictureIndices;

  @override
  void init(Map<String, dynamic> data) {
    List<Map<String, dynamic>> subtaskData =
        data['subtasks'].cast<Map<String, dynamic>>();
    _subtasks = subtaskData.map(Subtask.fromJson).toList();
    _currentSubtaskIndex = 0;
    _showQuestionMark = data['showQuestionMark'];
    _feedbacking = false;
    _chosenPictureIndices = [];
    logger.log('started subtask', {'subtask': _currentSubtaskIndex});
  }

  @override
  double? getProgress() => !_feedbacking
      ? _currentSubtaskIndex / _subtasks.length
      : (_currentSubtaskIndex + 1) / _subtasks.length;

  @override
  Widget build(BuildContext context) {
    var subtask = _subtasks[_currentSubtaskIndex];
    var nCards = subtask.pictures.length;
    if (_showQuestionMark) nCards++;
    var _chosenPictureIndex = this._chosenPictureIndex;
    var feedback = _feedbacking
        ? _chosenPictureIndex == subtask.correctPictureIndex
        : null;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            subtask.text,
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Flexible(
          child: ReadingWidth(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var gridView = GridView.count(
                    crossAxisCount: sqrt(nCards).ceil(),
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < subtask.pictures.length; i++)
                        PictureCard(
                          subtask.pictures[i],
                          i,
                          _chosenPictureIndex,
                          (_) {
                            _onTap(i);
                          },
                          feedback: subtask.correctPictureIndex == i
                              ? feedback
                              : null,
                        ),
                      if (_showQuestionMark)
                        PictureCard(
                          null,
                          -1,
                          _chosenPictureIndex,
                          (_) {
                            _onTap(-1);
                          },
                          feedback: subtask.correctPictureIndex == -1
                              ? feedback
                              : null,
                        ),
                    ],
                  );
                  if (constraints.maxHeight < constraints.maxWidth) {
                    return SizedBox(
                      width: constraints.maxHeight,
                      child: gridView,
                    );
                  }
                  return gridView;
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Visibility(
            visible: _chosenPictureIndex != null,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: ElevatedButton.icon(
              icon: Icon(Icons.arrow_forward),
              label: Text(S.of(context).taskAdvance),
              onPressed: !_feedbacking
                  ? () async {
                      logger.log('finished subtask',
                          {'subtask': _currentSubtaskIndex});
                      _chosenPictureIndices.add(_chosenPictureIndex!);
                      if (subtask.correctPictureIndex != null) {
                        logger.log('started feedback',
                            {'subtask': _currentSubtaskIndex});
                        setState(() {
                          _feedbacking = true;
                        });
                        await Future.delayed(Duration(milliseconds: 600));
                        logger.log('finished feedback',
                            {'subtask': _currentSubtaskIndex});
                        _feedbacking = false;
                      }
                      _chosenPictureIndex = null;
                      if (_currentSubtaskIndex < _subtasks.length - 1) {
                        setState(() {
                          _currentSubtaskIndex++;
                        });
                        logger.log('started subtask',
                            {'subtask': _currentSubtaskIndex});
                      } else {
                        finish(data: {
                          'chosenPictureIndices': _chosenPictureIndices
                        });
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _onTap(int pictureIndex) {
    logger.log('chose picture',
        {'subtask': _currentSubtaskIndex, 'picture': pictureIndex});
    setState(() {
      _chosenPictureIndex = pictureIndex;
    });
  }
}

class PictureCard<T> extends StatelessWidget {
  static const double chosenMargin = 16.0;

  final Image? picture;
  final T value;
  final T chosenValue;
  final void Function(T value) onTap;
  final bool? feedback;

  const PictureCard(this.picture, this.value, this.chosenValue, this.onTap,
      {this.feedback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var feedback = this.feedback;
    var card = Card(
      margin: chosenValue == value || feedback != null
          ? EdgeInsets.all(chosenMargin)
          : null,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (picture != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: picture,
              ),
            )
          else
            Center(
              child: Text(
                '?',
                style: TextStyle(
                  fontSize: chosenValue == value ? 70.0 - chosenMargin : 70.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,
                onTap: () {
                  onTap(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
    if (feedback == null) {
      return card;
    }
    return ColoredBox(
      color: feedback ? Colors.green : Colors.red,
      child: card,
    );
  }
}

@immutable
class Subtask {
  final String text;
  final List<Image> pictures;
  final int? correctPictureIndex;

  Subtask(this.text, this.pictures, [this.correctPictureIndex]);

  static Subtask fromJson(Map<String, dynamic> json) {
    List<String> pictures = json['pictures'].cast<String>();
    return Subtask(
      json['text'],
      pictures.map(_imageFromBase64).toList(),
      json['correctPictureIndex'],
    );
  }

  static Image _imageFromBase64(String data) {
    var bytes = base64Decode(data);
    return Image.memory(bytes);
  }
}
