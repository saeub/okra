import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';

import 'api.dart';
import 'tutorial.dart';

class IncompatibleStorageError implements Exception {
  final String key;
  final dynamic value;

  IncompatibleStorageError(this.key, this.value);

  @override
  String toString() {
    return 'Storage key "$key" has incompatible value: $value';
  }
}

class Storage extends ChangeNotifier {
  static const storageName = 'storage';
  static const apisKey = 'apis';
  static const tutorialKey = 'tutorial';
  static const showCompletedKey = 'showCompleted';

  late List<WebApi> _webApis;
  late TutorialApi _tutorialApi;
  late bool _showCompleted;

  Storage._init() {
    List<dynamic> apiJsons = jsonDecode(localStorage.getItem(apisKey) ?? '[]');
    try {
      _webApis =
          apiJsons.cast<Map<String, dynamic>>().map(WebApi.fromJson).toList();
    } on TypeError {
      throw IncompatibleStorageError(apisKey, apiJsons);
    } on NoSuchMethodError {
      throw IncompatibleStorageError(apisKey, apiJsons);
    }
    Map<String, dynamic> tutorialJson =
        jsonDecode(localStorage.getItem(tutorialKey) ?? 'null') ??
            TutorialApi(this).toJson();
    try {
      _tutorialApi = TutorialApi.fromJson(tutorialJson, this);
    } on TypeError {
      throw IncompatibleStorageError(tutorialKey, tutorialJson);
    }
    _showCompleted =
        jsonDecode(localStorage.getItem(showCompletedKey) ?? 'false');
  }

  List<WebApi> get webApis => _webApis;
  TutorialApi get tutorialApi => _tutorialApi;
  bool get showCompleted => _showCompleted;

  static Future<Storage> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initLocalStorage();
    return Storage._init();
  }

  void addWebApi(WebApi api) {
    _webApis.add(api);
    localStorage.setItem(
        apisKey, jsonEncode(_webApis.map((api) => api.toJson()).toList()));
    notifyListeners();
  }

  void removeWebApi(WebApi api) {
    _webApis.remove(api);
    localStorage.setItem(
        apisKey, jsonEncode(_webApis.map((api) => api.toJson()).toList()));
    notifyListeners();
  }

  void resetTutorial() {
    _tutorialApi.resetProgress();
    localStorage.setItem(tutorialKey, jsonEncode(_tutorialApi.toJson()));
    notifyListeners();
  }

  void saveTutorial() {
    localStorage.setItem(tutorialKey, jsonEncode(_tutorialApi.toJson()));
    notifyListeners();
  }

  void setShowCompleted(bool value) {
    _showCompleted = value;
    localStorage.setItem(showCompletedKey, jsonEncode(_showCompleted));
    notifyListeners();
  }
}
