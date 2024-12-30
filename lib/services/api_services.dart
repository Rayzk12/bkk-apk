import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiServices {
  final String baseUrl =
      'http://192.168.100.252:8000/api'; // Ganti dengan URL API Anda
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Fungsi untuk registrasi
  Future<Map<String, dynamic>> register(String name, String email,
      String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'), // Endpoint untuk registrasi
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Simpan token ke storage jika respons API menyediakan token setelah registrasi
      if (data.containsKey('token')) {
        await secureStorage.write(key: 'token', value: data['token']);
      }
      return data; // Mengembalikan data pengguna yang terdaftar
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Fungsi untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'), // Adjust to your login endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Save the token in secure storage
      await secureStorage.write(key: 'token', value: data['token']);

      // Save the user_id in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', data['user']['id'].toString());
      print(prefs.getString('user_id'));

      return data; // Return user data and token
    } else {
      throw Exception('Failed to log in');
    }
  }

  // Fungsi untuk mendapatkan daftar lowongan
  Future<List<dynamic>> fetchLowongan() async {
    try {
      final token = await secureStorage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/lowongan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['data'];
      } else {
        throw Exception('Gagal memuat lowongan');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan detail lowongan
  Future<Map<String, dynamic>> fetchDetailLowongan(int id) async {
    try {
      final token = await secureStorage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/lowongan/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat detail lowongan: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> storeAlumni(
      Map<String, dynamic> alumniData) async {
    final token = await secureStorage.read(key: 'token');

    try {
      // Kirim permintaan POST ke API
      final response = await http.post(
        Uri.parse('$baseUrl/alumni'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(alumniData),
      );

      // Periksa status kode HTTP
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil, parsing data JSON
        return jsonDecode(response.body);
      } else {
        // Gagal, parsing error dari server
        throw Exception((response.body));
      }
    } catch (e) {
      // Tangkap dan lempar ulang error jika terjadi masalah jaringan atau lainnya
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Method untuk mengambil data alumni berdasarkan ID
  Future<Map<String, dynamic>> getAlumniById() async {
    final token = await secureStorage.read(key: 'token');

    final response = await http.get(
      Uri.parse(
          '$baseUrl/data-alumni'), // Endpoint untuk mendapatkan data alumni
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mendapatkan data alumni: ${response.body}');
    }
  }

  // Fungsi untuk menyimpan pendaftaran lowongan
  Future<Map<String, dynamic>> storeDaftarLowongan(
      {required int lowonganId,
      required String nama,
      required String nisn,
      required String noTelp,
      required String email,
      required File cvFile,
      String? status}) async {
    final uri = Uri.parse('$baseUrl/pendaftaran'); // Endpoint API
    final token = await secureStorage.read(key: 'token');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

    // Menambahkan field data
    request.fields['lowongan_id'] = lowonganId.toString();
    request.fields['nama'] = nama;
    request.fields['nisn'] = nisn;
    request.fields['no_telp'] = noTelp;
    request.fields['email'] = email;

    if (status != null) request.fields['status'] = status;

    // Menambahkan file CV
    final cvStream = http.ByteStream(cvFile.openRead());
    final cvLength = await cvFile.length();
    final multipartFile = http.MultipartFile(
      'cv', // Nama field sesuai dengan API
      cvStream,
      cvLength,
      filename: cvFile.path.split('/').last,
    );

    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Jika berhasil
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Jika gagal
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Terjadi kesalahan.');
      }
    } catch (e) {
      throw Exception('Gagal mengirim data: $e');
    }
  }

  // Fungsi untuk menyimpan bookmark
  Future<void> bookmarkJob(int jobId) async {
    final token = await secureStorage.read(key: 'token');
    final response = await http.post(
      Uri.parse(
          '$baseUrl/bookmarks'), // Ganti dengan endpoint untuk menyimpan bookmark
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'job_id': jobId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal menyimpan bookmark: ${response.body}');
    }
  }

  // Fungsi untuk mengambil semua bookmark
  Future<List<dynamic>> fetchBookmarks() async {
    try {
      final token = await secureStorage.read(key: 'token');

      final response = await http.get(
        Uri.parse(
            '$baseUrl/bookmarks'), // Ganti dengan endpoint untuk mengambil bookmark
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData[
            'bookmarks']); // Debugging untuk melihat struktur respons
        return responseData['bookmarks']; // Ambil data dari 'bookmarks'
      } else {
        throw Exception('Gagal memuat bookmark');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return []; // Mengembalikan list kosong jika terjadi kesalahan
    }
  }

  // Fungsi untuk mendapatkan daftar pendaftaran berdasarkan user_id
  Future<List<dynamic>> getUserApplications() async {
    // Ambil token otentikasi dari penyimpanan
    final token = await secureStorage.read(key: 'token');

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    try {
      // Kirim request ke endpoint Laravel
      final response = await http.get(
        Uri.parse(
            '$baseUrl/pendaftaran-user'), // Ganti endpoint sesuai API Laravel
        headers: {
          'Authorization':
              'Bearer $token', // Kirim token pada header untuk otentikasi
          'Accept': 'application/json',
        },
      );

      // Periksa status response
      if (response.statusCode == 200) {
        // Parsing response JSON
        final List<dynamic> data = json.decode(response.body)['data'];
        print(data);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Otentikasi gagal, token tidak valid.');
      } else {
        throw Exception(
            'Gagal mengambil data pendaftaran, status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data pendaftaran:$e');
    }
  }

  // Fungsi untuk menghapus bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    final token = await secureStorage.read(key: 'token');

    final response = await http.delete(
      Uri.parse(
          '$baseUrl/bookmarks/$bookmarkId'), // Ganti dengan endpoint untuk menghapus bookmark
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus bookmark: ${response.body}');
    }
  }
}
