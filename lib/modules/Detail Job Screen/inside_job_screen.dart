import 'dart:convert';
import 'package:bkk/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InsideJobScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const InsideJobScreen({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari job
    final String photo = "http://192.168.100.252:8000/${job['photo']}";
    final String title = job['judul'] ?? 'Posisi tidak tersedia';
    final String company = job['perusahaan'] ?? 'Perusahaan tidak tersedia';
    final String location = job['mitra']['lokasi'] ?? 'Lokasi tidak tersedia';
    final String category = job['kategori'] ?? 'Kategori tidak tersedia';
    final String type = job['tipe'] ?? 'Tipe tidak tersedia';
    final String link = job['link_lamaran'] ?? 'Link tidak tersedia';
    final String salary = job['gaji'] != null
        ? 'Rp ${job['gaji']?.replaceAll('.', ',') ?? 'Gaji tidak tersedia'} per month'
        : 'Gaji tidak tersedia';
    final String description = job['deskripsi'] ?? 'Deskripsi tidak tersedia.';
    final List<String> requirements =
        List<String>.from(json.decode(job['requirement'] ?? '[]'));

    // Inisialisasi ApiService dan Flutter Secure Storage
    final ApiServices apiService = ApiServices();
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BKK SMN 19 JAKARTA'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: photo != null
                  ? Image.network(
                      photo, // Replace 'photo' with the URL of the image
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image not available'));
                      },
                    )
                  : const Center(
                      child: Text('No image available'),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(company),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(location),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.work, size: 16),
                      const SizedBox(width: 4),
                      Text(category),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(type),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16),
                      const SizedBox(width: 4),
                      Text(salary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Posted 6 hari yang lalu'),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 16),
                  const Text(
                    'Persyaratan Teknis: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...requirements.map((req) => Text('• $req')).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Lakukan pengecekan apakah link valid
                  await launcher(link);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lihat Lamaran'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Ambil userId dari secureStorage atau auth
                  // final token = await secureStorage.read(key: 'token');
                  // if (token != null) {
                  //   final prefs = await SharedPreferences.getInstance();
                  //   final userId = prefs.getString('user_id');
                  //   final lowonganId = job['id'];
                  //   print("User ID: ${userId}; Job ID: ${lowonganId}");

                  //   // Panggil API untuk menyimpan pendaftaran
                  //   try {
                  //     final response = await apiService.storeDaftarLowongan(
                  //       lowonganId: lowonganId,
                  //       userId: int.parse(userId!), // Convert ke int
                  //     );

                  //     // Tampilkan pesan sukses
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Data berhasil disimpan')),
                  //     );
                  //   } catch (e) {
                  //     // Tampilkan pesan error
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Gagal menyimpan data')),
                  //     );
                  //   }
                  // }
                  Navigator.pushNamed(context, '/applyJob');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Daftar Lowongan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launcher(String url) async {
    final Uri url0 = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(url0)) {
      throw Exception("Failed to launch URL: $url0");
    }
  }
}
