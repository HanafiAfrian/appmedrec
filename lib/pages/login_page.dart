import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_medical_ui/network/api/url_api.dart';
import 'package:flutter_medical_ui/pages/home_page.dart';
import 'package:flutter_medical_ui/pages/register_page.dart';
import 'package:flutter_medical_ui/widgets/button_primary.dart';
import 'package:flutter_medical_ui/widgets/general_logo_space.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message here
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Gas!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(background: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Ganti halaman awal menjadi SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
              username: prefs.getString('username') ?? '', isLoggedIn: true),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPages(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginPages extends StatefulWidget {
  const LoginPages({Key? key}) : super(key: key);

  @override
  _LoginPagesState createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _secureText = true;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  Future<void> _submitLogin() async {
    final Uri urlLogin = Uri.parse(BASEURL.apiLogin);
    try {
      final response = await http.post(urlLogin, body: {
        "username": usernameController.text,
        "password": passwordController.text,
        "fcm_token": _fcmToken ?? '',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final int value = data['value'] ?? 0;
        final String message = data['message'] ?? 'Unknown error';

        if (value == 1) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('username', usernameController.text);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                username: usernameController.text,
                isLoggedIn: true,
              ),
            ),
            (route) => false,
          );
        } else {
          _showDialog(
            title: 'Information',
            content: message,
          );
        }
      } else {
        _showDialog(
          title: 'Error',
          content: 'Failed to login. Please try again later.',
        );
      }
    } catch (e) {
      _showDialog(
        title: 'Error',
        content:
            'An unexpected error occurred. Please check your network connection and try again.',
      );
    }
  }

  Future<void> _getFCMToken() async {
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? token = await messaging.getToken();

      if (token != null) {
        setState(() {
          _fcmToken = token;
        });
        print('FCM Token: $_fcmToken');
      } else {
        print('Failed to get FCM token.');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  void _showDialog({
    required String title,
    required String content,
    VoidCallback? onOkPressed,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              if (onOkPressed != null) {
                onOkPressed();
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const GeneralLogoSpace(),
            const SizedBox(height: 100),
            Column(
              children: [
                Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 8),
                Text(
                  "Silahkan Melakukan Login Terlebih Dahulu!",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: usernameController,
                  hintText: 'Username',
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: _secureText,
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibility,
                    icon: _secureText
                        ? const Icon(Icons.visibility_off, size: 20)
                        : const Icon(Icons.visibility, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ButtonPrimary(
                    text: "LOGIN",
                    onTap: () {
                      if (usernameController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        _showDialog(
                          title: 'Warning !!!',
                          content: 'Please, enter the fields',
                        );
                      } else {
                        _submitLogin();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPages()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Create Account",
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_fcmToken != null)
                  GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _fcmToken!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('FCM Token disalin ke papan klip'),
                        ),
                      );
                    },
                    child: const Text('Long press to copy FCM Token'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        color: Colors.white,
      ),
      width: MediaQuery.of(context).size.width,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
