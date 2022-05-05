import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../generated/l10n.dart';
import '../util.dart';
import 'models.dart';

abstract class Api {
  String getName();

  Image? getIcon();

  Future<List<Experiment>> getExperiments();

  Future<Experiment> getExperiment(String experimentId);

  Future<TaskData> startTask(String experimentId, {bool practice = false});

  Future<void> finishTask(String taskId, TaskResults results);
}

/// Global variable to allow mocking responses in tests
http.Client client = http.Client();

class WebApi extends Api {
  final String name;
  final String? iconUrl;
  final String baseUrl;
  final String participantId;
  final String deviceKey;
  final DateTime added;
  final String _storageKey;

  WebApi(this.name, this.iconUrl, this.baseUrl, this.participantId,
      this.deviceKey, this.added,
      [String? storageKey])
      : _storageKey = storageKey ?? _randomStorageKey();

  static String _randomStorageKey() {
    var random = Random();
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_';
    return List<String>.generate(
        16, (index) => chars[random.nextInt(chars.length)]).join();
  }

  static WebApi fromJson(Map<String, dynamic> json) {
    return WebApi(
      json['name'],
      json['iconUrl'],
      json['baseUrl'],
      json['participantId'],
      json['deviceKey'],
      DateTime.parse(json['added']),
      json['storageKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'baseUrl': baseUrl,
      'participantId': participantId,
      'deviceKey': deviceKey,
      'added': added.toIso8601String(),
      'storageKey': _storageKey,
    };
  }

  static Future<WebApi> register(
      String baseUrl, String participantId, String registrationKey) async {
    http.Response response;
    try {
      response = await client
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'participantId': participantId,
              'registrationKey': registrationKey,
            }),
          )
          .timeout(Duration(seconds: 30));
    } on ArgumentError {
      throw ApiError(message: (s) => s.apiErrorInvalidUrl);
    } on FormatException {
      throw ApiError(message: (s) => s.apiErrorInvalidUrl);
    } on TimeoutException {
      throw ApiError(message: (s) => s.apiErrorTimeout, retriable: true);
    } on SocketException {
      throw ApiError(
          message: (s) => s.apiErrorConnectionFailed, retriable: true);
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['participantId'] == null || data['deviceKey'] == null) {
        throw ApiError(
          message: (s) => s.apiErrorInvalidResponse,
        );
      }
      return WebApi(
        data['name'],
        data['iconUrl'],
        baseUrl,
        data['participantId'],
        data['deviceKey'],
        DateTime.now(),
      );
    } else if (response.statusCode == 401) {
      throw ApiError(
        message: (s) => s.apiErrorInvalidCredentials,
        statusCode: response.statusCode,
      );
    } else {
      throw ApiError(statusCode: response.statusCode);
    }
  }

  @override
  String getName() => name;

  @override
  Image? getIcon() {
    var iconUrl = this.iconUrl;
    return iconUrl != null ? Image.network(iconUrl) : null;
  }

  @override
  Future<List<Experiment>> getExperiments() async {
    List<dynamic> data = (await get('experiments'))['experiments'];
    return data.map((d) => Experiment.fromJson(this, d)).toList();
  }

  @override
  Future<Experiment> getExperiment(String experimentId) async {
    Map<String, dynamic> data = await get('experiments/$experimentId');
    return Experiment.fromJson(this, data);
  }

  @override
  Future<TaskData> startTask(String experimentId,
      {bool practice = false}) async {
    Map<String, dynamic> data =
        await post('experiments/$experimentId/start?practice=$practice');
    return TaskData.fromJson(data);
  }

  @override
  Future<void> finishTask(String taskId, TaskResults results) async {
    await post('tasks/$taskId/finish', data: results.toJson());
  }

  Future<dynamic> get(String route, {int timeout = 30}) async {
    var url = '$baseUrl/$route';
    http.Response response;
    try {
      response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Participant-ID': participantId,
          'X-Device-Key': deviceKey,
        },
      ).timeout(Duration(seconds: timeout));
    } on TimeoutException {
      throw ApiError(message: (s) => s.apiErrorTimeout, retriable: true);
    } on SocketException {
      throw ApiError(
          message: (s) => s.apiErrorConnectionFailed, retriable: true);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiError(
        statusCode: response.statusCode,
      );
    }
  }

  Future<dynamic> post(String route,
      {Map<String, dynamic> data = const {}, int timeout = 30}) async {
    var url = '$baseUrl/$route';
    http.Response response;
    try {
      response = await client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'X-Participant-ID': participantId,
              'X-Device-Key': deviceKey,
            },
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeout));
    } on TimeoutException {
      throw ApiError(message: (s) => s.apiErrorTimeout, retriable: true);
    } on SocketException {
      throw ApiError(
          message: (s) => s.apiErrorConnectionFailed, retriable: true);
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiError(
        statusCode: response.statusCode,
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is WebApi) {
      return _storageKey == other._storageKey;
    }
    return false;
  }

  @override
  int get hashCode => _storageKey.hashCode;
}

class ApiError implements Exception {
  final Translatable message;
  final int statusCode;
  final bool retriable;

  ApiError({Translatable? message, this.statusCode = 0, this.retriable = false})
      : message = message ?? ((s) => s.apiErrorGeneric(statusCode));

  @override
  String toString() {
    return message(S.current);
  }
}
