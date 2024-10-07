import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  final String username;

  CalendarPage({Key? key, required this.username}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Data dari API
  Map<String, dynamic> _data = {};

  // Method untuk memuat data dari API
  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://appmedrec.com/farmasi_api/jadwal_obat.php?username=${widget.username}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _data = jsonData;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _updateKonfirmasi(String id, String noRm, String kdObat) async {
    final url = Uri.parse(
        'https://appmedrec.com/farmasi_api/update_konfirmasi_jadwal_obat.php?id=$id&no_rm=$noRm&kd_obat=$kdObat');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Konfirmasi berhasil'),
          ));
          fetchData(); // Reload data setelah konfirmasi
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal mengonfirmasi'),
          ));
        }
      } else {
        throw Exception('Gagal menghubungi server');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan'),
      ));
    }
  }

  Future<void> _batalKonfirmasi(String id, String noRm, String kdObat) async {
    final url = Uri.parse(
        'https://appmedrec.com/farmasi_api/batal_konfirmasi_jadwal_obat.php?id=$id&no_rm=$noRm&kd_obat=$kdObat');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Pembatalan konfirmasi berhasil'),
          ));
          fetchData(); // Reload data setelah pembatalan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal membatalkan konfirmasi'),
          ));
        }
      } else {
        throw Exception('Gagal menghubungi server');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan'),
      ));
    }
  }

  void _showConfirmationDialog(
      BuildContext context, String id, String noRm, String kdObat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
              'Apakah Anda yakin ingin membatalkan konfirmasi minum obat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
                _batalKonfirmasi(
                    id, noRm, kdObat); // Memanggil fungsi batal konfirmasi
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    // Memformat tanggal dengan format yang diinginkan
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String formattedDate2 = DateFormat('EEEE, d MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Minum Obat'),
        backgroundColor: Colors.teal, // Warna latar belakang AppBar
      ),
      body: _data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                if (_data.containsKey('pasien'))
                  ..._data['pasien'].map<Widget>((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 5, // Menambahkan efek bayangan pada Card
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Sudut membulat
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        subtitle: Text(
                          'Tanggal: $formattedDate2',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 72, 59, 59)),
                        ),
                      ),
                    );
                  }).toList(),
                if (_data.containsKey('obat') && _data.containsKey('jadwal'))
                  ..._data['obat'].map<Widget>((obat) {
                    var jadwalObat = _data['jadwal']
                        .where((item) => item['kd_obat'] == obat['kd_obat'])
                        .toList();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${obat['nm_obat']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text('Jumlah: ${obat['jumlah']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Dosis/Hari: ${obat['dosis']}',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8.0),
                            ...jadwalObat.map<Widget>((item) {
                              String id = item['id'].toString();
                              String noRm = item['no_rm'].toString();
                              String kdObat = item['kd_obat'].toString();

                              String jamMinumObat = item['jam_minum_obat'] ??
                                  'Tidak ada'; // Penanganan null

                              return Row(
                                children: [
                                  Text(
                                    '${item['jam']} ',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 8.0),
                                  if (item['tanggal'] == formattedDate)
                                    const SizedBox(width: 8.0),
                                  if (obat['jumlah'] == 0)
                                    ElevatedButton(
                                      onPressed: () => _showSnackbar(
                                          context, 'Sisa obat sudah habis'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Warna latar belakang tombol
                                      ),
                                      child: const Text('Konfirmasi'),
                                    )
                                  else if (item['konfirmasi'] == 'Selesai' &&
                                      item['tanggal'] != formattedDate)
                                    ElevatedButton(
                                      onPressed: () =>
                                          _updateKonfirmasi(id, noRm, kdObat),
                                      child: const Text('Konfirmasi'),
                                    )
                                  else
                                    Row(
                                      children: [
                                        Text(
                                          'Selesai',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          jamMinumObat,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(
                                            width:
                                                10), // Jarak antara teks dan tombol
                                        ElevatedButton(
                                          onPressed: () =>
                                              _showConfirmationDialog(
                                                  context, id, noRm, kdObat),
                                          child: const Text('Batal'),
                                        ),
                                      ],
                                    )
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
    );
  }
}

class _showSnackbar {
  _showSnackbar(BuildContext context, String s);
}
