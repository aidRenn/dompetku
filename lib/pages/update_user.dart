import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dompetku/config/api.dart';
import 'package:dompetku/models/user.dart';
import 'package:dompetku/pages/home.dart';

class UpdateUser extends StatefulWidget {
  final User user;
  const UpdateUser({super.key, required this.user});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(
      text: widget.user.password ?? '',
    );
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse(Api.updateUser),
        body: {
          'id': widget.user.id.toString(),
          'nama': _namaController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final res = jsonDecode(response.body);
      if (res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['result'] ?? 'Gagal update'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFD0B8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Color(0xFFDFD0B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFDFD0B8)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Ubah Informasi Akun",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222831),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _namaController,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Nama harus diisi'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Nama',
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Color(0xFFFFF1DC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Email harus diisi'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Color(0xFFFFF1DC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Password harus diisi'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Color(0xFFFFF1DC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222831),
                    foregroundColor: const Color(0xFFDFD0B8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan"),
                  onPressed: _updateUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
