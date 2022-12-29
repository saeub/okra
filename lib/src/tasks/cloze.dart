import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../tasks/task.dart';
import '../util.dart';

class Cloze extends Task {
  static const double fontSize = 30.0;

  late List<Segment> _segments;
  late int _currentSegmentIndex;
  late bool _feedbacking;
  int? _chosenOptionIndex;
  late List<int?> _chosenOptionIndices;

  @override
  void init(Map<String, dynamic> data) {
    List<Map<String, dynamic>> segmentsData =
        data['segments'].cast<Map<String, dynamic>>();
    _segments = segmentsData.map(Segment.fromJson).toList();
    _currentSegmentIndex = 0;
    _feedbacking = false;
    _chosenOptionIndices = [];
    logger.log('started segment', {'segment': _currentSegmentIndex});
  }

  @override
  double? getProgress() => !_feedbacking
      ? _currentSegmentIndex / _segments.length
      : (_currentSegmentIndex + 1) / _segments.length;

  @override
  Widget build(BuildContext context) {
    var segment = _segments[_currentSegmentIndex];
    var _chosenOptionIndex = this._chosenOptionIndex;
    var feedback =
        _feedbacking ? _chosenOptionIndex == segment.correctOptionIndex : null;
    return Column(
      children: [
        Expanded(
          child: ReadingWidth(
            child: Center(
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
                style: const TextStyle(
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
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: Text(S.of(context).taskAdvance),
            onPressed: !_feedbacking
                ? () async {
                    logger.log('finished segment', {
                      'segment': _currentSegmentIndex,
                      'finalResponse': _chosenOptionIndex
                    });
                    if (segment.correctOptionIndex != null) {
                      logger.log('started feedback',
                          {'segment': _currentSegmentIndex});
                      setState(() {
                        _feedbacking = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 600));
                      logger.log('finished feedback',
                          {'segment': _currentSegmentIndex});
                      _feedbacking = false;
                    }
                    this._chosenOptionIndex = null;
                    if (_currentSegmentIndex < _segments.length - 1) {
                      setState(() {
                        _currentSegmentIndex++;
                      });
                      logger.log(
                          'started segment', {'segment': _currentSegmentIndex});
                    } else {
                      finish();
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
                            this._chosenOptionIndex = i;
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
  final String? text;
  final double fontSize;
  final VoidCallback? onTap;
  final bool? feedback;

  const ClozeBlank(this.text,
      {this.fontSize = Cloze.fontSize, this.onTap, this.feedback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var feedback = this.feedback;
    var text = this.text;
    return Card(
      color: feedback != null
          ? feedback
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: text != null
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: feedback != null
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 50.0),
                  child: Text(
                    '',
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
        ),
      ),
    );
  }
}

@immutable
class Segment {
  final String pre, post;
  final List<String> options;
  final int? correctOptionIndex;

  static final RegExp blankPattern = RegExp(r'\{\{(.+?)\}\}');

  const Segment(this.pre, this.post, this.options, [this.correctOptionIndex]);

  static Segment fromJson(Map<String, dynamic> json) {
    var text = json['text'];
    var blankPosition = json['blankPosition'];
    if (blankPosition == null) {
      return Segment(text, '', const []);
    }
    var pre = text.substring(0, blankPosition);
    var post = text.substring(blankPosition);
    return Segment(
      pre,
      post,
      json['options'].cast<String>(),
      json['correctOptionIndex'],
    );
  }
}
