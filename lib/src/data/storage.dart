import 'package:flutter/foundation.dart';
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

  final LocalStorage storage;
  late List<WebApi> _webApis;
  late TutorialApi _tutorialApi;
  late bool _showCompleted;

  Storage(this.storage) {
    List<dynamic> apiJsons = storage.getItem(apisKey) ?? [];
    try {
      _webApis =
          apiJsons.cast<Map<String, dynamic>>().map(WebApi.fromJson).toList();
    } on TypeError {
      throw IncompatibleStorageError(apisKey, apiJsons);
    } on NoSuchMethodError {
      throw IncompatibleStorageError(apisKey, apiJsons);
    }
    Map<String, dynamic> tutorialJson =
        storage.getItem(tutorialKey) ?? TutorialApi(this).toJson();
    try {
      _tutorialApi = TutorialApi.fromJson(tutorialJson, this);
    } on TypeError {
      throw IncompatibleStorageError(tutorialKey, tutorialJson);
    }
    _showCompleted = storage.getItem(showCompletedKey) ?? false;
  }

  List<WebApi> get webApis => _webApis;
  TutorialApi get tutorialApi => _tutorialApi;
  bool get showCompleted => _showCompleted;

  static Future<LocalStorage> loadLocalStorage() async {
    var storage = LocalStorage(storageName);
    var ready = await storage.ready;
    if (ready) {
      return storage;
    } else {
      throw 'Storage not ready';
    }
  }

  void addWebApi(WebApi api) {
    _webApis.add(api);
    storage.setItem(apisKey, _webApis.map((api) => api.toJson()).toList());
    notifyListeners();
  }

  void removeWebApi(WebApi api) {
    _webApis.remove(api);
    storage.setItem(apisKey, _webApis.map((api) => api.toJson()).toList());
    notifyListeners();
  }

  void resetTutorial() {
    _tutorialApi.resetProgress();
    storage.setItem(tutorialKey, _tutorialApi.toJson());
    notifyListeners();
  }

  void saveTutorial() {
    storage.setItem(tutorialKey, _tutorialApi.toJson());
    notifyListeners();
  }

  void setShowCompleted(bool value) {
    _showCompleted = value;
    storage.setItem(showCompletedKey, _showCompleted);
    notifyListeners();
  }
}
