import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../tasks/task.dart';
import '../util.dart';

class Cloze extends Task {
  static const double fontSize = 30.0;

  List<Segment> _segments;
  int _currentSegmentIndex;
  int _chosenOptionIndex;
  List<int> _chosenOptionIndices;

  @override
  void init(Map<String, dynamic> data) {
    List<String> segmentsData = data['segments'].cast<String>();
    _segments = segmentsData.map(Segment.fromString).toList();
    _currentSegmentIndex = 0;
    _chosenOptionIndices = [];
    logger.log('started segment', {'segment': _currentSegmentIndex});
  }

  @override
  double getProgress() => _currentSegmentIndex / _segments.length;

  @override
  Widget build(BuildContext context) {
    var segment = _segments[_currentSegmentIndex];
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
                      child: ClozeBlank(_chosenOptionIndex != null
                          ? segment.options[_chosenOptionIndex]
                          : null),
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
            onPressed: () {
              logger.log('finished segment', {'segment': _currentSegmentIndex});
              _chosenOptionIndices.add(_chosenOptionIndex);
              _chosenOptionIndex = null;
              if (_currentSegmentIndex < _segments.length - 1) {
                setState(() {
                  _currentSegmentIndex++;
                });
                logger
                    .log('started segment', {'segment': _currentSegmentIndex});
              } else {
                finish(data: {'chosenOptionIndices': _chosenOptionIndices});
              }
            },
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

  const ClozeBlank(this.text,
      {this.fontSize = Cloze.fontSize, this.onTap, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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

  static final RegExp blankPattern = RegExp(r'\{\{(.+?)\}\}');

  Segment(this.pre, this.post, this.options);

  static Segment fromString(String segment) {
    var match = blankPattern.firstMatch(segment);
    if (match == null) {
      return Segment(segment, null, []);
    }
    var pre = segment.substring(0, match.start);
    var post = segment.substring(match.end);
    var options = match.group(1).split('|');
    return Segment(
      pre,
      post,
      options,
    );
  }
}
