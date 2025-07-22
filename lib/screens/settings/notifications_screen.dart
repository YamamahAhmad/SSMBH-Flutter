import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project1/providers/settings_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer للاستماع للتغييرات في SettingsProvider
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications Settings'),
            backgroundColor: Colors.blueAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Receive All Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    settingsProvider.areNotificationsEnabled
                        ? 'You will receive alerts for theft, humidity, etc.'
                        : 'All notifications are currently turned off.',
                  ),
                  value: settingsProvider.areNotificationsEnabled,
                  onChanged: (bool value) {
                    // عند تغيير المفتاح، نقوم بتحديث الحالة عبر الـ Provider
                    settingsProvider.toggleNotifications(value);
                  },
                  activeColor: Colors.blueAccent,
                ),
                const Divider(),
                // يمكنك إضافة أي إعدادات أخرى هنا إذا أردت في المستقبل
              ],
            ),
          ),
        );
      },
    );
  }
}