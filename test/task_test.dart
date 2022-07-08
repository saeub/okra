import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okra/generated/l10n.dart';
import 'package:okra/src/pages/task.dart';
import 'package:okra/src/tasks/digit_span.dart';
import 'package:okra/src/tasks/n_back.dart';
import 'package:okra/src/tasks/reaction_time.dart';
import 'package:okra/src/tasks/reading.dart';
import 'package:okra/src/tasks/simon_game.dart';
import 'package:okra/src/tasks/task.dart';
import 'package:okra/src/tasks/types.dart';

MaterialApp getTaskApp(String taskType, Map<String, dynamic> data,
    TaskEventLogger logger, FinishCallback onFinished) {
  return MaterialApp(
    home: Scaffold(
      body: TaskWidget(
          TaskType.fromString(taskType).taskFactory, data, logger, onFinished),
    ),
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class LoggerTester {
  final TaskEventLogger logger;
  late int _eventIndex;

  LoggerTester(this.logger) {
    _eventIndex = 0;
  }

  Map<String, dynamic>? expectLogged(String label,
      {Map<String, dynamic>? data, bool allowAdditionalKeys = false}) {
    if (logger.events.length <= _eventIndex) {
      fail('Nothing was logged');
    }
    var actualLabel = logger.events[_eventIndex].label;
    expect(actualLabel, label);
    var actualData = logger.events[_eventIndex].data;
    if (data != null) {
      if (allowAdditionalKeys) {
        for (var key in data.keys) {
          expect(actualData?[key], data[key]);
        }
      } else {
        expect(actualData, data);
      }
    }
    _eventIndex++;
    return actualData;
  }

  void expectDoneLogging() {
    expect(logger.events.length, _eventIndex);
  }
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;

  group('Cloze', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'cloze',
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
        'cloze',
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
      await tester.pump(const Duration(seconds: 1));
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
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'segment': 1});

      l.expectDoneLogging();
    });
  });

  group('Digit span', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'digit-span',
        {},
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      // 1 correct response
      var loggedData = l.expectLogged('started displaying span');
      List<num> span = loggedData?['span'];
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[0].toString()), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[0].toString()), findsNothing);
      expect(find.text(span[1].toString()), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[1].toString()), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[1].toString()), findsNothing);
      expect(find.text(span[2].toString()), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[2].toString()), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(span[1].toString()), findsNothing);
      expect(find.text(span[2].toString()), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      l.expectLogged('finished displaying span', data: {'span': span});

      expect(find.byType(DigitSpanInput), findsOneWidget);
      await tester.tap(find.text('DONE')); // disabled
      for (var digit in span) {
        await tester.tap(find.widgetWithText(DigitButton, digit.toString()));
      }
      await tester.pumpAndSettle();
      expect(find.text(span.join()), findsOneWidget);
      await tester.tap(find.text('DONE'));
      l.expectLogged('submitted response',
          data: {'response': span, 'correct': span});

      // 2 incorrect responses
      for (var i = 0; i < 2; i++) {
        loggedData = l.expectLogged('started displaying span');
        span = loggedData?['span'];
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        l.expectLogged('finished displaying span', data: {'span': span});

        var response = [for (var digit in span) (digit + 1) % 10];
        expect(find.byType(DigitSpanInput), findsOneWidget);
        await tester.tap(find.text('DONE')); // disabled
        for (var digit in response) {
          await tester.tap(find.widgetWithText(DigitButton, digit.toString()));
        }
        await tester.pumpAndSettle();
        expect(find.text(response.join()), findsOneWidget);
        await tester.tap(find.text('DONE'));
        await tester.pumpAndSettle();
        l.expectLogged('submitted response',
            data: {'response': response, 'correct': span});
      }
      l.expectDoneLogging();
    });

    testWidgets('supports span criteria', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'digit-span',
        {
          'maxErrors': 1,
          'initialLength': 20,
          'excludeDigits': [0, 1, 2, 3, 4, 5, 6, 7]
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      var loggedData = l.expectLogged('started displaying span');
      List<num> span = loggedData?['span'];
      // initialLength
      expect(span.length, 20);
      // excludeDigits
      for (var i in [0, 1, 2, 3, 4, 5, 6, 7]) {
        expect(span.contains(i), false);
      }
      // No equal consecutive digits
      for (var i = 1; i < span.length; i++) {
        expect(span[i - 1] == span[i], false);
      }
      for (var i = 0; i < 41; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      l.expectLogged('finished displaying span', data: {'span': span});

      expect(find.byType(DigitSpanInput), findsOneWidget);
      await tester.tap(find.widgetWithText(DigitButton, '0'));
      await tester.tap(find.widgetWithText(DigitButton, '1'));
      await tester.pumpAndSettle();
      expect(find.text('01'), findsOneWidget);
      await tester.tap(find.text('DONE'));
      l.expectLogged('submitted response', data: {
        'response': [0, 1],
        'correct': span
      });

      l.expectDoneLogging();
    });
  });

  group('Lexical decision', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'lexical-decision',
        {
          'words': ['word', 'non-word'],
        },
        logger,
        ({data, message}) {
          expect(data?['answers'], [true, false]);
          expect(data?['durations'].length, 2);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started countdown');
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.tap(find.text('NOT A WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
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
        'lexical-decision',
        {
          'words': ['word', 'word', 'non-word', 'non-word'],
          'correctAnswers': [true, true, false, false],
        },
        logger,
        ({data, message}) {
          expect(data?['answers'], [true, false, true, false]);
          expect(data?['durations'].length, 4);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started countdown');
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished countdown');

      l.expectLogged('started word', data: {'word': 0});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 0, 'answer': true});
      l.expectLogged('started feedback', data: {'word': 0});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 0});

      l.expectLogged('started word', data: {'word': 1});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 1, 'answer': false});
      l.expectLogged('started feedback', data: {'word': 1});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 1});

      l.expectLogged('started word', data: {'word': 2});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 2, 'answer': true});
      l.expectLogged('started feedback', data: {'word': 2});
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 2});

      l.expectLogged('started word', data: {'word': 3});
      expect(find.textContaining('word'), findsOneWidget);
      await tester.tap(find.text('NOT A WORD'));
      await tester.pumpAndSettle();
      l.expectLogged('finished word', data: {'word': 3, 'answer': false});
      l.expectLogged('started feedback', data: {'word': 3});
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      await tester.tap(find.text('WORD')); // disabled
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'word': 3});

      l.expectDoneLogging();
    });
  });

  group('n-back', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'n-back',
        {
          'n': 1,
          'stimulusChoices': ['A', 'B'],
          'nStimuli': 2,
          'nPositives': 1,
        },
        logger,
        ({data, message}) {
          expect(data, {'nTruePositives': 1, 'nFalsePositives': 1});
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();
      l.expectLogged('generated stimuli');
      await tester.pump(const Duration(milliseconds: 500));

      l.expectLogged('started showing stimulus', data: {'stimulus': 0});
      await tester.tapAt(const Offset(100, 100));
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      l.expectLogged('started feedback',
          data: {'stimulus': 0}, allowAdditionalKeys: true);
      await tester.tapAt(const Offset(100, 100)); // already feedbacked
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      await tester.pump(const Duration(milliseconds: 500));
      l.expectLogged('finished showing stimulus', data: {'stimulus': 0});
      l.expectLogged('finished feedback', data: {'stimulus': 0});
      await tester.tapAt(const Offset(100, 100)); // already feedbacked
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      await tester.pump(const Duration(milliseconds: 2500));

      l.expectLogged('started showing stimulus', data: {'stimulus': 1});
      await tester.pump(const Duration(milliseconds: 500));
      l.expectLogged('finished showing stimulus', data: {'stimulus': 1});
      await tester.tapAt(const Offset(100, 100));
      l.expectLogged('tapped screen', data: {'stimulus': 1});
      l.expectLogged('started feedback',
          data: {'stimulus': 1}, allowAdditionalKeys: true);
      await tester.pump(const Duration(milliseconds: 2500));
      l.expectLogged('finished feedback', data: {'stimulus': 1});
      l.expectDoneLogging();
    });

    test('generates valid stimulus sequences', () {
      int numberOfPositiveStimuli(List<String> stimuli, int n) {
        var count = 0;
        for (var i = n; i < stimuli.length; i++) {
          if (stimuli[i] == stimuli[i - n]) {
            count++;
          }
        }
        return count;
      }

      var nStimuli = 10;
      for (var n = 1; n <= nStimuli; n++) {
        for (var p = 0; p <= nStimuli - n; p++) {
          var stimuli = NBack.generateStimuli(['A', 'B'], nStimuli, p, n);
          var nPositives = numberOfPositiveStimuli(stimuli, n);
          expect(nPositives, p,
              reason:
                  '$stimuli (n = $n) has $nPositives positive stimuli, should be $p');
        }
      }

      expect(() => NBack.generateStimuli(['A'], 10, 3, 2), throwsArgumentError);
      expect(() => NBack.generateStimuli(['A', 'B'], 3, 2, 2),
          throwsArgumentError);
    });

    testWidgets('supports configurable stimulus durations', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'n-back',
        {
          'n': 1,
          'stimulusChoices': ['A', 'B'],
          'nStimuli': 2,
          'nPositives': 1,
          'secondsShowingStimulus': 1.5,
          'secondsBetweenStimuli': 5,
        },
        logger,
        ({data, message}) {
          expect(data, {'nTruePositives': 1, 'nFalsePositives': 1});
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();
      l.expectLogged('generated stimuli');
      await tester.pump(const Duration(milliseconds: 500));

      l.expectLogged('started showing stimulus', data: {'stimulus': 0});
      await tester.tapAt(const Offset(100, 100));
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      l.expectLogged('started feedback',
          data: {'stimulus': 0}, allowAdditionalKeys: true);
      await tester.tapAt(const Offset(100, 100)); // already feedbacked
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      await tester.pump(const Duration(milliseconds: 1500));
      l.expectLogged('finished feedback', data: {'stimulus': 0});
      l.expectLogged('finished showing stimulus', data: {'stimulus': 0});
      await tester.tapAt(const Offset(100, 100)); // already feedbacked
      l.expectLogged('tapped screen', data: {'stimulus': 0});
      await tester.pump(const Duration(milliseconds: 5000));

      l.expectLogged('started showing stimulus', data: {'stimulus': 1});
      await tester.pump(const Duration(milliseconds: 1500));
      l.expectLogged('finished showing stimulus', data: {'stimulus': 1});
      await tester.tapAt(const Offset(100, 100));
      l.expectLogged('tapped screen', data: {'stimulus': 1});
      l.expectLogged('started feedback',
          data: {'stimulus': 1}, allowAdditionalKeys: true);
      await tester.pump(const Duration(milliseconds: 5000));
      l.expectLogged('finished feedback', data: {'stimulus': 1});
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
        'picture-naming',
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
      await tester.tap(find.byType(Card).last);
      l.expectLogged('chose picture', data: {'subtask': 2, 'picture': -1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 2});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
      // TODO: Make the task screen size independent, remove this setup
      tester.binding.window.physicalSizeTestValue = const Size(600, 1100);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'picture-naming',
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
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'subtask': 0});

      l.expectLogged('started subtask', data: {'subtask': 1});
      expect(find.text('Second subtask'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(1));
      expect(find.text('?'), findsOneWidget);
      await tester.tap(find.byType(Card).last);
      l.expectLogged('chose picture', data: {'subtask': 1, 'picture': -1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished subtask', data: {'subtask': 1});
      l.expectLogged('started feedback', data: {'subtask': 1});
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.pump(const Duration(seconds: 1));
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
      await tester.pump(const Duration(seconds: 1));
      l.expectLogged('finished feedback', data: {'subtask': 2});

      l.expectDoneLogging();
    });
  });

  group('Question answering', () {
    testWidgets('can be completed', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
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
            'chosenAnswerIndices': [2, 0],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});
      expect(find.byType(MarkdownBody), findsOneWidget);

      expect(find.text('Is this a question?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      await tester.tap(find.text('FINISH')); // disabled
      await tester.tap(find.text('Yes'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 0});
      await tester.tap(find.text('Maybe'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 2});
      await tester.tap(find.text('FINISH')); // disabled

      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', data: {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

      l.expectDoneLogging();
    });

    testWidgets('supports feedback', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
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
            'chosenAnswerIndices': [1, 0],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});
      expect(find.byType(MarkdownBody), findsOneWidget);
      await tester.tap(find.text('No'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 1});
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', data: {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

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
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
        {
          'readingType': 'self-paced',
          'text': 'First segment.\nSecond segment.\nThird segment.',
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenAnswerIndices': [],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});

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

      l.expectLogged('finished reading', data: {'stage': 1});
      l.expectDoneLogging();
    });

    testWidgets('logs scroll events', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
        {
          'readingType': 'normal',
          'text':
              '# Lorem ipsum\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ullamcorper velit sed ullamcorper morbi tincidunt ornare massa eget.\n\n' *
                  5,
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenAnswerIndices': [],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});
      await tester.scrollUntilVisible(find.text('CONTINUE'), 50.0);
      l.expectLogged('scrolled text');
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

      l.expectDoneLogging();
    });

    testWidgets('supports expandable questions on small screen sizes',
        (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
        {
          'readingType': 'normal',
          'text':
              '# Lorem ipsum\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ullamcorper velit sed ullamcorper morbi tincidunt ornare massa eget.\n\n' *
                  5,
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
            'chosenAnswerIndices': [0, 0],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});
      expect(find.byType(ExpansionPanelList), findsOneWidget);
      await tester.tap(find.text('Answer questions')); // expand
      await tester.pumpAndSettle();
      l.expectLogged('expanded questions');
      await tester.tap(find.text('Yes'));
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 0});
      await tester.tap(find.text('Answer questions')); // collapse
      await tester.pumpAndSettle();
      l.expectLogged('collapsed questions');
      await tester.tap(find.text('Answer questions')); // expand
      await tester.pumpAndSettle();
      l.expectLogged('expanded questions');
      await tester.tap(find.text('Definitely'));
      l.expectLogged('chose answer', data: {'question': 1, 'answer': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

      l.expectDoneLogging();
    });

    testWidgets('supports ratings before questions', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
        {
          'readingType': 'normal',
          'text': 'This is an example text.',
          'questions': [
            {
              'question': 'Is this a question?',
              'answers': ['Yes', 'No', 'Maybe'],
            },
          ],
          'ratingsBeforeQuestions': [
            {
              'question': 'How is it?',
              'type': 'emoticon',
              'lowExtreme': 'bad',
              'highExtreme': 'good',
            },
            {
              'question': 'How was it?',
              'type': 'slider',
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenAnswerIndices': [0],
            'ratingsBeforeQuestionsAnswers': [3, 0.5],
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 0});
      expect(find.byType(MarkdownBody), findsOneWidget);

      expect(find.text('Is this a question?'), findsNothing);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 0});

      l.expectLogged('started ratings before questions');
      await tester.tap(find.text('CONTINUE')); // disabled
      expect(find.text('How is it?'), findsOneWidget);
      expect(find.text('good'), findsOneWidget);
      expect(find.text('bad'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.sentiment_satisfied));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('How was it?'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished ratings before questions');

      l.expectLogged('started reading', data: {'stage': 1});
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      l.expectLogged('chose answer', data: {'question': 0, 'answer': 0});
      await tester.tap(find.text('FINISH'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

      l.expectDoneLogging();
    });

    testWidgets('supports configurable font size', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'question-answering',
        {
          'readingType': 'normal',
          'text':
              '# Lorem ipsum\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ullamcorper velit sed ullamcorper morbi tincidunt ornare massa eget.\n\n' *
                  5,
          'fontSize': 1,
        },
        logger,
        ({data, message}) {
          expect(data, {
            'chosenAnswerIndices': [],
            'ratingsBeforeQuestionsAnswers': null,
          });
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started reading', data: {'stage': 1});
      await tester.scrollUntilVisible(find.text('CONTINUE'), 50.0);
      // No scrolling due to small font size
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished reading', data: {'stage': 1});

      l.expectDoneLogging();
    });
  });

  group('Reaction time', () {
    testWidgets('can be completed', (tester) async {
      // Reduce screen size to restrict stimulus positions
      tester.binding.window.physicalSizeTestValue = const Size(100, 100);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'reaction-time',
        {
          'nStimuli': 3,
          'minSecondsBetweenStimuli': 0,
          'maxSecondsBetweenStimuli': 0,
        },
        logger,
        ({data, message}) {
          for (var reactionTime in data?['reactionTimes']) {
            expect(reactionTime >= 0 && reactionTime < 0.5, true);
          }
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stimulus', data: {'stimulus': null});
      expect(find.text('Pop the balloon!'), findsOneWidget);
      await tester.tapAt(const Offset(20, 20));
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
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        l.expectLogged('tapped screen', data: {
          'stimulus': i,
          'position': {'x': 20.0, 'y': 12.0}
        });
        l.expectLogged('tapped stimulus', data: {'stimulus': i});
      }

      l.expectDoneLogging();
    }, skip: true);

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
            const BoxConstraints(maxWidth: 800, maxHeight: 300));
        var hitbox = task.getStimulusHitbox()!;
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

  group('Reading', () {
    testWidgets('can be completed', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'reading',
        {
          'text': 'This is an example text.',
          'textWidth': 300,
          'textHeight': 200,
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
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stage', data: {'type': 'ScrollableTextStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished stage', data: {'type': 'ScrollableTextStage'});

      l.expectLogged('started stage', data: {'type': 'QuestionsStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      expect(find.text('Is this a question?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      expect(find.text('CONTINUE'), findsNothing);
      await tester.tap(find.text('Yes'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 0});
      await tester.tap(find.text('Maybe'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 2});
      expect(find.text('CONTINUE'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      l.expectLogged('turned to question', data: {'questionIndex': 1});

      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 1, 'answerIndex': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('submitted answers', data: {
        'answerIndices': [2, 0]
      });
      l.expectLogged('finished stage', data: {'type': 'QuestionsStage'});

      l.expectDoneLogging();
    });

    testWidgets('logs scroll events', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'reading',
        {
          'text': 'This is an example text.',
          'textWidth': 100,
          'textHeight': 50,
          'questions': [
            {
              'question': 'Is this a question?',
              'answers': ['Yes', 'No', 'Maybe'],
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stage', data: {'type': 'ScrollableTextStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 16]
      });
      await tester.tap(find.text('CONTINUE'), warnIfMissed: false); // invisible
      l.expectDoneLogging();
      await tester.drag(find.byType(ScrollableText), const Offset(0, -20));
      l.expectLogged('visible range', data: {
        'characterRange': [5, 19]
      });
      await tester.drag(find.byType(ScrollableText), const Offset(0, -20));
      l.expectLogged('visible range', data: {
        'characterRange': [11, 24]
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished stage', data: {'type': 'ScrollableTextStage'});

      l.expectLogged('started stage', data: {'type': 'QuestionsStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 16]
      });
      expect(find.text('CONTINUE'), findsNothing);
      await tester.drag(find.byType(ScrollableText), const Offset(0, -20));
      l.expectLogged('visible range', data: {
        'characterRange': [5, 19]
      });
      await tester.drag(find.byType(ScrollableText), const Offset(0, -20));
      l.expectLogged('visible range', data: {
        'characterRange': [11, 24]
      });
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 1});
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('submitted answers', data: {
        'answerIndices': [1]
      });
      l.expectLogged('finished stage', data: {'type': 'QuestionsStage'});

      l.expectDoneLogging();
    });

    testWidgets('supports ratings', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'reading',
        {
          'text': 'This is an example text.',
          'textWidth': 300,
          'textHeight': 200,
          'ratings': [
            {
              'question': 'How is it?',
              'type': 'emoticon',
              'lowExtreme': 'bad',
              'highExtreme': 'good',
            },
            {
              'question': 'How was it?',
              'type': 'slider',
              'lowExtreme': 'bad',
              'highExtreme': 'good',
            },
          ],
          'questions': [
            {
              'question': 'Is this a question?',
              'answers': ['Yes', 'No', 'Maybe'],
            },
          ],
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stage', data: {'type': 'ScrollableTextStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished stage', data: {'type': 'ScrollableTextStage'});

      l.expectLogged('started stage', data: {'type': 'RatingsStage'});
      expect(find.text('How is it?'), findsOneWidget);
      expect(find.text('bad'), findsOneWidget);
      expect(find.text('good'), findsOneWidget);
      await tester.tap(find.text('CONTINUE')); // disabled
      await tester.tap(find.byIcon(Icons.sentiment_satisfied));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      expect(find.text('How was it?'), findsOneWidget);
      expect(find.text('bad'), findsOneWidget);
      expect(find.text('good'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished ratings', data: {
        'answers': [3, 0.5]
      });
      l.expectLogged('finished stage', data: {'type': 'RatingsStage'});

      l.expectLogged('started stage', data: {'type': 'QuestionsStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 1});
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('submitted answers', data: {
        'answerIndices': [1]
      });
      l.expectLogged('finished stage', data: {'type': 'QuestionsStage'});

      l.expectDoneLogging();
    });

    testWidgets('supports answer correction', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(20000, 20000);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'reading',
        {
          'text': 'This is an example text.',
          'textWidth': 300,
          'textHeight': 200,
          'questions': [
            {
              'question': 'Is this a question?',
              'answers': ['Yes', 'No', 'Maybe'],
              'correctAnswerIndex': 0,
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
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started stage', data: {'type': 'ScrollableTextStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('finished stage', data: {'type': 'ScrollableTextStage'});

      l.expectLogged('started stage', data: {'type': 'QuestionsStage'});
      expect(find.byType(ScrollableText), findsOneWidget);
      l.expectLogged('visible range', data: {
        'characterRange': [0, 24]
      });
      expect(find.text('Is this a question?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      expect(find.text('CONTINUE'), findsNothing);
      await tester.tap(find.text('Yes'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 0});
      await tester.tap(find.text('Maybe'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 2});
      expect(find.text('CONTINUE'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pumpAndSettle();
      l.expectLogged('turned to question', data: {'questionIndex': 1});

      expect(find.text('What about this?'), findsOneWidget);
      expect(find.text('Definitely'), findsOneWidget);
      await tester.tap(find.text('Definitely'));
      l.expectLogged('selected answer',
          data: {'questionIndex': 1, 'answerIndex': 0});
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('submitted answers', data: {
        'answerIndices': [2, 0]
      });

      l.expectLogged('showing correction dialog');
      l.expectLogged('turned to question', data: {'questionIndex': 0});
      expect(find.text('1 answer incorrect'), findsOneWidget);
      expect(find.text('Please correct your answers.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Is this a question?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Maybe'), findsOneWidget);
      await tester.tap(find.text('Yes'));
      l.expectLogged('started answer correction', data: {
        'questionIndicesToCorrect': [0]
      });
      l.expectLogged('selected answer',
          data: {'questionIndex': 0, 'answerIndex': 0});
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      l.expectLogged('submitted answers', data: {
        'answerIndices': [0, 0]
      });
      l.expectLogged('finished stage', data: {'type': 'QuestionsStage'});

      l.expectDoneLogging();
    });
  });

  group('Simon game', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'simon-game',
        {},
        logger,
        ({data, message}) {
          expect(data, {'maxCorrectItems': 3});
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      List<int> sequence;

      // 3 correct sequences
      for (var i = 0; i < 3; i++) {
        var loggedData = l.expectLogged('started watching');
        sequence = loggedData?['sequence'];
        await tester.pump(Duration(milliseconds: 500 + sequence.length * 800));
        l.expectLogged('finished watching');
        l.expectLogged('started repeating', data: {'sequence': sequence});
        for (var item in sequence) {
          expect(find.byIcon(Icons.thumb_up), findsNothing);
          expect(find.byIcon(Icons.thumb_down), findsNothing);
          var color = SimonGame.colors[item];
          await tester.tap(find.byKey(ValueKey(color)));
          await tester.pumpAndSettle();
        }
        l.expectLogged('finished repeating');
        l.expectLogged('started feedback', data: {'feedback': true});
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
        expect(find.byIcon(Icons.thumb_down), findsNothing);
        await tester.pump(const Duration(milliseconds: 1000));
        l.expectLogged('finished feedback');
      }

      // Incorrect 4th sequence
      var loggedData = l.expectLogged('started watching');
      sequence = loggedData?['sequence'].toList(); // copy
      await tester.tap(find.byKey(ValueKey(SimonGame.colors[0]))); // disabled
      await tester.pump(Duration(milliseconds: 500 + sequence.length * 800));
      l.expectLogged('finished watching');
      l.expectLogged('started repeating', data: {'sequence': sequence});
      // Inject incorrect item
      sequence[2]--;
      if (sequence[2] < 0) {
        sequence[2] = SimonGame.colors.length - 1;
      }
      for (var item in sequence.sublist(0, 3)) {
        expect(find.byIcon(Icons.thumb_up), findsNothing);
        expect(find.byIcon(Icons.thumb_down), findsNothing);
        var color = SimonGame.colors[item];
        await tester.tap(find.byKey(ValueKey(color)));
        await tester.pumpAndSettle();
      }
      l.expectLogged('finished repeating');
      l.expectLogged('started feedback', data: {'feedback': false});
      expect(find.byIcon(Icons.thumb_up), findsNothing);
      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      l.expectLogged('finished feedback');

      l.expectDoneLogging();
    });
  });

  group('Trail making', () {
    testWidgets('can be completed', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'trail-making',
        {
          'stimuli': ['1', '2', '3'],
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started task');
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.text('1'));
      l.expectLogged('tapped correct stimulus', data: {'stimulus': '1'});

      await tester.tap(find.text('3'));
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.pumpAndSettle();
      l.expectLogged('tapped incorrect stimulus', data: {'stimulus': '3'});
      l.expectLogged('started feedback');
      await tester.pump(const Duration(milliseconds: 500));
      l.expectLogged('finished feedback');

      await tester.tap(find.text('2'));
      l.expectLogged('tapped correct stimulus', data: {'stimulus': '2'});

      await tester.tap(find.text('3'));
      l.expectLogged('tapped correct stimulus', data: {'stimulus': '3'});

      l.expectDoneLogging();
    });

    testWidgets('supports distractors', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'trail-making',
        {
          'stimuli': ['1', '2', '3'],
          'colors': ['FFFFFF', '000000'],
          'nDistractors': 6,
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started task');
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text('2'), findsNWidgets(3));
      expect(find.text('3'), findsNWidgets(3));
    });

    testWidgets('supports custom grid size', (tester) async {
      var logger = TaskEventLogger();
      var l = LoggerTester(logger);

      await tester.pumpWidget(getTaskApp(
        'trail-making',
        {
          'stimuli': ['A', 'B', 'C', 'D'],
          'gridWidth': 2,
          'gridHeight': 2,
        },
        logger,
        ({data, message}) {
          expect(data, null);
          expect(message, null);
        },
      ));
      await tester.pumpAndSettle();

      l.expectLogged('started task');
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
    });
  });
}
