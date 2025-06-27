import 'package:flutter/material.dart';

import 'account_security_settings_screen.dart';
import 'display_settings_screen.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: ListView(
        children: <Widget>[
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Account & Security',
            subtitle: 'Password, app lock',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountSecuritySettingsScreen(),
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            subtitle: 'Manage alert preferences',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            ),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.display_settings_outlined,
            title: 'Display',
            subtitle: 'Dark mode',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DisplaySettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        VoidCallback? onTap,
      }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).listTileTheme.iconColor,
          ),
          title: Text(
            title,
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.7) ??
                  Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).listTileTheme.iconColor,
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}