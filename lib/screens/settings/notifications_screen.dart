import 'package:flutter/material.dart';

import '../../services/settings_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _notificationStates = {};

  @override
  void initState() {
    super.initState();
    _notificationStates['lidOpen'] = SettingsManager.notifyOnLidOpen();
    _notificationStates['vibration'] = SettingsManager.notifyOnVibration();
    _notificationStates['lowBattery'] = SettingsManager.notifyOnLowBattery();
    _notificationStates['connectionLost'] =
        SettingsManager.notifyOnConnectionLost();
  }

  void _updateNotificationSetting(String key, bool value) {
    setState(
          () => _notificationStates[key] = value,
    );
    switch (key) {
      case 'lidOpen':
        SettingsManager.setNotifyOnLidOpen(
          value,
        );
        break;
      case 'vibration':
        SettingsManager.setNotifyOnVibration(
          value,
        );
        break;
      case 'lowBattery':
        SettingsManager.setNotifyOnLowBattery(
          value,
        );
        break;
      case 'connectionLost':
        SettingsManager.setNotifyOnConnectionLost(
          value,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
        ),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            secondary: const Icon(
              Icons.door_sliding_outlined,
            ),
            title: const Text(
              'Lid Open Alert',
            ),
            subtitle: const Text(
              'Notify when beehive lid is opened',
            ),
            value: _notificationStates['lidOpen']!,
            onChanged: (v) => _updateNotificationSetting(
              'lidOpen',
              v,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(
              Icons.vibration_outlined,
            ),
            title: const Text(
              'Vibration Alert',
            ),
            subtitle: const Text(
              'Notify on beehive vibration or disturbance',
            ),
            value: _notificationStates['vibration']!,
            onChanged: (v) => _updateNotificationSetting(
              'vibration',
              v,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(
              Icons.battery_alert_outlined,
            ),
            title: const Text(
              'Low Battery Alert',
            ),
            subtitle: const Text(
              'Notify when device battery is low',
            ),
            value: _notificationStates['lowBattery']!,
            onChanged: (v) => _updateNotificationSetting(
              'lowBattery',
              v,
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(
              Icons.signal_wifi_off_outlined,
            ),
            title: const Text(
              'Connection Lost Alert',
            ),
            subtitle: const Text(
              'Notify if beehive loses internet connection',
            ),
            value: _notificationStates['connectionLost']!,
            onChanged: (v) => _updateNotificationSetting(
              'connectionLost',
              v,
            ),
          ),
        ],
      ),
    );
  }
}