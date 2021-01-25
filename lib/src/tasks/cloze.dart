import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../tasks/task.dart';
import '../util.dart';

class Cloze extends Task {
  static const double fontSize = 30.0;

  List<Segment> _segments;
  int _currentSegmentIndex;
  int _chosenIndex;
  List<int> _chosenIndices;

  @override
  void init(Map<String, dynamic> data) {
    List<String> segmentsData = data['segments'].cast<String>();
    _segments = segmentsData.map(Segment.fromString).toList();
    _currentSegmentIndex = 0;
    _chosenIndices = [];
    logger.log('started segment', {'segment': _currentSegmentIndex});
  }

  @override
  Widget build(BuildContext context) {
    var segment = _segments[_currentSegmentIndex];
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: segment.pre),
                if (segment.options.isNotEmpty)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: ClozeGap(_chosenIndex != null
                        ? segment.options[_chosenIndex]
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
        Visibility(
          visible: _chosenIndex != null || segment.options.isEmpty,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: AccentButton(
            Icons.arrow_forward,
            S.of(context).taskAdvance,
            onPressed: () {
              logger.log('finished segment', {'segment': _currentSegmentIndex});
              _chosenIndices.add(_chosenIndex);
              _chosenIndex = null;
              if (_currentSegmentIndex < _segments.length - 1) {
                setState(() {
                  _currentSegmentIndex++;
                });
                logger
                    .log('started segment', {'segment': _currentSegmentIndex});
              } else {
                finish(data: {'chosenIndices': _chosenIndices});
              }
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < segment.options.length; i++)
                    ClozeGap(
                      segment.options[i],
                      onTap: () {
                        logger.log('chose option',
                            {'segment': _currentSegmentIndex, 'option': i});
                        setState(() {
                          _chosenIndex = i;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        AnimatedLinearProgressIndicator(
            _currentSegmentIndex / _segments.length),
      ],
    );
  }
}

class ClozeGap extends StatelessWidget {
  final String text;
  final double fontSize;
  final VoidCallback onTap;

  const ClozeGap(this.text,
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

  static final RegExp gapPattern = RegExp(r'\{\{(.+?)\}\}');

  Segment(this.pre, this.post, this.options);

  static Segment fromString(String segment) {
    var match = gapPattern.firstMatch(segment);
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
