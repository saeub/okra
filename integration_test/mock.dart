import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:okra/src/data/api.dart' as api;

void mockApiClient() {
  bool authorized(http.Request request) {
    return request.headers['X-Participant-ID'] == 'mock_participant' &&
        request.headers['X-Device-Key'] == 'mock_key';
  }

  var client = http.MockClient((request) async {
    // POST /register
    if (request.method == 'POST' &&
        request.url == Uri.parse('https://mock.api/register')) {
      if (request.body ==
          jsonEncode({
            'participantId': 'mock_participant',
            'registrationKey': 'mock_key',
          })) {
        return http.Response(
            jsonEncode({
              'name': 'Mock API',
              'participantId': 'mock_participant',
              'deviceKey': 'mock_key'
            }),
            200);
      }
      return http.Response('', 401);
    }

    // GET /experiments
    if (request.method == 'GET' &&
        request.url == Uri.parse('https://mock.api/experiments')) {
      if (!authorized(request)) {
        return http.Response('', 401);
      }
      return http.Response(
          jsonEncode({
            'experiments': [
              {
                'id': 'mock_experiment',
                'type': 'cloze',
                'title': 'Mock experiment',
                'instructions': 'Mock instructions',
                'nTasks': 3,
                'nTasksDone': 1,
                'hasPracticeTask': false,
              }
            ]
          }),
          200);
    }

    // GET /experiments/mock_experiment
    if (request.method == 'GET' &&
        request.url ==
            Uri.parse('https://mock.api/experiments/mock_experiment')) {
      if (!authorized(request)) {
        return http.Response('', 401);
      }
      return http.Response(
          jsonEncode({
            'id': 'mock_experiment',
            'type': 'cloze',
            'title': 'Mock experiment',
            'instructions': 'Mock instructions',
            'nTasks': 3,
            'nTasksDone': 1,
            'hasPracticeTask': false,
          }),
          200);
    }

    // POST /experiments/mock_experiment/start
    if (request.method == 'POST' &&
        request.url ==
            Uri.parse(
                'https://mock.api/experiments/mock_experiment/start?practice=false')) {
      if (!authorized(request)) {
        return http.Response('', 401);
      }
      return http.Response(
          jsonEncode({
            'id': 'mock_task',
            'data': {
              'segments': [
                {
                  'text': 'This is an .',
                  'blankPosition': 11,
                  'options': ['example', 'text', 'pineapple'],
                  'correctOptionIndex': 0
                },
              ],
            },
          }),
          200);
    }

    // POST /tasks/mock_task/finish
    if (request.method == 'POST' &&
        request.url ==
            Uri.parse('https://mock.api/tasks/mock_task/finish')) {
      if (!authorized(request)) {
        return http.Response('', 401);
      }
      return http.Response(jsonEncode({}), 200);
    }

    // Not found
    return http.Response('', 404);
  });

  api.client = client;
}
