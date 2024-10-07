import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class _showSnackbar {
  _showSnackbar(BuildContext context, String s);
}

class NotificationsPage extends StatefulWidget {
  final String username;

  NotificationsPage({Key? key, required this.username}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Data dari API
  Map<String, dynamic> _data = {};

  // Method untuk memuat data dari API
  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://appmedrec.com/farmasi_api/riwayat_minum_obat.php?username=${widget.username}');

    try {
      final response = await http.get(url);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Ubah respons JSON menjadi Map<String, dynamic>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Minum Obat'),
        backgroundColor: Colors.teal, // Warna latar belakang AppBar
      ),
      body: _data.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Menampilkan data obat dalam bentuk tabel
                  if (_data.containsKey('obat'))
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16.0, // Jarak antar kolom
                          headingRowHeight: 56.0, // Tinggi baris heading
                          columns: [
                            DataColumn(
                                label: Text('Nama Obat',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Isi',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Jumlah',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Dosis / Hari',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: _data['obat'].map<DataRow>((item) {
                            return DataRow(cells: [
                              DataCell(Text(item['nm_obat'].toString())),
                              DataCell(Text(item['isi'].toString())),
                              DataCell(Text(item['jumlah'].toString())),
                              DataCell(Text(item['dosis'].toString())),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),

                  // Menampilkan jadwal minum obat dalam bentuk tabel
                  if (_data.containsKey('jadwal'))
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16.0, // Jarak antar kolom
                          headingRowHeight: 56.0, // Tinggi baris heading
                          columns: [
                            DataColumn(
                                label: Text('Tanggal & Hari',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Jam',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Nama Obat',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Status',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: _data['jadwal'].map<DataRow>((item) {
                            String date = item['tanggal'].toString();
                            String dayName = item['nama_hari'].toString();
                            return DataRow(cells: [
                              DataCell(Text('$dayName, $date')),
                              DataCell(Text(item['jam'].toString())),
                              DataCell(Text(_data['obat']
                                  .firstWhere((o) =>
                                      o['kd_obat'] ==
                                      item['kd_obat'])['nm_obat']
                                  .toString())),
                              DataCell(Text(item['konfirmasi'].toString())),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
