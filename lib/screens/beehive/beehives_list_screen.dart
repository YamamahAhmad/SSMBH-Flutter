import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/beehive.dart';
import '../../services/notification_service.dart';
import '../../services/settings_manager.dart';
import '../../utils/app_constants.dart';
import '../settings/settings_screen.dart';
import 'add_beehive_screen.dart';
import 'beehive_detail_screen.dart';
import 'manage_beehives_screen.dart';

class BeehivesListScreen extends StatefulWidget {
  const BeehivesListScreen({
    super.key,
  });
  @override
  State<BeehivesListScreen> createState() => _BeehivesListScreenState();
}

class _BeehivesListScreenState extends State<BeehivesListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final Set<String> _notifiedHiveIds = {};

  void _checkForAlertsAndNotify(List<Beehive> beehives) {
    for (final hive in beehives) {
      final bool hasActiveAlert = hive.alert;
      final bool alreadyNotified = _notifiedHiveIds.contains(
        hive.id,
      );

      if (hasActiveAlert && !alreadyNotified) {
        _sendNotificationForHive(
          hive,
        );
        _notifiedHiveIds.add(
          hive.id,
        );
      } else if (!hasActiveAlert && alreadyNotified) {
        _notifiedHiveIds.remove(
          hive.id,
        );
      }
    }
  }

  void _sendNotificationForHive(Beehive hive) {
    bool shouldNotify = false;
    String reason = hive.reason.toLowerCase();
    if (reason.contains('lid') || reason.contains('door')) {
      shouldNotify = SettingsManager.notifyOnLidOpen();
    } else if (reason.contains('vibration')) {
      shouldNotify = SettingsManager.notifyOnVibration();
    } else if (reason.contains('battery')) {
      shouldNotify = SettingsManager.notifyOnLowBattery();
    } else if (reason.contains('connection')) {
      shouldNotify = SettingsManager.notifyOnConnectionLost();
    } else {
      shouldNotify = true;
    }

    if (shouldNotify) {
      NotificationService.showLocalNotification(
        id: hive.id.hashCode,
        title: '🐝 Alert for ${hive.name}',
        body: 'Reason: ${hive.reason}',
      );
    }
  }

  void _navigateToDetail(BuildContext context, Beehive beehive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BeehiveDetailScreen(
          beehive: beehive,
        ),
      ),
    );
  }

  void _refreshAppTheme() => MyApp.of(context)?.refreshTheme();
  Future<void> _logout() async => await FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref(
      'beehives',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BEEHIVE MONITOR',
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bug_report,
                    size: 40,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Beehive Monitor',
                    style: Theme.of(context)
                        .appBarTheme
                        .titleTextStyle
                        ?.copyWith(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? 'Menu',
                    style: TextStyle(
                      color: (Theme.of(context)
                          .appBarTheme
                          .titleTextStyle
                          ?.color ??
                          darkTextColor)
                          .withOpacity(
                        0.7,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
              ),
              title: const Text(
                'Add New Beehive',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBeehiveScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.edit_location_alt_outlined,
              ),
              title: const Text(
                'Manage Beehives',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageBeehivesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
              ),
              title: const Text(
                'Settings',
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                ).then(
                      (_) => _refreshAppTheme(),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Logout',
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream:
        dbRef.orderByChild('info/userId').equalTo(currentUser?.uid).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'No beehives found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Add a new beehive from the side menu.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final beehives =
          Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map)
              .entries
              .map(
                (e) => Beehive.fromRtdb(
              snapshot.data!.snapshot.child(
                e.key,
              ),
            ),
          )
              .toList();

          _checkForAlertsAndNotify(
            beehives,
          );

          return ListView.builder(
            itemCount: beehives.length,
            itemBuilder: (ctx, index) {
              final beehive = beehives[index];
              final alertColor =
              beehive.alert ? Colors.red.shade400 : Colors.orange;
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(
                    beehive.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    'Temp: ${beehive.temperature.toStringAsFixed(1)}°C, Hum: ${beehive.humidity.toStringAsFixed(1)}%, Door: ${beehive.isDoorOpen ? "Open" : "Closed"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: alertColor.withOpacity(
                      0.2,
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: alertColor,
                      size: 28,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${beehive.currentWeight.toStringAsFixed(1)} Kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        width: 70,
                        child: LinearProgressIndicator(
                          value:
                          beehive.currentWeight / beehive.maxWeightCapacity,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            alertColor,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(
                            3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToDetail(
                    context,
                    beehive,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}