import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import this to use kIsWeb
import './screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // RUNNING ON WEB: Use manual options
    // Replace the strings below with values from your Firebase Console
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCJJE2A-DxS5J5zXQu1W9QWeZf0amC83-c",
        appId: "1:574182244658:web:55d38a873700ea8936572b",
        messagingSenderId: "574182244658",
        projectId: "swipe-book-782ac",
        storageBucket: "swipe-book-782ac.firebasestorage.app",
      ),
    );
  } else {
    // RUNNING ON MOBILE (Android/iOS): Uses google-services.json automatically
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech Book',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}