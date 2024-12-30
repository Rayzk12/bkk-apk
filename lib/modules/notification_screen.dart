import 'package:bkk/services/api_services.dart';
import 'package:bkk/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class UserApplicationsScreen extends StatefulWidget {
  const UserApplicationsScreen({super.key});

  @override
  _UserApplicationsScreenState createState() => _UserApplicationsScreenState();
}

class _UserApplicationsScreenState extends State<UserApplicationsScreen> {
  late Future<List<dynamic>> _applicationsFuture;

  @override
  void initState() {
    super.initState();
    _applicationsFuture = ApiServices().getUserApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran Lowongan'),
      ),
      drawer: const Sidebar(),
      body: FutureBuilder<List<dynamic>>(
        future: _applicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Tangani error dengan lebih detail
            final error = snapshot.error;
            return Center(
              child: Text(
                'Terjadi kesalahan: ${error is Exception ? error.toString() : 'Error tidak diketahui'}',
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data pendaftaran.'));
          } else {
            final applications = snapshot.data!;
            print(applications);
            return ListView.builder(
              itemCount: applications.length,
              itemBuilder: (context, index) {
                var application = applications[index];
                return _buildApplicationCard(application);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildApplicationCard(dynamic application) {
    // Validasi data response sebelum diakses
    final lowongan = application['lowongan'];
    final String jobTitle = lowongan?['judul'] ?? 'Judul tidak tersedia';
    final String company = lowongan?['mitra']['perusahaan'] ?? 'Perusahaan tidak tersedia';
    final String location = lowongan?['mitra']['lokasi'] ?? 'Lokasi tidak tersedia';
    final String status = application['status'] ?? 'Status tidak tersedia';
    final String interviewLocation =
        application['lokasi_interview'] ?? 'Lokasi interview tidak tersedia';
    final String interviewDate =
        application['tanggal_interview'] ?? 'Tanggal interview tidak tersedia';

    // Menentukan warna badge berdasarkan status lamaran
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'accepted':
        badgeColor = Colors.green;
        badgeText = 'Diterima';
        break;
      case 'rejected':
        badgeColor = Colors.red;
        badgeText = 'Ditolak';
        break;
      default:
        badgeColor = Colors.yellow;
        badgeText = 'Menunggu';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul dan informasi lowongan
                Text(
                  jobTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(company),
                Text(location),
                const SizedBox(height: 8),

                // Detail interview jika diterima dan data tersedia
                if (status == 'accepted' &&
                    (interviewLocation != 'Lokasi interview tidak tersedia' ||
                        interviewDate != 'Tanggal interview tidak tersedia')) ...[
                  Row(
                    children: [
                      const Text(
                        'Lokasi Interview: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(interviewLocation),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Tanggal Interview: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(interviewDate),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Badge status di pojok kanan atas
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
    ),
  );
 }
}