import 'dart:convert';

import 'package:bkk/services/api_services.dart';
import 'package:flutter/material.dart';

class AlumniScreen extends StatefulWidget {
  const AlumniScreen({Key? key}) : super(key: key);

  @override
  _AlumniScreenState createState() => _AlumniScreenState();
}

class _AlumniScreenState extends State<AlumniScreen> {
  String? _selectedKompetensi;
  String? _selectedSasaran;
  String? _selectedTahunLulus;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tempatSasaranController =
      TextEditingController();

  final ApiServices _apiService = ApiServices(); // Inisialisasi AlumniService

  void _submitForm() async {
    // Ambil data dari form
    String nama = _namaController.text;
    String nik = _nikController.text;
    String noTelp = _noTelpController.text;
    String email = _emailController.text;
    String tempatSasaran = _tempatSasaranController.text;

    // Membuat Map untuk data alumni
    Map<String, dynamic> alumniData = {
      'nama_siswa': nama,
      'nisn': nik, // Jika NIK diubah menjadi NISN
      'nomor_telepon': noTelp,
      'email': email,
      'jenis_kelamin':
          'Laki-laki', // Sesuaikan jika Anda menambah pilihan gender
      'jurusan': _selectedKompetensi,
      'tahun_kelulusan': _selectedTahunLulus,
      'sasaran': _selectedSasaran,
      'tempat_sasaran': tempatSasaran,
    };

    try {
      // Kirim data ke API
      final response = await _apiService.storeAlumni(alumniData);

      // Tampilkan pesan berhasil
      print('Data berhasil disimpan: ${response['data']}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data berhasil disimpan!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // Variabel default untuk pesan error
      String errorMessage = 'Gagal menyimpan data';

      // Cek apakah error adalah Exception dengan JSON di dalamnya
      if (e is Exception) {
        final errorString = e.toString();
        // Cek apakah mengandung JSON
        if (errorString.contains('{') && errorString.contains('}')) {
          final jsonStart = errorString.indexOf('{');
          final jsonString = errorString.substring(jsonStart);
          try {
            // Parse JSON
            final parsedError = jsonDecode(jsonString);
            errorMessage = parsedError['message'] ?? errorMessage;
          } catch (parseError) {
            print('Error parsing response: $parseError');
          }
        }
      }

      // Tampilkan pesan error di SnackBar
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BKK SMN 19 JAKARTA'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement menu functionality
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Diri',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField('Nama', _namaController),
            _buildTextField('No NIK', _nikController),
            _buildTextField('No TELP', _noTelpController),
            _buildTextField('E-Mail', _emailController),
            const SizedBox(height: 16),
            const Text(
              'KOMPETENSI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRadioGrid(
                _selectedTahunLulus == '2024'
                    ? [
                        'Akuntansi dan Keuangan Lembaga',
                        'Manajemen Perkantoran',
                        'Broadcasting dan Perfilman',
                        'Bisnis Retail'
                      ]
                    : [
                        'Akuntansi dan Keuangan Lembaga',
                        'Otomotatisasi dan Tata Kelola Perkantoran',
                        'Multimedia',
                        'Bisnis Daring dan Pemasaran'
                      ],
                _selectedKompetensi, (value) {
              setState(() {
                _selectedKompetensi = value;
              });
            }),
            const SizedBox(height: 16),
            const Text(
              'SASARAN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSasaranGrid(
                ['Belum BEKERJA', 'KULIAH', 'WIRAUSAHA', 'Bekerja'],
                _selectedSasaran, (value) {
              setState(() {
                _selectedSasaran = value;
              });
            }),
            const SizedBox(height: 16),
            _buildTextField('Tempat Sasaran', _tempatSasaranController),
            const SizedBox(height: 16),
            const Text(
              'TAHUN LULUS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRadioGrid(
                ['2021', '2022', '2023', '2024'], _selectedTahunLulus, (value) {
              setState(() {
                _selectedTahunLulus = value;
                // Reset kompetensi saat tahun lulus diubah
                _selectedKompetensi = null;
              });
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue,
                ),
                child: const Text('KIRIM'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Halaman Alumni, indeks 1
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/job'); // JobScreen
          } else if (index == 1) {
            Navigator.pushNamed(context, '/alumni'); // AlumniScreen
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile'); // ProfileScreen
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Job'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Alumni'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2, // Memberikan ruang lebih untuk label
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8), // Jarak antara label dan TextField
          Expanded(
            flex: 5, // Memberikan ruang lebih untuk TextField
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12), // Atur padding untuk mengurangi tinggi
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Membuat sudut membulat
                  borderSide:
                      const BorderSide(color: Colors.grey), // Warna border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Sudut membulat saat fokus
                  borderSide: const BorderSide(
                      color: Colors.blue), // Warna border saat fokus
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGrid(List<String> options, String? groupValue,
      ValueChanged<String?> onChanged) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Maksimal 2 kolom
        childAspectRatio: 4, // Mengatur rasio aspek agar lebih kompak
        crossAxisSpacing: 2, // Jarak antar kolom
        mainAxisSpacing: 0, // Jarak antar baris
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: options[index],
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Expanded(
              // Membungkus dengan Expanded agar teks bisa membungkus ke bawah
              child: Text(
                options[index],
                style: const TextStyle(
                    // Optional: tambahkan gaya teks sesuai kebutuhan
                    ),
                maxLines: 3, // Batasi teks menjadi 2 baris, bisa disesuaikan
                overflow: TextOverflow
                    .ellipsis, // Menambahkan elipsis jika teks lebih panjang
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSasaranGrid(List<String> options, String? groupValue,
      ValueChanged<String?> onChanged) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Maksimal 3 kolom
        childAspectRatio: 5, // Menjaga rasio aspek agar lebih kompak
        crossAxisSpacing: 2, // Jarak antar kolom
        mainAxisSpacing: 0, // Jarak antar baris diatur ke 0
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: options[index],
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(options[index]),
          ],
        );
      },
    );
  }
}
