import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dompetku/config/api.dart';
import 'package:dompetku/models/user.dart';
import 'package:dompetku/pages/login.dart';
import 'package:dompetku/pages/update_user.dart';
import 'package:dompetku/utils/session.dart';
import 'package:dompetku/pages/kategori_page.dart';
import 'transaksi_page.dart';
import 'catatan_page.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _user;
  bool _loading = true;

  int pemasukan = 0;
  int pengeluaran = 0;
  int saldo = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _getUserData();
    await _getRekap();
  }

  Future<void> _getUserData() async {
    final userId = await SessionManager.getUserId();

    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Api.getUser),
        body: {'id': userId},
      );

      final res = jsonDecode(response.body);

      if (res['status'] == 200) {
        setState(() {
          _user = User.fromJson(res['result']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat data user'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _getRekap() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    try {
      final res = await http.post(
        Uri.parse(Api.getTransaksi),
        body: {'user_id': userId},
      );
      final data = jsonDecode(res.body);

      if (data['status'] == 200) {
        int totalPemasukan = 0;
        int totalPengeluaran = 0;

        for (var item in data['result']) {
          final jenis = item['jenis'].toString().trim().toLowerCase();
          final nominal =
              double.tryParse(item['nominal'].toString())?.toInt() ?? 0;

          if (jenis == 'pemasukan') {
            totalPemasukan += nominal;
          } else if (jenis == 'pengeluaran') {
            totalPengeluaran += nominal;
          }
        }

        setState(() {
          pemasukan = totalPemasukan;
          pengeluaran = totalPengeluaran;
          saldo = pemasukan - pengeluaran;
        });
      }
    } catch (e) {
      print("Rekap error: $e");
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> _confirmDeleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah kamu yakin ingin menghapus akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteUser();
    }
  }

  Future<void> _deleteUser() async {
    try {
      print("Menghapus user dengan ID: ${_user!.id}");
      print("URL API: ${Api.delUser}");

      final response = await http.post(
        Uri.parse(Api.delUser),
        body: {'id': _user!.id.toString()},
      );

      print("RESPONSE BODY:");
      print(response.body); // ini penting!

      final res = jsonDecode(response.body);

      if (res['status'] == 200) {
        await SessionManager.clearUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['result'] ?? 'Gagal menghapus akun'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFD0B8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        title: const Text(
          "Home",
          style: TextStyle(
            color: Color(0xFFDFD0B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFDFD0B8)),
      ),
      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF1DC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Halo, ${_user?.nama ?? '-'}!",
                          style: const TextStyle(
                            fontSize: 30,
                            color: Color(0xFF222831),
                            fontFamily: 'Yellowtail',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                                endIndent: 8,
                              ),
                            ),
                            Text(
                              _user?.email ?? '-',
                              style: const TextStyle(
                                color: Color(0xFF393E46),
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                                indent: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildRekapCard(),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF1DC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                                endIndent: 8,
                              ),
                            ),
                            Text(
                              "HOME MENU",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222831),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                                indent: 8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildMenuButton(
                          label: "Transaksi",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransaksiPage(),
                              ),
                            );
                            _getRekap();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuButton(
                          label: "Kategori",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KategoriPage(),
                              ),
                            );
                            _getRekap();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuButton(
                          label: "Catatan",
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CatatanPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFDFD0B8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF222831),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dompet Mahasiswa',
                  style: TextStyle(
                    color: Color(0xFFDFD0B8),
                    fontSize: 28,
                    fontFamily: 'Yellowtail',
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _user?.nama ?? '-',
                  style: const TextStyle(
                    color: Color(0xFFDFD0B8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user?.email ?? '-',
                  style: const TextStyle(
                    color: Color(0xFFDFD0B8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDrawerItem(
            icon: Icons.edit,
            label: 'Edit Profil',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateUser(user: _user!),
                ),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.delete,
            label: 'Hapus Akun',
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteUser();
            },
          ),
          const Spacer(),
          const Divider(
            color: Color(0xFF393E46),
            indent: 16,
            endIndent: 16,
            thickness: 1,
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi Logout"),
                  content: const Text(
                    "Apakah kamu yakin ingin keluar dari akun ini?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
              if (confirm == true) _logout();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF393E46)),
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFF393E46), fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF393E46),
          foregroundColor: const Color(0xFFDFD0B8),
          minimumSize: const Size.fromHeight(50),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }

  String formatRupiah(int number) {
    return NumberFormat('#,##0', 'id_ID').format(number);
  }

  Widget _buildRekapCard() {
    return Row(
      children: [
        _buildSingleCard(
          title: "Saldo",
          value: "Rp ${formatRupiah(saldo)}",
          color: const Color(0xFF393E46),
          textColor: const Color(0xFFDFD0B8),
        ),
        _buildSingleCard(
          title: "Pemasukan",
          value: "Rp ${formatRupiah(pemasukan)}",
          color: const Color(0xFFD0F0C0),
          textColor: const Color(0xFF2E7D32),
        ),
        _buildSingleCard(
          title: "Pengeluaran",
          value: "Rp ${formatRupiah(pengeluaran)}",
          color: const Color(0xFFFFCDD2),
          textColor: const Color(0xFFC62828),
        ),
      ],
    );
  }

  Widget _buildSingleCard({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Card(
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
