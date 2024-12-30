import 'package:bkk/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:bkk/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkedJobsScreen extends StatefulWidget {
  const BookmarkedJobsScreen({Key? key}) : super(key: key);

  @override
  _BookmarkedJobsScreenState createState() => _BookmarkedJobsScreenState();
}

class _BookmarkedJobsScreenState extends State<BookmarkedJobsScreen> {
  final ApiServices _apiServices = ApiServices();
  late Future<List<dynamic>> _bookmarkedJobsFuture =
      Future.value([]); // Initialize with empty list
  final Set<int> _bookmarkedJobIds =
      {}; // Set untuk menyimpan ID pekerjaan yang dibookmark

  @override
  void initState() {
    super.initState();
    _loadBookmarkedJobs();
  }

  Future<void> _loadBookmarkedJobs() async {
    final prefs = await SharedPreferences.getInstance();

    // Ambil daftar ID pekerjaan yang dibookmark dari SharedPreferences
    final List<String>? savedJobIds = prefs.getStringList('bookmarkedJobs');

    if (savedJobIds != null && savedJobIds.isNotEmpty) {
      // Mengubah daftar ID pekerjaan yang disimpan menjadi set of integers
      _bookmarkedJobIds.addAll(savedJobIds.map((id) => int.parse(id)));

      // Fetch bookmark jobs berdasarkan ID pekerjaan yang disimpan
      final bookmarks = await _apiServices.fetchBookmarks();
      final filteredBookmarks = bookmarks.where((bookmark) {
        return _bookmarkedJobIds.contains(bookmark['job']['id']);
      }).toList();

      setState(() {
        _bookmarkedJobsFuture = Future.value(filteredBookmarks);
      });
    } else {
      setState(() {
        _bookmarkedJobsFuture =
            Future.value([]); // Set to empty list if no saved jobs
      });
    }
  }

  Future<void> _removeBookmark(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedJobIds = prefs.getStringList('bookmarkedJobs');

    if (savedJobIds != null) {
      // Hapus ID dari daftar bookmark
      savedJobIds.remove(jobId.toString());
      await prefs.setStringList('bookmarkedJobs', savedJobIds);

      // Hapus dari set bookmark lokal
      setState(() {
        _bookmarkedJobIds.remove(jobId);
        _bookmarkedJobsFuture = _bookmarkedJobsFuture.then((jobs) {
          return jobs.where((job) => job['job']['id'] != jobId).toList();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lowongan Tersimpan'),
        centerTitle: true,
      ),
      drawer: const Sidebar(),
      body: FutureBuilder<List<dynamic>>(
        future: _bookmarkedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada lowongan yang disimpan.'));
          }

          final bookmarkedJobs = snapshot.data!;
          return ListView.builder(
            itemCount: bookmarkedJobs.length,
            itemBuilder: (context, index) {
              return _buildJobCard(context, bookmarkedJobs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    List<String> requirements;
    try {
      requirements =
          List<String>.from(json.decode(job['job']['requirement'] ?? '[]'));
    } catch (_) {
      requirements = ['Persyaratan tidak tersedia.'];
    }

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
                        job['job']['judul'] ?? 'Posisi tidak tersedia',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job['job']['perusahaan'] ?? 'Perusahaan tidak tersedia',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      Text(job['job']['lokasi'] ?? 'Lokasi tidak tersedia'),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: Colors.amber,
                      size: 35,
                    ),
                    onPressed: () {
                      // Hapus bookmark
                      _removeBookmark(job['job']['id']);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Deskripsi:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(job['job']['deskripsi'] ?? 'Tidak ada deskripsi.'),
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
