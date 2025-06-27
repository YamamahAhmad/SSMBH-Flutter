import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences _prefs;
  static const String _darkModeKey = 'darkMode';
  static const String _appLockEnabledKey = 'appLockEnabled';
  static const String _appLockTimeoutKey = 'appLockTimeout';
  static const String _notifyLidOpenKey = 'notifyLidOpen';
  static const String _notifyVibrationKey = 'notifyVibration';
  static const String _notifyLowBatteryKey = 'notifyLowBattery';
  static const String _notifyConnectionLostKey = 'notifyConnectionLost';

  static Future<void> initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static bool isDarkModeEnabled() =>
      _prefs.getBool(
        _darkModeKey,
      ) ??
          false;
  static bool isAppLockEnabled() =>
      _prefs.getBool(
        _appLockEnabledKey,
      ) ??
          false;
  static String getAppLockTimeout() =>
      _prefs.getString(
        _appLockTimeoutKey,
      ) ??
          '1 minute';
  static bool notifyOnLidOpen() =>
      _prefs.getBool(
        _notifyLidOpenKey,
      ) ??
          true;
  static bool notifyOnVibration() =>
      _prefs.getBool(
        _notifyVibrationKey,
      ) ??
          true;
  static bool notifyOnLowBattery() =>
      _prefs.getBool(
        _notifyLowBatteryKey,
      ) ??
          true;
  static bool notifyOnConnectionLost() =>
      _prefs.getBool(
        _notifyConnectionLostKey,
      ) ??
          true;
  static Future<void> setDarkMode(bool v) => _prefs.setBool(
    _darkModeKey,
    v,
  );
  static Future<void> setAppLockEnabled(bool v) => _prefs.setBool(
    _appLockEnabledKey,
    v,
  );
  static Future<void> setAppLockTimeout(String v) => _prefs.setString(
    _appLockTimeoutKey,
    v,
  );
  static Future<void> setNotifyOnLidOpen(bool v) => _prefs.setBool(
    _notifyLidOpenKey,
    v,
  );
  static Future<void> setNotifyOnVibration(bool v) => _prefs.setBool(
    _notifyVibrationKey,
    v,
  );
  static Future<void> setNotifyOnLowBattery(bool v) => _prefs.setBool(
    _notifyLowBatteryKey,
    v,
  );
  static Future<void> setNotifyOnConnectionLost(bool v) => _prefs.setBool(
    _notifyConnectionLostKey,
    v,
  );
}