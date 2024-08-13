import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'loadscreen.dart';
import 'data.dart';
import 'home.dart';
import 'signup.dart';
import 'login.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  await initializeFirebase();
  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    // Determine the Android version
    final int androidVersion = int.parse(Platform.version.split('.')[0]);

    if (androidVersion >= 34) {
      // Request permissions for Android 14 and higher
      final List<Permission> permissions = [
        Permission.photos,
        Permission.videos,
      ];

      final Map<Permission, PermissionStatus> statuses = await permissions.request();
      if (statuses.values.any((status) => status != PermissionStatus.granted)) {
      }
    } else if (androidVersion >= 33) {
      // Request permissions for Android 13
      final List<Permission> permissions = [
        Permission.photos,
        Permission.videos,
      ];

      final Map<Permission, PermissionStatus> statuses = await permissions.request();
      if (statuses.values.any((status) => status != PermissionStatus.granted)) {
        openAppSettings();
      }
    } else {
      // Request permissions for Android 12L and lower
      final PermissionStatus storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        openAppSettings();
      }
    }
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDjZnrWLuLI_J9g_MbMz_vHOS6_MHCsZyw",
        authDomain: "aaamin-53ef0.firebaseapp.com",
        databaseURL: "https://aaamin-53ef0-default-rtdb.firebaseio.com",
        projectId: "aaamin-53ef0",
        storageBucket: "aaamin-53ef0.appspot.com",
        messagingSenderId: "594113826131",
        appId: "1:594113826131:web:17047819d6c0a28ca265a6",
        measurementId: "G-JYN6LC1218",
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('Firebase App already initialized.');
    } else {
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoadingScreen(),
      routes: {
        '/signup': (context) => const Signup(),
        '/login': (context) => const Login(),
        '/home': (context) => const Homepage(),
        '/data': (context) => const Data(),
      },
    );
  }
}
