// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageKeys {
  static const INSTANCE_ID = 'instanceId';
  static const CURRENT_SCREEN_NAME = 'currentScreenName';
  static const PREVIOUS_SCREEN_NAME = 'previousScreenName';
}

class LocalStorage {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static String getString(String key, [String defValue = ""]) {
    return _prefsInstance?.getString(key) ?? defValue;
  }

  static Future<bool> setString(
      {required String key, required String value}) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }

  //? ADD DATA TO LOCAL STORAGE
  static Future<void> saveLocalInstanceId({required String instranceID}) async {
    LocalStorage.setString(
        key: LocalStorageKeys.INSTANCE_ID, value: instranceID);
  }

  static Future<void> saveCurrentScreenName(
      {required String currentScreenName}) async {
    LocalStorage.setString(
        key: LocalStorageKeys.CURRENT_SCREEN_NAME, value: currentScreenName);
  }

  static Future<void> savePreviousScreenName(
      {required String previousScreenName}) async {
    LocalStorage.setString(
        key: LocalStorageKeys.PREVIOUS_SCREEN_NAME, value: previousScreenName);
  }
   static Future<String> readLocalInstanceId() async {
    return LocalStorage.getString(LocalStorageKeys.INSTANCE_ID);
  }

  //? READ DATA FROM LOCAL STORAGE
  static final GET_INSTANCE_ID =
      LocalStorage.getString(LocalStorageKeys.INSTANCE_ID);

  static final GET_PREVIOUS_SCREEN_NAME =
      LocalStorage.getString(LocalStorageKeys.PREVIOUS_SCREEN_NAME);

  static final GET_CURRENT_SCREEN_NAME =
      LocalStorage.getString(LocalStorageKeys.CURRENT_SCREEN_NAME);
}
