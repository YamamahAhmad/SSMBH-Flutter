import 'package:flutter/material.dart';
import 'package:project1/services/settings_manager.dart';

import 'change_password_screen.dart';

class AccountSecuritySettingsScreen extends StatelessWidget {
  const AccountSecuritySettingsScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account & Security',
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(
              Icons.lock_outline,
            ),
            title: const Text(
              'Change Password',
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const AppLockOptions(),
        ],
      ),
    );
  }
}

class AppLockOptions extends StatefulWidget {
  const AppLockOptions({
    super.key,
  });
  @override
  State<AppLockOptions> createState() => _AppLockOptionsState();
}

class _AppLockOptionsState extends State<AppLockOptions> {
  late bool _appLockEnabled;
  late String _appLockTimeout;

  @override
  void initState() {
    super.initState();
    _appLockEnabled = SettingsManager.isAppLockEnabled();
    _appLockTimeout = SettingsManager.getAppLockTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(
            Icons.timer_off_outlined,
          ),
          title: const Text(
            'App Lock',
          ),
          subtitle: _appLockEnabled
              ? Text(
            'Lock app after $_appLockTimeout of inactivity',
          )
              : const Text(
            'Disabled',
          ),
          value: _appLockEnabled,
          onChanged: (bool value) {
            SettingsManager.setAppLockEnabled(
              value,
            );
            setState(
                  () => _appLockEnabled = value,
            );
          },
        ),
        if (_appLockEnabled)
          ListTile(
            contentPadding: const EdgeInsets.only(
              left: 72.0,
              right: 16.0,
            ),
            title: const Text(
              'App Lock Timeout',
            ),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _appLockTimeout,
                items: <String>[
                  '30 seconds',
                  '1 minute',
                  '5 minutes',
                  '15 minutes'
                ]
                    .map(
                      (String v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(
                      v,
                    ),
                  ),
                )
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    SettingsManager.setAppLockTimeout(
                      newValue,
                    );
                    setState(
                          () => _appLockTimeout = newValue,
                    );
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}