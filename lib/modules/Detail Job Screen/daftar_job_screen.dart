import 'dart:convert';
import 'dart:io';

import 'package:bkk/services/api_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ApplyJobScreen extends StatefulWidget {
  const ApplyJobScreen({Key? key}) : super(key: key);

  @override
  _ApplyJobScreenState createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  PlatformFile? _selectedCV;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ApiServices _apiService = ApiServices();

  void _submitForm() async {
    String nama = _namaController.text;
    String nisn = _nisnController.text;
    String noTelp = _noTelpController.text;
    String email = _emailController.text;

    if (_selectedCV == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Silakan unggah file CV terlebih dahulu'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final cvFile = File(_selectedCV!.path!);

    try {
      // Ganti lowonganId dengan ID yang sesuai
      int lowonganId = 1; // Contoh, sesuaikan dengan data Anda
      final response = await _apiService.storeDaftarLowongan(
        lowonganId: lowonganId,
        nama: nama,
        nisn: nisn,
        noTelp: noTelp,
        email: email,
        cvFile: cvFile,
        status: 'pending', // Nilai status default
      );

      // Berhasil
      print('Pendaftaran berhasil: ${response['data']}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pendaftaran berhasil!'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      // Tampilkan pesan error
      String errorMessage = 'Gagal mengirim pendaftaran';
      if (e is Exception) {
        final errorString = e.toString();
        if (errorString.contains('{') && errorString.contains('}')) {
          final jsonStart = errorString.indexOf('{');
          final jsonString = errorString.substring(jsonStart);
          try {
            final parsedError = jsonDecode(jsonString);
            errorMessage = parsedError['message'] ?? errorMessage;
          } catch (_) {}
        }
      }

      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _pickCVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedCV = result.files.single;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BKK SMN 19 JAKARTA'),
        centerTitle: true,
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
            _buildTextField('NISN', _nisnController),
            _buildTextField('No Telepon', _noTelpController),
            _buildTextField('Email', _emailController),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: _pickCVFile,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: _selectedCV != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_present,
                                  size: 50, color: Colors.blue),
                              const SizedBox(height: 8),
                              Text(
                                _selectedCV!.name,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file,
                                  size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Silahkan unggah file CV',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
