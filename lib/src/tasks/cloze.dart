import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../tasks/task.dart';
import '../util.dart';

class Cloze extends Task {
  static const double fontSize = 30.0;

  List<Segment> _segments;
  int _currentSegmentIndex;
  bool _feedbacking;
  int _chosenOptionIndex;
  List<int> _chosenOptionIndices;

  @override
  void init(Map<String, dynamic> data) {
    List<String> segmentsData = data['segments'].cast<String>();
    _segments = segmentsData.map(Segment.fromString).toList();
    _currentSegmentIndex = 0;
    _feedbacking = false;
    _chosenOptionIndices = [];
    logger.log('started segment', {'segment': _currentSegmentIndex});
  }

  @override
  double getProgress() => !_feedbacking
      ? _currentSegmentIndex / _segments.length
      : (_currentSegmentIndex + 1) / _segments.length;

  @override
  Widget build(BuildContext context) {
    var segment = _segments[_currentSegmentIndex];
    var feedback =
        _feedbacking ? _chosenOptionIndex == segment.correctOptionIndex : null;
    return Column(
      children: [
        Expanded(
          child: ReadingWidth(
            Center(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: segment.pre),
                  if (segment.options.isNotEmpty)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ClozeBlank(
                        _chosenOptionIndex != null
                            ? segment.options[_chosenOptionIndex]
                            : null,
                        feedback:
                            _chosenOptionIndex == segment.correctOptionIndex
                                ? feedback
                                : null,
                      ),
                    ),
                  TextSpan(text: segment.post),
                ]),
                style: TextStyle(
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Visibility(
          visible: _chosenOptionIndex != null || segment.options.isEmpty,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: AccentButton(
            Icons.arrow_forward,
            S.of(context).taskAdvance,
            onPressed: !_feedbacking
                ? () async {
                    logger.log(
                        'finished segment', {'segment': _currentSegmentIndex});
                    _chosenOptionIndices.add(_chosenOptionIndex);
                    if (segment.correctOptionIndex != null) {
                      logger.log('started feedback',
                          {'segment': _currentSegmentIndex});
                      setState(() {
                        _feedbacking = true;
                      });
                      await Future.delayed(Duration(milliseconds: 600));
                      logger.log('finished feedback',
                          {'segment': _currentSegmentIndex});
                      _feedbacking = false;
                    }
                    _chosenOptionIndex = null;
                    if (_currentSegmentIndex < _segments.length - 1) {
                      setState(() {
                        _currentSegmentIndex++;
                      });
                      logger.log(
                          'started segment', {'segment': _currentSegmentIndex});
                    } else {
                      finish(
                          data: {'chosenOptionIndices': _chosenOptionIndices});
                    }
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < segment.options.length; i++)
                      ClozeBlank(
                        segment.options[i],
                        onTap: () {
                          logger.log('chose option',
                              {'segment': _currentSegmentIndex, 'option': i});
                          setState(() {
                            _chosenOptionIndex = i;
                          });
                        },
                        feedback: i != _chosenOptionIndex &&
                                i == segment.correctOptionIndex
                            ? feedback
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ClozeBlank extends StatelessWidget {
  final String text;
  final double fontSize;
  final VoidCallback onTap;
  final bool feedback;

  const ClozeBlank(this.text,
      {this.fontSize = Cloze.fontSize, this.onTap, this.feedback, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: feedback != null
          ? feedback
              ? Colors.green
              : Colors.red
          : null,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: text != null
              ? Text(
                  text,
                  style: TextStyle(fontSize: fontSize),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 50.0),
                  child: Text(
                    '',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
        ),
        onTap: onTap,
      ),
    );
  }
}

@immutable
class Segment {
  final String pre, post;
  final List<String> options;
  final int correctOptionIndex;

  static final RegExp blankPattern = RegExp(r'\{\{(.+?)\}\}');

  Segment(this.pre, this.post, this.options, [this.correctOptionIndex]);

  static Segment fromString(String segment) {
    // TODO: More strictly structured format (e.g. blank position + options)
    var match = blankPattern.firstMatch(segment);
    if (match == null) {
      return Segment(segment, null, []);
    }
    var pre = segment.substring(0, match.start);
    var post = segment.substring(match.end);
    var options = match.group(1).split('|');
    int correctOptionIndex;
    for (var i = 0; i < options.length; i++) {
      if (options[i].startsWith('_')) {
        correctOptionIndex = i;
        options[i] = options[i].substring(1);
        break;
      }
    }
    return Segment(
      pre,
      post,
      options,
      correctOptionIndex,
    );
  }
}
