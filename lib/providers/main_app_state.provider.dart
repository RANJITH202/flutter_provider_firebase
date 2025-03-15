import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';

class MainAppState extends ChangeNotifier {
  static final MainAppState _instance = MainAppState._internal();

  factory MainAppState() {
    return _instance;
  }

  MainAppState._internal();
  late FlutterSecureStorage secureStorage;

  String _currentScreen = '';
  String get currentScreen => _currentScreen;
  set currentScreen(value) {
    if (value != null) {
      _currentScreen = value;
    }
  }

  String _tempCurrentScreen = '';
  String get tempCurrentScreen => _tempCurrentScreen;
  set tempCurrentScreen(value) {
    if (value != null) {
      _tempCurrentScreen = value;
    }
  }

  String _previousScreen = '';
  String get previousScreen => _previousScreen;
  set previousScreen(String _value) {
    _previousScreen = _value;
    secureStorage.setString('ff_previousScreen', _value);
  }
  void deletePreviousScreen() {
    secureStorage.delete(key: 'ff_previousScreen');
  }

  String _tempPreviousScreen = '';
  String get tempPreviousScreen => _tempPreviousScreen;
  set tempPreviousScreen(value) {
    if (value != null) {
      _tempPreviousScreen = value;
    }
  }

  //   Future<void> initializeForFirstTime() async {
  //   secureStorage = FlutterSecureStorage();

  //   _currrentUser.authToken = '';

  //   final prefs = await SharedPreferences.getInstance();

  //   if (prefs.getBool('first_run') ?? true) {
  //     await secureStorage.deleteAll();

  //     prefs.setBool('first_run', false);
  //   }

  //   _safeInit(() {
  //     if (prefs.containsKey('ff_userDetails')) {
  //       try {
  //         final serializedData = prefs.getString('ff_userDetails') ?? '{}';
  //         _userDetails = BLUserStructStruct.fromSerializableMap(
  //             jsonDecode(serializedData));
  //       } catch (e) {
  //         print("Can't decode persisted data type. Error: $e.");
  //       }
  //     }
  //   });


  //   await _safeInitAsync(() async {
  //     if (await secureStorage.read(key: 'ff_currrentUser') != null) {
  //       try {
  //         final serializedData =
  //             await secureStorage.getString('ff_currrentUser') ?? '{}';
  //         _currrentUser = CurrentUserModelStruct.fromSerializableMap(
  //             jsonDecode(serializedData));
  //       } catch (e) {
  //         print("Can't decode persisted data type. Error: $e.");
  //       }
  //     }
  //   });
  //   await _safeInitAsync(() async {
  //     _appConfigs =
  //         await secureStorage.getString('ff_appConfigs') ?? _appConfigs;
  //   });
  //   await _safeInitAsync(() async {
  //     _appUpdateStatus = await secureStorage.getString('ff_appUpdateStatus') ??
  //         _appUpdateStatus;
  //   });
  //   await _safeInitAsync(() async {
  //     _presentScreen =
  //         await secureStorage.getString('ff_presentScreen') ?? _presentScreen;
  //   });
  //   await _safeInitAsync(() async {
  //     _previousScreen =
  //         await secureStorage.getString('ff_previousScreen') ?? _previousScreen;
  //   });
  //       await _safeInitAsync(() async {
  //     _MfKYCVerifiedStatus =
  //         await secureStorage.getString('ff_MfKYCVerifiedStatus') ??
  //             _MfKYCVerifiedStatus;
  //   });
  //   await _safeInitAsync(() async {
  //     if (await secureStorage.read(key: 'ff_products') != null) {
  //       try {
  //         final serializedData =
  //             await secureStorage.getString('ff_products') ?? '{}';
  //         _products =
  //             ProductsStruct.fromSerializableMap(jsonDecode(serializedData));
  //       } catch (e) {
  //         print("Can't decode persisted data type. Error: $e.");
  //       }
  //     }
  //   });
  // }


  void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);

  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';

  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');

  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');

  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return const CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });

  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: const ListToCsvConverter().convert([value]));
}