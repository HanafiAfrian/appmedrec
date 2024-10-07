import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileData;
  late TextEditingController _noPasienController;
  late TextEditingController _nmPasienController;
  late TextEditingController _nikController;
  late TextEditingController _jKelController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _agamaController;
  late TextEditingController _alamatController;
  late TextEditingController _tglLhrController;
  late TextEditingController _usiaController;
  late TextEditingController _noTlpController;
  late TextEditingController _statusController;
  late TextEditingController _tglDaftarController;
  late TextEditingController _idPasienController;

  @override
  void initState() {
    super.initState();
    _profileData = fetchProfileData(widget.username);
  }

  Future<Map<String, dynamic>> fetchProfileData(String username) async {
    final response = await http.get(Uri.parse(
        'https://appmedrec.com/farmasi_api/user_profil.php?username=$username'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final profile = data[0];

        // Inisialisasi controllers dengan data
        setState(() {
          _noPasienController =
              TextEditingController(text: profile['no_pasien']);
          _nmPasienController =
              TextEditingController(text: profile['nm_pasien']);
          _nikController =
              TextEditingController(text: profile['nik'].toString());
          _jKelController = TextEditingController(text: profile['j_kel']);
          _pekerjaanController =
              TextEditingController(text: profile['pekerjaan']);
          _agamaController = TextEditingController(text: profile['agama']);
          _alamatController = TextEditingController(text: profile['alamat']);
          _tglLhrController = TextEditingController(text: profile['tgl_lhr']);
          _usiaController = TextEditingController(text: profile['usia']);
          _noTlpController = TextEditingController(text: profile['no_tlp']);
          _statusController = TextEditingController(text: profile['status']);
          _tglDaftarController =
              TextEditingController(text: profile['tgldaftar']);
          _idPasienController =
              TextEditingController(text: profile['id_pasien'].toString());
        });

        return profile;
      } else {
        return {"message": "Data pasien tidak ditemukan"};
      }
    } else {
      throw Exception('Gagal mengambil data profil');
    }
  }

  Future<void> _updateProfile() async {
    final url =
        'https://appmedrec.com/farmasi_api/update_user_profil.php'; // URL endpoint untuk update
    final response = await http.post(Uri.parse(url), body: {
      'no_pasien': _noPasienController.text,
      'nm_pasien': _nmPasienController.text,
      'nik': _nikController.text,
      'j_kel': _jKelController.text,
      'pekerjaan': _pekerjaanController.text,
      'agama': _agamaController.text,
      'alamat': _alamatController.text,
      'tgl_lhr': _tglLhrController.text,
      'usia': _usiaController.text,
      'no_tlp': _noTlpController.text,
      'status': _statusController.text,
      'tgldaftar': _tglDaftarController.text,
      'id_pasien': _idPasienController.text,
    });

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      // Tampilkan pesan sukses atau error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      throw Exception('Gagal memperbarui data profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya'),
        backgroundColor: Colors.teal, //
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: GlobalKey<FormState>(),
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _noPasienController,
                      decoration: InputDecoration(labelText: 'No Pasien'),
                      keyboardType: TextInputType.text,
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _nmPasienController,
                      decoration: InputDecoration(labelText: 'Nama Pasien'),
                      keyboardType: TextInputType.text,
                      enabled: false,
                    ),
                    TextFormField(
                      controller: _nikController,
                      decoration: InputDecoration(labelText: 'NIK'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _jKelController,
                      decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      controller: _pekerjaanController,
                      decoration: InputDecoration(labelText: 'Pekerjaan'),
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      controller: _agamaController,
                      decoration: InputDecoration(labelText: 'Agama'),
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: InputDecoration(labelText: 'Alamat'),
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      controller: _tglLhrController,
                      decoration: InputDecoration(labelText: 'Tanggal Lahir'),
                      keyboardType: TextInputType.text,
                    ),
                    TextFormField(
                      controller: _usiaController,
                      decoration: InputDecoration(labelText: 'Usia'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _noTlpController,
                      decoration: InputDecoration(labelText: 'No Telepon'),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profil'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('Data tidak ditemukan'));
          }
        },
      ),
    );
  }
}
