import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String username;

  ChatPage({Key? key, required this.username}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Data dari API
  Map<String, dynamic> _data = {};

  // Method untuk memuat data dari API
  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://appmedrec.com/farmasi_api/rekammedis.php?username=${widget.username}');

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
        title: Text('Rekap Medis'),
        backgroundColor: Colors.teal, // Warna latar belakang AppBar
      ),
      body: _data.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Menampilkan data pasien
                if (_data.containsKey('pasien'))
                  ..._data['pasien'].map<Widget>((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4, // Menambahkan efek bayangan pada Card
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Sudut membulat
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          'No Pasien: ${item['no_pasien']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Text('Nama Pasien: ${item['nm_pasien']}',
                                style: const TextStyle(fontSize: 14)),
                            Text(
                                'Tanggal Pemeriksaan: ${item['tgl_pemeriksaan']}',
                                style: const TextStyle(fontSize: 14)),
                            Text('Keluhan: ${item['keluhan']}',
                                style: const TextStyle(fontSize: 14)),
                            Text('Ket: ${item['ket']}',
                                style: const TextStyle(fontSize: 14)),
                            Text('Nama Dokter: ${item['nm_dokter']}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                // Menampilkan data obat dalam bentuk tabel
                if (_data.containsKey('obat'))
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0, // Jarak antar kolom
                      headingRowHeight: 56.0, // Tinggi baris heading
                      columns: [
                        DataColumn(
                            label: Text('Nama Obat',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Isi',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Jumlah',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Dosis / Hari',
                                style: TextStyle(fontWeight: FontWeight.bold))),
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
              ],
            ),
    );
  }
}
