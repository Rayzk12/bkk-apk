import 'package:bkk/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:bkk/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);

  @override
  _JobScreenState createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final ApiServices _apiServices = ApiServices();
  late Future<List<dynamic>> _lowonganFuture;
  final Set<int> _bookmarkedJobIds = {};

  @override
  void initState() {
    super.initState();
    _loadBookmarkedJobs(); // Load bookmarked jobs from API
    _lowonganFuture = _apiServices.fetchLowongan();
  }

  Future<void> _loadBookmarkedJobs() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch bookmarks from API
    try {
      final bookmarkedJobs = await _apiServices.fetchBookmarks();

      setState(() {
        // Tambahkan job_id ke dalam _bookmarkedJobIds
        _bookmarkedJobIds.addAll(
            bookmarkedJobs.map((bookmark) => bookmark['job_id'] as int));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data bookmark: $e')),
      );
    }
  }

  Future<void> _saveBookmarkedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarkedJobs',
        _bookmarkedJobIds.map((id) => id.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BKK SMN 19 JAKARTA'),
        centerTitle: true,
      ),
      drawer: const Sidebar(), // Include Sidebar here
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Jobs',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Start Your Job !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _lowonganFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada lowongan tersedia.'));
                }

                final lowongans = snapshot.data!;
                print(lowongans);
                return ListView.builder(
                  itemCount: lowongans.length,
                  itemBuilder: (context, index) {
                    return _buildJobCard(context, lowongans[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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

  Widget _buildJobCard(BuildContext context, dynamic job) {
    List<String> requirements;
    try {
      requirements = List<String>.from(json.decode(job['requirement'] ?? '[]'));
    } catch (_) {
      requirements = ['Persyaratan tidak tersedia.'];
    }

    bool isBookmarked = _bookmarkedJobIds.contains(job['id']);

    return GestureDetector(
      onTap: () {
        // Mengirim data job ke halaman InsideJob
        Navigator.pushNamed(context, '/insideJob', arguments: job);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['judul'] ?? 'Posisi tidak tersedia',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job['perusahaan'] ?? 'Perusahaan tidak tersedia',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      Text(job['mitra']['lokasi'] ?? 'Lokasi tidak tersedia'),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.amber[400],
                      size: 35,
                    ),
                    onPressed: () async {
                      // Implement bookmark functionality
                      try {
                        if (isBookmarked) {
                          // Remove bookmark
                          await _apiServices.deleteBookmark(job['id']);
                          _bookmarkedJobIds.remove(job['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Lowongan dihapus dari bookmark!')),
                          );
                        } else {
                          // Add bookmark
                          await _apiServices.bookmarkJob(
                              job['id']); // Use job['id'] for the bookmark
                          _bookmarkedJobIds.add(job['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lowongan disimpan!')),
                          );
                        }
                        await _saveBookmarkedJobs(); // Simpan status bookmark ke SharedPreferences
                        setState(() {}); // Refresh UI
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menyimpan: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job['deskripsi'] ?? 'Tidak ada deskripsi.'),
              const SizedBox(height: 8),
              const Text('Persyaratan Teknis:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...requirements.map((req) => Text('• $req')).toList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
