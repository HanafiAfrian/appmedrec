import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_medical_ui/pages/home_page.dart';
import 'package:flutter_medical_ui/pages/started.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? username = prefs.getString('username');
  await Firebase.initializeApp(); // Inisialisasi Firebase

  runApp(MyApp(isLoggedIn: isLoggedIn, username: username));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;

  const MyApp({Key? key, required this.isLoggedIn, this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLoggedIn
          ? HomePage(username: username ?? '', isLoggedIn: isLoggedIn)
          : StartedPage(),
      debugShowCheckedModeBanner: false, // Menonaktifkan banner debug
    );
  }
}
