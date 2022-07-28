import 'package:flutter/material.dart';

import '../data/models.dart';

typedef FinishCallback = void Function({
  Map<String, dynamic>? data,
  String? message,
});

abstract class Task {
  final Color? backgroundColor = null;

  late TaskEventLogger logger;
  late StateSetter _setState;
  late FinishCallback _finish;

  void init(Map<String, dynamic> data);

  Future<void> loadAssets() async {}

  double? getProgress() => null;

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

abstract class MultistageTask extends Task {
  TaskStage? _currentStage;
  TaskStage? get currentStage => _currentStage;

  @override
  @mustCallSuper
  void init(Map<String, dynamic> data) {
    _startNextStage();
  }

  void _startNextStage() {
    if (_currentStage != null) {
      logger.log(
          'finished stage', {'type': _currentStage.runtimeType.toString()});
    }
    var nextStage = getNextStage(_currentStage);
    if (nextStage != null) {
      nextStage.injectDependencies(this, _setState, _startNextStage);
      setState(() {
        _currentStage = nextStage;
      });
      logger
          .log('started stage', {'type': _currentStage.runtimeType.toString()});
    }
  }

  TaskStage? getNextStage(TaskStage? previousStage);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(_currentStage),
      child: _currentStage!.build(context),
    );
  }

  @override
  double? getProgress() {
    return _currentStage!.getProgress();
  }
}

abstract class TaskStage {
  late TaskEventLogger logger;
  late MultistageTask _task;
  late StateSetter _setState;
  late void Function() _finish;

  void injectDependencies(
      MultistageTask task, StateSetter setState, void Function() finish) {
    _task = task;
    logger = _task.logger;
    _setState = setState;
    _finish = finish;
  }

  double? getProgress() => null;

  Widget build(BuildContext context);

  void setState(VoidCallback fn) => _setState(fn);

  void finish() => _finish();
}
