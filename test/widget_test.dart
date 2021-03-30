import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/image.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:okra/generated/l10n.dart';
import 'package:okra/src/data/api.dart';
import 'package:okra/src/data/models.dart';
import 'package:okra/src/data/storage.dart';
import 'package:okra/src/data/tutorial.dart';
import 'package:okra/src/pages/settings.dart';
import 'package:okra/src/pages/task.dart';
import 'package:okra/src/tasks/types.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class MockStorage extends Mock implements Storage {
  @override
  List<WebApi> get webApis => [];

  @override
  TutorialApi get tutorialApi => TutorialApi(this);

  @override
  bool get showCompleted => false;
}

var storage = MockStorage();

Widget getApp(Widget widget) {
  return MaterialApp(
    home: ChangeNotifierProvider<Storage>.value(
      value: storage,
      child: Scaffold(
        body: widget,
      ),
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
      hasPracticeTask: experimentId == 'test-practice',
      ratings: [
        TaskRating('Question?', TaskRatingType.slider),
      ],
    );
  }

  @override
  Future<TaskData> startTask(String experimentId,
      {bool practice = false}) async {
    if (practice) {
      return TaskData('test', {
        'segments': [
          {
            'text': 'This is .',
            'blankPosition': 8,
            'options': ['madness', 'practice'],
          },
        ],
      });
    } else {
      return TaskData('test', {
        'segments': [
          {
            'text': 'This is a .',
            'blankPosition': 10,
            'options': ['test', 'example'],
          },
        ],
      });
    }
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
      await tester.tap(find.text('START TASK'));
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
      expect(find.text('Continue with the next one?'), findsOneWidget);
      expect(find.text('The next task will count!'), findsNothing);
      expect(testApi.taskResults.data, {
        'chosenOptionIndices': [1],
      });
      expect(testApi.taskResults.ratingAnswers, [0.5]);
      expect(testApi.taskResults.events.length, 3);
    });

    testWidgets('supports practice tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
          getApp(TaskPage(await testApi.getExperiment('test-practice'))));
      await tester.pumpAndSettle();
      // Instructions
      await tester.tap(find.text('START PRACTICE TASK'));
      await tester.pumpAndSettle();
      // Task
      expect(find.text('PRACTICE'), findsOneWidget);
      expect(find.text('This task does not count'), findsOneWidget);
      await tester.tap(find.text('practice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // No ratings for practice tasks
      // Results
      expect(find.text('Continue with the next one?'), findsOneWidget);
      expect(find.text('The next task will count!'), findsOneWidget);
      expect(testApi.taskResults.data, {
        'chosenOptionIndices': [1],
      });
      expect(testApi.taskResults.ratingAnswers, null);
      expect(testApi.taskResults.events.length, 3);
    });
  });

  group('SettingsPage', () {
    testWidgets('shows "about" list tile', (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'MockOkra',
        packageName: 'mock.okra',
        version: '1.2.3',
        buildNumber: '',
      );

      await tester.pumpWidget(getApp(SettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About '));
      await tester.pumpAndSettle();
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('VIEW LICENSES'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });
  });
}
