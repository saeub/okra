import 'package:flutter/widgets.dart';

import '../data/models.dart';

typedef FinishCallback = void Function({
  Map<String, dynamic> data,
  String message,
});

abstract class Task {
  final TaskEventLogger logger;
  StateSetter setState;
  FinishCallback finish;

  Task(this.logger);

  Widget build(BuildContext context);
}

class TaskEventLogger {
  final List<TaskEvent> _events;
  final Stopwatch stopwatch;

  TaskEventLogger()
      : _events = [],
        stopwatch = Stopwatch();

  List<TaskEvent> get events => _events;

  void log(String label, [Map<String, dynamic> data]) {
    print('TaskEventLogger: $label $data');
    _events.add(TaskEvent(DateTime.now(), label, data));
  }
}
