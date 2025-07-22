import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true; // القيمة الافتراضية هي تفعيل الإشعارات

  bool get areNotificationsEnabled => _notificationsEnabled;

  static const String _notificationsKey = 'notifications_enabled';

  SettingsProvider() {
    _loadSettings();
  }

  // تحميل الإعدادات المحفوظة عند بدء التشغيل
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // إذا لم تكن هناك قيمة محفوظة، استخدم القيمة الافتراضية (true)
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  // تبديل حالة الإشعارات وحفظها
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, _notificationsEnabled);
    notifyListeners();
    print("Notifications status set to: $_notificationsEnabled");
  }
}