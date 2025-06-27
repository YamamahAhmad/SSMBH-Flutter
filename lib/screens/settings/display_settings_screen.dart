import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/settings_manager.dart';

class DisplaySettingsScreen extends StatefulWidget {
  const DisplaySettingsScreen({
    super.key,
  });
  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  late bool _isDarkModeEnabled;

  @override
  void initState() {
    super.initState();
    _isDarkModeEnabled = SettingsManager.isDarkModeEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Display',
        ),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            secondary: const Icon(
              Icons.brightness_6_outlined,
            ),
            title: const Text(
              'Dark Mode',
            ),
            value: _isDarkModeEnabled,
            onChanged: (bool value) {
              SettingsManager.setDarkMode(
                value,
              );
              setState(
                    () => _isDarkModeEnabled = value,
              );
              MyApp.of(context)?.refreshTheme();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}