import 'package:bkk/modules/Job%20Screen/job_screen.dart';
import 'package:bkk/services/api_services.dart'; // Impor ApiServices
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true; // Default adalah obscure text aktif
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiServices _apiServices = ApiServices();

  bool _isLoading = false; // Status loading

  void _login() async {
    setState(() {
      _isLoading = true; // Set loading status true saat login
    });

    try {
      final response = await _apiServices.login(
        _emailController.text,
        _passwordController.text,
      );

      // Mengecek status akun dari response (misalnya, 'status' adalah field dalam API response)
      if (response['status'] == 'inactive') {
        // Jika statusnya inactive, tampilkan dialog dan arahkan kembali ke login
        _showInactiveDialog();
        return; // Menghentikan eksekusi jika akun tidak aktif
      }

      // Navigasi ke JobScreen setelah login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobScreen()),
      );
    } catch (e) {
      // Tampilkan dialog kesalahan jika login gagal
      String errorMessage;
      if (e is Map<String, dynamic> && e.containsKey('message')) {
        // Jika API mengembalikan pesan kesalahan
        errorMessage = e['message'];
      } else {
        errorMessage = 'Login gagal. Silakan coba lagi.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading status false setelah proses selesai
      });
    }
  }

  void _showInactiveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Akun Belum Aktif'),
          content: const Text(
              'Akun Anda belum aktif. Silakan hubungi admin untuk aktivasi akun.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/smk_logo.png', width: 80, height: 80),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'BURSA KERJA KHUSUS\nSMKN 19 JAKARTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to the BKK SMKN 19 JAKARTA application',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
  controller: _passwordController,
  obscureText: _isObscured, // Menggunakan status _isObscured
  decoration: InputDecoration(
    labelText: 'Password',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    suffixIcon: IconButton(
      icon: Icon(
        _isObscured ? Icons.visibility_off : Icons.visibility, // Ubah ikon berdasarkan status
      ),
      onPressed: () {
        setState(() {
          _isObscured = !_isObscured; // Toggle status obscure
        });
      },
    ),
  ),
),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _login, // Nonaktifkan tombol saat loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator() // Tampilkan indikator loading
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No Account Yet?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Register Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
