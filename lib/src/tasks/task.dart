import 'package:flutter/widgets.dart';

import '../data/models.dart';

typedef FinishCallback = void Function({
  Map<String, dynamic>? data,
  String? message,
});

abstract class Task {
  late TaskEventLogger logger;
  late StateSetter _setState;
  late FinishCallback _finish;

  void init(Map<String, dynamic> data);

  Future<void> loadAssets() async {}

  double? getProgress();

  Widget build(BuildContext context);

  /// Inject dependencies after constructor call and before `init`.
  /// This allows `setState` and `finish` to be used in `init` while avoiding
  /// boilerplate in the task implementation. It's a bit of a hack and should
  /// only be called immediately after the task is constructed.
  void injectDependencies(
      TaskEventLogger logger, StateSetter setState, FinishCallback finish) {
    this.logger = logger;
    _setState = setState;
    _finish = finish;
  }

  void setState(VoidCallback fn) => _setState(fn);

  void finish({Map<String, dynamic>? data, String? message}) =>
      _finish(data: data, message: message);
}

class TaskEventLogger {
  final List<TaskEvent> _events;
  final Stopwatch stopwatch;

  TaskEventLogger()
      : _events = [],
        stopwatch = Stopwatch();

  List<TaskEvent> get events => _events;

  void log(String label, [Map<String, dynamic>? data]) {
    debugPrint('TaskEventLogger: $label $data');
    _events.add(TaskEvent(DateTime.now(), label, data));
  }
}
