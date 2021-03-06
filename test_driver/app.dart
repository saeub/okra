import 'dart:convert';

import 'package:flutter_driver/driver_extension.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:okra/main.dart' as app;
import 'package:okra/src/data/api.dart' as api;

class MockClient extends Mock implements http.Client {}

void main() async {
  enableFlutterDriverExtension();

  // Mock HTTP client
  api.client = MockClient();
  when(api.client.post(
    any,
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((invocation) async {
    if (!Uri.tryParse(invocation.positionalArguments[0]).isAbsolute) {
      throw FormatException();
    }
    return http.Response('', 404);
  });
  when(api.client.post(
    'https://mock.api/register',
    headers: anyNamed('headers'),
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response('', 401));
  when(api.client.post(
    'https://mock.api/register',
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'participantId': 'mock_participant',
      'registrationKey': 'mock_key',
    }),
  )).thenAnswer((_) async => http.Response(
      jsonEncode({
        'name': 'Mock API',
        'participantId': 'mock_participant',
        'deviceKey': 'mock_key'
      }),
      200));
  when(api.client.get(
    'https://mock.api/experiments',
    headers: {
      'Content-Type': 'application/json',
      'X-Participant-ID': 'mock_participant',
      'X-Device-Key': 'mock_key',
    },
  )).thenAnswer((_) async => http.Response(
      jsonEncode({
        'experiments': [
          {
            'id': 'mock_experiment',
            'type': 'question-answering',
            'title': 'Mock experiment',
            'instructions': 'Mock instructions',
            'nTasks': 3,
            'nTasksDone': 1
          }
        ]
      }),
      200));
  when(api.client.get(
    'https://mock.api/experiments/mock_experiment',
    headers: {
      'Content-Type': 'application/json',
      'X-Participant-ID': 'mock_participant',
      'X-Device-Key': 'mock_key',
    },
  )).thenAnswer((_) async => http.Response(
      jsonEncode({
        'id': 'mock_experiment',
        'type': 'question-answering',
        'title': 'Mock experiment',
        'instructions': 'Mock instructions',
        'nTasks': 3,
        'nTasksDone': 1
      }),
      200));
  when(api.client.post(
    'https://mock.api/experiments/mock_experiment/start',
    headers: {
      'Content-Type': 'application/json',
      'X-Participant-ID': 'mock_participant',
      'X-Device-Key': 'mock_key',
    },
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(
      jsonEncode({
        'id': 'mock_task',
        'data': {
          'text': '# Title\nThis is a test task.',
          'readingType': 'normal',
          'questions': [
            {
              'question': 'What was this?',
              'answers': ['A test task', 'Not a test task', 'A grapefruit'],
            },
            {
              'question': "What's this now?",
              'answers': ['A question', 'An apple'],
            },
          ],
        },
      }),
      200));
  when(api.client.post(
    'https://mock.api/tasks/mock_task/finish',
    headers: {
      'Content-Type': 'application/json',
      'X-Participant-ID': 'mock_participant',
      'X-Device-Key': 'mock_key',
    },
    body: anyNamed('body'),
  )).thenAnswer((_) async => http.Response(jsonEncode({}), 200));

  app.main();
}
