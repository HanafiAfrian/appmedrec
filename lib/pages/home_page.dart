import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_medical_ui/pages/CalendarPage.dart';
import 'package:flutter_medical_ui/pages/ChatPage.dart';
import 'package:flutter_medical_ui/pages/NotificationsPage.dart';
import 'package:flutter_medical_ui/pages/login_page.dart';
import 'package:flutter_medical_ui/pages/started.dart';
import 'package:flutter_medical_ui/pages/profile_page.dart';
import 'package:flutter_medical_ui/pages/gantipassword_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/doctor_item.dart';
import '../widgets/specialist_item.dart';

class Information {
  final String id;
  final String judul;
  final String ket;
  final String img;
  final String createdAt;

  Information({
    required this.id,
    required this.judul,
    required this.ket,
    required this.img,
    required this.createdAt,
  });

  factory Information.fromJson(Map<String, dynamic> json) {
    return Information(
      id: json['id'],
      judul: json['judul'],
      ket: json['ket'],
      img: json['img'],
      createdAt: json['created_at'],
    );
  }
}

// Model untuk Dokter
class Doctor {
  final String id;
  final String nama;
  final String image;
  final String specialist;

  Doctor({
    required this.id,
    required this.nama,
    required this.image,
    required this.specialist,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      nama: json['nama'],
      image: json['image'],
      specialist: json['specialist'],
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  final bool isLoggedIn; // Menambahkan status login sebagai parameter

  const HomePage({Key? key, required this.username, required this.isLoggedIn})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Information> _informationList = []; // Removed redundant variable
  List<Doctor> _doctorList = []; // Daftar dokter
  @override
  void initState() {
    super.initState();
    _fetchInformation();
    _fetchDoctors(); // Ambil data dokter saat inisialisasi
  }

  Future<void> _fetchDoctors() async {
    final response = await http
        .get(Uri.parse('https://appmedrec.com/farmasi_api/specialist.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _doctorList = (data['data'] as List)
              .map((doctor) => Doctor.fromJson(doctor))
              .toList();
        });
      }
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<void> _fetchInformation() async {
    final response = await http
        .get(Uri.parse('https://appmedrec.com/farmasi_api/information.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _informationList = (data['data'] as List)
              .map((info) => Information.fromJson(info))
              .toList();
        });
      }
    } else {
      throw Exception('Failed to load information');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (widget.isLoggedIn || index == 0) {
            // Hanya navigasi jika login atau item Home
            _onItemTapped(index);
          } else {
            // Menampilkan snackbar atau dialog jika mencoba mengklik item yang tidak dapat diakses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Anda harus login terlebih dahulu'),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.black54,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: widget.isLoggedIn ? Colors.black54 : Colors.grey,
            ),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: widget.isLoggedIn ? Colors.black54 : Colors.grey,
            ),
            label: 'Rekap Medis',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_none_outlined,
              color: widget.isLoggedIn ? Colors.black54 : Colors.grey,
            ),
            label: 'Riwayat',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello,",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          widget.username,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    if (widget
                        .isLoggedIn) // Menampilkan PopupMenuButton jika sudah login
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: PopupMenuButton<String>(
                          icon: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                AssetImage("assets/profile-user.png"),
                          ),
                          onSelected: (String value) {
                            switch (value) {
                              case 'profile':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(username: widget.username),
                                  ),
                                );
                                break;
                              case 'changePassword':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GantiPasswordPage(
                                        username: widget.username),
                                  ),
                                );
                                break;
                              case 'logout':
                                _logout(context);
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'profile',
                              child: Text('Profil Saya'),
                            ),
                            PopupMenuItem<String>(
                              value: 'changePassword',
                              child: Text('Ganti Password'),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Text('Logout'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 223, 200, 228),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/surgeon.png",
                        width: 92,
                        height: 100,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How do you feel?",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              "Fill out your medical right now",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPages(),
                              ),
                            ),
                            child: Container(
                              width: 150,
                              height: 35,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 16),
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(95, 179, 173, 173),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.search,
                        size: 32,
                        color: Colors.black54,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "How can we help you?",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 110, // Atur tinggi sesuai kebutuhan
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _informationList.length,
                    itemBuilder: (context, index) {
                      final info = _informationList[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 100, // Atur lebar sesuai kebutuhan
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                info.img,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      info.judul,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Doctor list",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _doctorList.length,
                    itemBuilder: (context, index) {
                      final doctor = _doctorList[index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                doctor.image,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              doctor.nama,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              doctor.specialist,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigasi ke halaman utama (HomePage), jika sudah berada di halaman ini, tidak perlu navigasi ulang
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarPage(username: widget.username),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(username: widget.username),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsPage(username: widget.username),
          ),
        );
        break;
      default:
        break;
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StartedPage(),
      ),
    );
  }
}
