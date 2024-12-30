import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header bagian atas dari drawer
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo di atas nama aplikasi
                Image(
                  image: AssetImage(
                      'assets/smk_logo.png'), // Gantilah dengan path logo Anda
                  height: 100, // Atur ukuran logo sesuai kebutuhan
                  width: 100, // Atur ukuran logo sesuai kebutuhan
                ),
                SizedBox(height: 8), // Jarak antara logo dan nama aplikasi
                Text(
                  'BKK SMN 19 JAKARTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Navigasi ke Lowongan Tersimpan
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Cari Lowongan'),
            onTap: () {
              Navigator.pushNamed(context, '/job');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Lowongan Tersimpan'),
            onTap: () {
              Navigator.pushNamed(context, '/bookmarkedJobs');
            },
          ),
          // Navigasi ke Notifikasi Lamaran Saya
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifikasi Lamaran Saya'),
            onTap: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
        ],
      ),
    );
  }
}
