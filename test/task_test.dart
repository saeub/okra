import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okra/generated/l10n.dart';
import 'package:okra/src/pages/task.dart';
import 'package:okra/src/tasks/reaction_time.dart';
import 'package:okra/src/tasks/task.dart';
import 'package:okra/src/tasks/types.dart';
import 'package:okra/main.dart' as okra;

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

  void expectLogged(String label,
      {Map<String, dynamic> data, bool allowAdditionalKeys = false}) {
    expect(logger.events[_eventIndex].label, label);
    if (data != null) {
      if (allowAdditionalKeys) {
        for (var key in data.keys) {
          expect(logger.events[_eventIndex].data[key], data[key]);
        }
      } else {
        expect(logger.events[_eventIndex].data, data);
      }
    }
    _eventIndex++;
  }

  void expectDoneLogging() {
    expect(logger.events.length, _eventIndex);
  }
}

void main() {
  okra.testMode = true;

  group('Cloze', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.cloze,
        {
          'segments': [
            {
              'text': 'This is a  and it is interesting.',
              'blankPosition': 10,
              'options': ['test', 'example', 'pineapple'],
            },
            {
              'text': 'This is a segment without blanks.',
            },
            {
              'text': 'This one has  option.',
              'blankPosition': 13,
              'options': ['only one'],
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenOptionIndices': [2, null, 0]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', data: {'segment': 0});
      expect(find.textContaining('This is a '), findsOneWidget);
      expect(find.textContaining(' and it is interesting.'), findsOneWidget);
      expect(find.text('test'), findsOneWidget);
      expect(find.text('example'), findsOneWidget);
      expect(find.text('pineapple'), findsOneWidget);
      await tester.tap(find.text('test'));
      l.expectLogged('chose option', data: {'segment': 0, 'option': 0});
      await tester.tap(find.text('pineapple'));
      l.expectLogged('chose option', data: {'segment': 0, 'option': 2});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', data: {'segment': 0});

      l.expectLogged('started segment', data: {'segment': 1});
      expect(find.textContaining('This is a segment without blanks.'),
          findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', data: {'segment': 1});

      l.expectLogged('started segment', data: {'segment': 2});
      expect(find.textContaining('This one has '), findsOneWidget);
      expect(find.textContaining(' option.'), findsOneWidget);
      expect(find.text('only one'), findsOneWidget);
      await tester.tap(find.text('only one'));
      l.expectLogged('chose option', data: {'segment': 2, 'option': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', data: {'segment': 2});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.cloze,
        {
          'segments': [
            {
              'text': 'This is a  and it is interesting.',
              'blankPosition': 10,
              'options': ['test', 'example', 'pineapple'],
              'correctOptionIndex': 3,
            },
            {
              'text': 'This one has  option.',
              'blankPosition': 13,
              'options': ['only one'],
              'correctOptionIndex': 0,
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenOptionIndices': [0, 0]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', data: {'segment': 0});
      await tester.tap(find.text('test'));
      l.expectLogged('chose option', data: {'segment': 0, 'option': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', data: {'segment': 0});
      l.expectLogged('started feedback', data: {'segment': 0});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'segment': 0});

      l.expectLogged('started segment', data: {'segment': 1});
      expect(find.text('only one'), findsOneWidget);
      await tester.tap(find.text('only one'));
      l.expectLogged('chose option', data: {'segment': 1, 'option': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished segment', data: {'segment': 1});
      l.expectLogged('started feedback', data: {'segment': 1});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'segment': 1});

      l.expectDoneLogging();
    });
  });

  group('Lexical decision', () {
    testWidgets('can be completed', (tester) async {
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

      l.expectLogged('started word', data: {'word': 0});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 0, 'answer': true});

      l.expectLogged('started word', data: {'word': 1});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 1, 'answer': false});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
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

      l.expectLogged('started word', data: {'word': 0});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 0, 'answer': true});
      l.expectLogged('started feedback', data: {'word': 0});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 0});

      l.expectLogged('started word', data: {'word': 1});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 1, 'answer': false});
      l.expectLogged('started feedback', data: {'word': 1});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 1});

      l.expectLogged('started word', data: {'word': 2});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 2, 'answer': true});
      l.expectLogged('started feedback', data: {'word': 2});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 2});

      l.expectLogged('started word', data: {'word': 3});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 3, 'answer': false});
      l.expectLogged('started feedback', data: {'word': 3});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 3});

      l.expectDoneLogging();
    });
  });

  group('Picture naming', () {
    const dummyPicture =
        '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/ooooA//2Q==';

    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

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
            'chosenPictureIndices': [2, 0, -1]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started subtask', data: {'subtask': 0});
      expect(find.text('First subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(3));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).at(0));
      l.expectLogged('chose picture', data: {'subtask': 0, 'picture': 0});
      await tester.tap(find.byType(Card).at(2));
      l.expectLogged('chose picture', data: {'subtask': 0, 'picture': 2});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 0});

      l.expectLogged('started subtask', data: {'subtask': 1});
      expect(find.text('Second subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(1));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).at(0));
      l.expectLogged('chose picture', data: {'subtask': 1, 'picture': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 1});

      l.expectLogged('started subtask', data: {'subtask': 2});
      expect(find.text('Third subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.text('?'));
      l.expectLogged('chose picture', data: {'subtask': 2, 'picture': -1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 2});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
      // TODO: Make the task screen size independent, remove this setup
      tester.binding.window.physicalSizeTestValue = Size(600, 1100);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

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
              'correctPictureIndex': 1
            },
            {
              'text': 'Second subtask',
              'pictures': [
                dummyPicture,
              ],
              'correctPictureIndex': 0
            },
            {
              'text': 'Third subtask',
              'pictures': [
                dummyPicture,
                dummyPicture,
              ],
              'correctPictureIndex': 0
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenPictureIndices': [1, -1, 1]
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started subtask', data: {'subtask': 0});
      await tester.tap(find.byType(Card).at(1));
      l.expectLogged('chose picture', data: {'subtask': 0, 'picture': 1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 0});
      l.expectLogged('started feedback', data: {'subtask': 0});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'subtask': 0});

      l.expectLogged('started subtask', data: {'subtask': 1});
      expect(find.text('Second subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(1));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.text('?'));
      l.expectLogged('chose picture', data: {'subtask': 1, 'picture': -1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 1});
      l.expectLogged('started feedback', data: {'subtask': 1});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'subtask': 1});

      l.expectLogged('started subtask', data: {'subtask': 2});
      expect(find.text('Third subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).at(1));
      l.expectLogged('chose picture', data: {'subtask': 2, 'picture': 1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 2});
      l.expectLogged('started feedback', data: {'subtask': 2});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'subtask': 2});

      l.expectDoneLogging();
    });
  });

  group('Question answering', () {
    testWidgets('can be completed', (tester) async {
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
            'chosenAnswerIndices': [2, 0]
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
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 0});
      await tester.tap(find.text('Maybe'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 2});
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH')); // disabled

      await tester
          .ensureVisible(find.text('What about this?', skipOffstage: false));
      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', data: {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished answering');

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
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
              'correctAnswerIndex': 2,
            },
            {
              'question': 'What about this?',
              'answers': ['Definitely'],
              'correctAnswerIndex': 0,
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenAnswerIndices': [1, 0]
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
      await tester.ensureVisible(find.text('No', skipOffstage: false));
      await tester.tap(find.text('No'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 1});

      await tester
          .ensureVisible(find.text('What about this?', skipOffstage: false));
      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', data: {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('FINISH', skipOffstage: false));
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished answering');

      l.expectLogged('started feedback');
      expect(find.byIcon(Icons.arrow_forward, skipOffstage: false),
          findsNWidgets(2)); // feedback + "FINISH" button
      expect(find.byIcon(Icons.check, skipOffstage: false), findsOneWidget);
      await tester.tap(find.text('FINISH')); // disabled
      l.expectLogged('finished feedback');
      await tester.pumpAndSettle();

      l.expectDoneLogging();
    });

    testWidgets('supports self-paced reading without questions',
        (tester) async {
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
          expect(data, {'chosenAnswerIndices': []});
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading');

      l.expectLogged('started segment', data: {
        'segments': [0]
      });
      expect(find.text('First segment.'), findsOneWidget);
      await tester.tap(find.text('First segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', data: {
        'segments': [0, 1]
      });
      expect(find.text('First segment.'), findsOneWidget);
      expect(find.text('Second segment.'), findsOneWidget);
      await tester.tap(find.text('Second segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', data: {
        'segments': [1, 2]
      });
      expect(find.text('Second segment.'), findsOneWidget);
      expect(find.text('Third segment.'), findsOneWidget);
      await tester.tap(find.text('Third segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('started segment', data: {
        'segments': [2]
      });
      expect(find.text('Third segment.'), findsOneWidget);
      await tester.tap(find.text('Third segment.'));
      await tester.pumpAndSettle();

      l.expectLogged('finished reading');
      l.expectDoneLogging();
    });
  });

  group('Reaction time', () {
    testWidgets('can be completed', (tester) async {
      // Reduce screen size to restrict stimulus positions
      tester.binding.window.physicalSizeTestValue = Size(100, 100);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        TaskType.reactionTime,
        {
          'nStimuli': 3,
          'minSecondsBetweenStimuli': 0,
          'maxSecondsBetweenStimuli': 0,
        },
        logger,
        ({data, message}) {
          for (var reactionTime in data['reactionTimes']) {
            expect(reactionTime >= 0 && reactionTime < 0.5, true);
          }
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stimulus', data: {'stimulus': null});
      expect(find.text('Pop the balloon!'), findsOneWidget);
      await tester.tapAt(Offset(20, 20));
      await tester.pumpAndSettle();
      l.expectLogged('tapped screen', data: {
        'stimulus': null,
        'position': {'x': 20.0, 'y': 12.0}
      });
      l.expectLogged('tapped stimulus', data: {'stimulus': null});

      for (var i = 0; i < 3; i++) {
        l.expectLogged('started stimulus',
            data: {'stimulus': i}, allowAdditionalKeys: true);
        expect(find.text('Tap the balloon!'), findsNothing);
        await tester.tapAt(Offset(20, 20));
        await tester.pumpAndSettle();
        l.expectLogged('tapped screen', data: {
          'stimulus': i,
          'position': {'x': 20.0, 'y': 12.0}
        });
        l.expectLogged('tapped stimulus', data: {'stimulus': i});
      }

      l.expectDoneLogging();
    });

    test('generates stimulus positions within visible area', () async {
      var logger = TaskEventLogger();
      var task = ReactionTime()
        ..logger = logger
        ..init({
          'nStimuli': 1,
          'minSecondsBetweenStimuli': 0,
          'maxSecondsBetweenStimuli': 1.5,
        });
      await task.loadAssets();

      for (var i = 0; i < 10000; i++) {
        task.randomizeStimulusPosition(
            BoxConstraints(maxWidth: 800, maxHeight: 300));
        var hitbox = task.getStimulusHitbox();
        expect(hitbox.left >= 0, true);
        expect(hitbox.top >= 0, true);
        expect(hitbox.right < 800, true);
        expect(hitbox.bottom < 300, true);
      }
    });

    test('generates stimulus delays within configured range', () async {
      var logger = TaskEventLogger();
      var task = ReactionTime()
        ..logger = logger
        ..init({
          'nStimuli': 1,
          'minSecondsBetweenStimuli': 0.005,
          'maxSecondsBetweenStimuli': 0.995,
        });
      await task.loadAssets();

      for (var i = 0; i < 10000; i++) {
        var delay = task.generateRandomStimulusDelay();
        expect(delay.inMilliseconds >= 5, true);
        expect(delay.inMilliseconds < 995, true);
      }

      task.init({
        'nStimuli': 1,
        'minSecondsBetweenStimuli': 0.5,
        'maxSecondsBetweenStimuli': 0.5,
      });
      for (var i = 0; i < 10000; i++) {
        var delay = task.generateRandomStimulusDelay();
        expect(delay.inMilliseconds, 500);
      }

      task.init({
        'nStimuli': 1,
        'minSecondsBetweenStimuli': 0.5,
        'maxSecondsBetweenStimuli': 0,
      });
      for (var i = 0; i < 10000; i++) {
        var delay = task.generateRandomStimulusDelay();
        expect(delay.inMilliseconds, 500);
      }
    });
  });
}
