import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../beehive/beehives_list_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
  });

  Future<void> _saveTokenToDatabase(User user) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    final userRef = FirebaseDatabase.instance.ref(
      'users/${user.uid}',
    );
    await userRef.update(
      {
        'fcmToken': token,
        'lastUpdated': ServerValue.timestamp,
      },
    );
    if (kDebugMode) {
      print(
        "--- FCM Token for user ${user.uid} saved to Database. ---",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          _saveTokenToDatabase(
            snapshot.data!,
          );
          return const BeehivesListScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}