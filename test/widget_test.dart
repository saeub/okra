import 'package:flutter/material.dart';
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
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class TestApi extends Api {
  final bool unstable;
  TaskResults? taskResults;
  late int nRetries;

  TestApi({this.unstable = false}) {
    nRetries = 0;
  }

  void _maybeFail() {
    if (unstable && nRetries == 0) {
      nRetries++;
      throw ApiError(retriable: true);
    }
    nRetries = 0;
  }

  @override
  String getName() {
    return 'Test API';
  }

  @override
  Image? getIcon() {
    return null;
  }

  @override
  Future<List<Experiment>> getExperiments() async {
    _maybeFail();
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
      ratings: const [
        TaskRating('Question?', TaskRatingType.slider),
      ],
    );
  }

  @override
  Future<TaskData> startTask(String experimentId,
      {bool practice = false}) async {
    _maybeFail();
    if (practice) {
      return const TaskData(
          'test',
          {
            'segments': [
              {
                'text': 'This is .',
                'blankPosition': 8,
                'options': ['madness', 'practice'],
              },
            ],
          },
          instructionsAfter:
              "You've completed the practice task. Now continue with the main task.");
    } else {
      return const TaskData('test', {
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
    _maybeFail();
    taskResults = results;
  }
}

var testApi = TestApi();
var unstableTestApi = TestApi(unstable: true);

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
      expect(find.text('The next task will count!'), findsNothing);
      expect(find.text('REPEAT PRACTICE TASK'), findsNothing);
      expect(testApi.taskResults?.data, {
        'chosenOptionIndices': [1],
      });
      expect(testApi.taskResults?.ratingAnswers, [0.5]);
      expect(testApi.taskResults?.events.length, 3);
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
      expect(find.text('The next task will count!'), findsOneWidget);
      expect(find.text('REPEAT PRACTICE TASK'), findsOneWidget);
      expect(testApi.taskResults?.data, {
        'chosenOptionIndices': [1],
      });
      expect(testApi.taskResults?.ratingAnswers, null);
      expect(testApi.taskResults?.events.length, 3);

      // Repeat
      await tester.tap(find.text('REPEAT PRACTICE TASK'));
      await tester.pumpAndSettle();
      // Task
      expect(find.text('PRACTICE'), findsOneWidget);
      expect(find.text('This task does not count'), findsOneWidget);
      await tester.tap(find.text('madness'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // No ratings for practice tasks
      // Results
      expect(find.text('The next task will count!'), findsOneWidget);
      expect(find.text('REPEAT PRACTICE TASK'), findsOneWidget);
      expect(testApi.taskResults?.data, {
        'chosenOptionIndices': [0],
      });
      expect(testApi.taskResults?.ratingAnswers, null);
      expect(testApi.taskResults?.events.length, 3);
    });

    testWidgets('displays instructions after task',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          getApp(TaskPage(await testApi.getExperiment('test-practice'))));
      await tester.pumpAndSettle();
      // Instructions
      await tester.tap(find.text('START PRACTICE TASK'));
      await tester.pumpAndSettle();
      // Task
      await tester.tap(find.text('practice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // No ratings for practice tasks
      // Results
      expect(
          find.text(
              "You've completed the practice task. Now continue with the main task."),
          findsOneWidget);
    });

    // FIXME: This doesn't work because of async exceptions
    testWidgets('tolerates unstable connection', (WidgetTester tester) async {
      await tester.pumpWidget(
          getApp(TaskPage(await unstableTestApi.getExperiment('test'))));
      await tester.pumpAndSettle();
      // Instructions
      await tester.tap(find.text('START TASK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RETRY'));
      await tester.pumpAndSettle();
      // Task
      await tester.tap(find.text('example'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      // Ratings
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('RETRY'));
      await tester.pumpAndSettle();
      // Results
      expect(find.text('The next task will count!'), findsNothing);
      expect(find.text('REPEAT PRACTICE TASK'), findsNothing);
      expect(unstableTestApi.taskResults?.data, {
        'chosenOptionIndices': [1],
      });
      expect(unstableTestApi.taskResults?.ratingAnswers, [0.5]);
      expect(unstableTestApi.taskResults?.events.length, 3);
    }, skip: true);
  });

  group('SettingsPage', () {
    testWidgets('shows "about" list tile', (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'MockOkra',
        packageName: 'mock.okra',
        version: '1.2.3',
        buildNumber: '',
        buildSignature: '',
      );

      await tester.pumpWidget(getApp(const SettingsPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About '));
      await tester.pumpAndSettle();
      expect(find.text('1.2.3'), findsOneWidget);
      expect(find.text('VIEW LICENSES'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });
  });
}
