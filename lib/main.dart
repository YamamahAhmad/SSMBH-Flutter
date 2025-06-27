import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'services/notification_service.dart';
import 'services/settings_manager.dart';
import 'utils/app_constants.dart';

// ===================================================================
// إعدادات الإشعارات في الخلفية (يجب أن تكون هنا في ملف main.dart)
// ===================================================================
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print(
      "--- Handling a background message: ${message.messageId}",
    );
  }
}

// ===================================================================
// MAIN FUNCTION & APP SETUP
// ===================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await SettingsManager.initialize();
  await NotificationService.initialize();
  await _requestFcmPermission();

  FirebaseMessaging.instance.getToken().then(
        (token) {
      if (kDebugMode) {
        print(
          "==========================================",
        );
        print(
          "FCM Token: $token",
        );
        print(
          "==========================================",
        );
      }
    },
  );

  FirebaseDatabase.instance.databaseURL =
  "https://fir-be497-default-rtdb.europe-west1.firebasedatabase.app";

  runApp(
    const MyApp(),
  );
}

Future<void> _requestFcmPermission() async {
  NotificationSettings settings =
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print(
      '>>> User notification permission: ${settings.authorizationStatus}',
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late bool _isDarkMode;
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    _isDarkMode = SettingsManager.isDarkModeEnabled();
    WidgetsBinding.instance.addObserver(
      this,
    );
    _setupFirebaseMessagingListeners();
  }

  void _setupFirebaseMessagingListeners() {
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        if (kDebugMode) {
          print(
            '--- Got a message whilst in the foreground!',
          );
        }
        RemoteNotification? notification = message.notification;
        if (notification != null && message.notification?.android != null) {
          NotificationService.showLocalNotification(
            id: notification.hashCode,
            title: notification.title ?? 'No Title',
            body: notification.body ?? 'No Body',
          );
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        if (kDebugMode) {
          print(
            '--- A new onMessageOpenedApp event was published!',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(
      state,
    );
    if (FirebaseAuth.instance.currentUser == null ||
        !SettingsManager.isAppLockEnabled()) return;

    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedTime != null) {
      final timeoutDuration =
      _parseDuration(SettingsManager.getAppLockTimeout());
      if (DateTime.now().difference(_pausedTime!) > timeoutDuration) {
        await FirebaseAuth.instance.signOut();
        navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const AuthGate(),
            ),
                (route) => false);
      }
      _pausedTime = null;
    }
  }

  Duration _parseDuration(String timeout) {
    if (timeout.contains('seconds')) {
      return Duration(
        seconds: int.parse(
          timeout.split(' ').first,
        ),
      );
    }
    return Duration(
      minutes: int.parse(
        timeout.split(' ').first,
      ),
    );
  }

  void refreshTheme() =>
      setState(() => _isDarkMode = SettingsManager.isDarkModeEnabled());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Beehive Monitor',
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: BorderSide(
            color: primaryYellow.withOpacity(
              0.7,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: BorderSide(
            color: primaryYellow.withOpacity(
              0.7,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: const BorderSide(
            color: buttonOrange,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: darkTextColor,
        ),
        prefixIconColor: buttonOrange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        elevation: 0,
        iconTheme: IconThemeData(
          color: darkTextColor,
        ),
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        centerTitle: true,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ),
      iconTheme: const IconThemeData(
        color: darkTextColor,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkTextColor,
        textColor: darkTextColor,
      ),
      dividerColor: Colors.grey[300],
      cardColor: Colors.white,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (states) =>
          states.contains(MaterialState.selected) ? buttonOrange : null,
        ),
        trackColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.selected)
              ? buttonOrange.withOpacity(
            0.5,
          )
              : null,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: primaryYellow,
      colorScheme: ColorScheme.dark(
        primary: primaryYellow,
        secondary: buttonOrange,
        onPrimary: darkTextColor,
        onSecondary: Colors.white,
        surface: Colors.grey[850]!,
        background: const Color(
          0xFF121212,
        ),
      ),
      scaffoldBackgroundColor: const Color(
        0xFF121212,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 15,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              30,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: BorderSide(
            color: primaryYellow.withOpacity(
              0.7,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: BorderSide(
            color: primaryYellow.withOpacity(
              0.7,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
          borderSide: const BorderSide(
            color: buttonOrange,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: Colors.white70,
        ),
        prefixIconColor: buttonOrange,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Colors.grey[850],
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),
      dividerColor: Colors.grey[700],
      cardColor: Colors.grey[850],
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.selected)
              ? buttonOrange
              : Colors.grey[600],
        ),
        trackColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.selected)
              ? buttonOrange.withOpacity(
            0.5,
          )
              : Colors.grey[800],
        ),
      ),
    );
  }
}