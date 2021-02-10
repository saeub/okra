import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okra/generated/l10n.dart';
import 'package:okra/src/data/api.dart';
import 'package:okra/src/data/models.dart';
import 'package:okra/src/pages/task.dart';
import 'package:okra/src/tasks/types.dart';

Widget getApp(Widget widget) {
  return MaterialApp(
    home: Scaffold(
      body: widget,
    ),
    localizationsDelegates: [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class TestApi extends Api {
  TaskResults taskResults;

  @override
  String getName() {
    return 'Test API';
  }

  @override
  Image getIcon() {
    return null;
  }

  @override
  Future<List<Experiment>> getExperiments() async {
    return [await getExperiment('test')];
  }

  @override
  Future<Experiment> getExperiment(String experimentId) async {
    return Experiment(
      this,
      'test',
      type: TaskType.cloze,
      title: 'Test experiment',
      instructions: 'Test instructions',
      nTasks: 1,
      nTasksDone: 0,
      ratings: [
        TaskRating('Question?', TaskRatingType.slider),
      ],
    );
  }

  @override
  Future<TaskData> startTask(String experimentId) async {
    return TaskData('test', {
      'segments': [
        'This is a {{test|example}}.',
      ],
    });
  }

  @override
  Future<void> finishTask(String taskId, TaskResults results) async {
    taskResults = results;
  }
}

var testApi = TestApi();

void main() {
  group('TaskPage', () {
    testWidgets('collects task results', (WidgetTester tester) async {
      await tester
          .pumpWidget(getApp(TaskPage(await testApi.getExperiment('test'))));
      await tester.pumpAndSettle();
      // Instructions
      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();
      // Task
      await tester.tap(find.text('example'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // Ratings
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // Results
      expect(testApi.taskResults.data, {
        'chosenOptionIndices': [1],
      });
      expect(testApi.taskResults.ratingAnswers, [0.5]);
      expect(testApi.taskResults.events.length, 3);
    });
  });
}
