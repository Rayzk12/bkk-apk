import 'package:bkk/modules/Login%20Screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:bkk/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan ini diimpor untuk menggunakan layanan API

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final baseUrl = 'http://192.168.100.252:8000/uploads/profile_photos/';
  final ApiServices _apiService = ApiServices();
  Map<String, dynamic>? _alumniData; // Menyimpan data alumni
  bool _isLoading = true; // Menandakan apakah data sedang dimuat

  @override
  void initState() {
    super.initState();
    _getAlumni(); // Mengambil data alumni saat halaman diinisialisasi
  }

  // Method untuk mengambil data alumni
  Future<void> _getAlumni() async {
    try {
      final data = await _apiService.getAlumniById();
      setState(() {
        _alumniData = data['data']; // Menyimpan data alumni
        _isLoading =
            false; // Set loading ke false setelah data berhasil diambil
      });
      print(_alumniData);
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // Set loading ke false jika ada error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement menu functionality
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        "$baseUrl${_alumniData?['photo']}" ??
                            'https://www.w3schools.com/w3images/avatar2.png', // Ganti dengan URL foto dari data alumni
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _alumniData?['user']['name'] ??
                          'Nama Pengguna', // Tampilkan nama pengguna
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _alumniData?['user']['email'] ??
                          'email@example.com', // Tampilkan email pengguna
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nama Lengkap'),
                      subtitle:
                          Text(_alumniData?['nama_siswa'] ?? 'Tidak ada data'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Nomor Telepon'),
                      subtitle: Text(
                          _alumniData?['nomor_telepon'] ?? 'Tidak ada data'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('Jurusan'),
                      subtitle: Text(_alumniData?['jurusan'] ??
                          'Tidak ada data'), // Menampilkan jurusan
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tahun Kelulusan'),
                      subtitle: Text(
                          _alumniData?['tahun_kelulusan']?.toString() ??
                              'Tidak ada data'), // Menampilkan tahun kelulusan
                    ),
                    ListTile(
                      leading: const Icon(Icons.pin_drop),
                      title: const Text('Sasaran'),
                      subtitle: Text(_alumniData?['sasaran'] ??
                          'Tidak ada data'), // Menampilkan sasaran
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs
                            .clear(); // Menghapus semua data dari SharedPreferences

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 32),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/job');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/alumni');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
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
}
