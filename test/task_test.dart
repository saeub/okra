import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okra/generated/l10n.dart';
import 'package:okra/src/pages/task.dart';
import 'package:okra/src/tasks/task.dart';
import 'package:okra/src/tasks/types.dart';

MaterialApp getTaskApp(TaskType type, Map<String, dynamic> data,
    TaskEventLogger logger, FinishCallback onFinished) {
  return MaterialApp(
    home: Scaffold(
      body: TaskWidget(type.taskFactory, data, logger, onFinished),
    ),
    localizationsDelegates: [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class LoggerTester {
  final TaskEventLogger logger;
  int _eventIndex;

  LoggerTester(this.logger) {
    _eventIndex = 0;
  }

  void expectLogged(String label, [Map<String, dynamic> data]) {
    expect(logger.events[_eventIndex].label, label);
    if (data != null) {
      expect(logger.events[_eventIndex].data, data);
    }
    _eventIndex++;
  }

  void expectDoneLogging() {
    expect(logger.events.length, _eventIndex);
  }
}

void main() {
  group('Cloze', () {
    testWidgets('can be completed', (WidgetTester tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.cloze,
        {
          'segments': [
            'This is a {{test|example|pineapple}} and it is interesting.',
            'This is a segment without gaps.',
            'This one has {{only one}} option.',
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenIndices': [2, null, 0]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', {'segment': 0});
      expect(find.textContaining('This is a '), findsOneWidget);
      expect(find.textContaining(' and it is interesting.'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);
      expect(find.text('example'), findsOneWidget);
      expect(find.text('pineapple'), findsOneWidget);
      await tester.tap(find.text('test'));
      l.expectLogged('chose option', {'segment': 0, 'option': 0});
      await tester.tap(find.text('pineapple'));
      l.expectLogged('chose option', {'segment': 0, 'option': 2});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', {'segment': 0});

      l.expectLogged('started segment', {'segment': 1});
      expect(find.textContaining('This is a segment without gaps.'),
          findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', {'segment': 1});

      l.expectLogged('started segment', {'segment': 2});
      expect(find.textContaining('This one has '), findsOneWidget);
      expect(find.textContaining(' option.'), findsOneWidget);
      expect(find.text('only one'), findsOneWidget);
      await tester.tap(find.text('only one'));
      l.expectLogged('chose option', {'segment': 2, 'option': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', {'segment': 2});

      l.expectDoneLogging();
    });
  });

  group('Lexical decision', () {
    testWidgets('can be completed', (WidgetTester tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.lexicalDecision,
        {
          'words': ['word', 'non-word'],
        },
        logger,
        ({data, message}) {
          expect(data['answers'], [true, false]);
          expect(data['durations'].length, 2);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started countdown');
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished countdown');

      l.expectLogged('started word', {'word': 0});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 0, 'answer': true});

      l.expectLogged('started word', {'word': 1});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 1, 'answer': false});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (WidgetTester tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.lexicalDecision,
        {
          'words': ['word', 'word', 'non-word', 'non-word'],
          'correctAnswers': [true, true, false, false],
        },
        logger,
        ({data, message}) {
          expect(data['answers'], [true, false, true, false]);
          expect(data['durations'].length, 4);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started countdown');
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished countdown');

      l.expectLogged('started word', {'word': 0});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 0, 'answer': true});
      l.expectLogged('started feedback', {'word': 0, 'feedback': true});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', {'word': 0});

      l.expectLogged('started word', {'word': 1});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 1, 'answer': false});
      l.expectLogged('started feedback', {'word': 1, 'feedback': false});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', {'word': 1});

      l.expectLogged('started word', {'word': 2});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 2, 'answer': true});
      l.expectLogged('started feedback', {'word': 2, 'feedback': false});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', {'word': 2});

      l.expectLogged('started word', {'word': 3});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', {'word': 3, 'answer': false});
      l.expectLogged('started feedback', {'word': 3, 'feedback': true});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', {'word': 3});

      l.expectDoneLogging();
    });
  });

  group('Picture naming', () {
    testWidgets('can be completed', (WidgetTester tester) async {
      // TODO: Make the task screen size independent, remove this setup
      tester.binding.window.physicalSizeTestValue = Size(600, 1100);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      const dummyPicture =
          '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/ooooA//2Q==';
      await tester.pumpWidget(getTaskApp(
        TaskType.pictureNaming,
        {
          'showQuestionMark': true,
          'subtasks': [
            {
              'text': 'First subtask',
              'pictures': [
                dummyPicture,
                dummyPicture,
                dummyPicture,
              ],
            },
            {
              'text': 'Second subtask',
              'pictures': [
                dummyPicture,
              ],
            },
            {
              'text': 'Third subtask',
              'pictures': [
                dummyPicture,
                dummyPicture,
              ],
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenIndices': [2, 0, -1]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started subtask', {'subtask': 0});
      expect(find.text('First subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).at(0));
      l.expectLogged('chose picture', {'subtask': 0, 'picture': 0});
      await tester.tap(find.byType(Card).at(2));
      l.expectLogged('chose picture', {'subtask': 0, 'picture': 2});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', {'subtask': 0});

      l.expectLogged('started subtask', {'subtask': 1});
      expect(find.text('Second subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(1));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).at(0));
      l.expectLogged('chose picture', {'subtask': 1, 'picture': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', {'subtask': 1});

      l.expectLogged('started subtask', {'subtask': 2});
      expect(find.text('Third subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.text('?'));
      l.expectLogged('chose picture', {'subtask': 2, 'picture': -1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', {'subtask': 2});

      l.expectDoneLogging();
    });
  });

  group('Question answering', () {
    testWidgets('can be completed', (WidgetTester tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.questionAnswering,
        {
          'readingType': 'normal',
          'text': 'This is an example text.',
          'questions': [
            {
              'question': 'Is this a question?',
              'answers': ['Yes', 'No', 'Maybe'],
            },
            {
              'question': 'What about this?',
              'answers': ['Definitely'],
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenIndices': [2, 0]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading');
      expect(find.byType(MarkdownBody), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading');

      l.expectLogged('started answering');
      expect(find.text('Is this a question?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH')); // disabled
      await tester.ensureVisible(find.text('Yes', skipOffstage: false));
      await tester.tap(find.text('Yes'));
      l.expectLogged('chose answer', {'question': 0, 'answer': 0});
      await tester.tap(find.text('Maybe'));
      l.expectLogged('chose answer', {'question': 0, 'answer': 2});
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH')); // disabled

      await tester
          .ensureVisible(find.text('What about this?', skipOffstage: false));
      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished answering');

      l.expectDoneLogging();
    });

    testWidgets('supports self-paced reading without questions',
        (WidgetTester tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.questionAnswering,
        {
          'readingType': 'self-paced',
          'text': 'First segment.\nSecond segment.\nThird segment.',
        },
        logger,
        ({data, message}) {
          expect(data, {'chosenIndices': []});
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading');

      l.expectLogged('started segment', {
        'segments': [0]
      });
      expect(find.text('First segment.'), findsOneWidget);
      await tester.tap(find.text('First segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', {
        'segments': [0, 1]
      });
      expect(find.text('First segment.'), findsOneWidget);
      expect(find.text('Second segment.'), findsOneWidget);
      await tester.tap(find.text('Second segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', {
        'segments': [1, 2]
      });
      expect(find.text('Second segment.'), findsOneWidget);
      expect(find.text('Third segment.'), findsOneWidget);
      await tester.tap(find.text('Third segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', {
        'segments': [2]
      });
      expect(find.text('Third segment.'), findsOneWidget);
      await tester.tap(find.text('Third segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('finished reading');
      l.expectDoneLogging();
    });
  });
}
