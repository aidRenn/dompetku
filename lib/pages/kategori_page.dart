import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dompetku/config/api.dart';
import 'package:dompetku/models/kategori.dart';
import 'package:dompetku/utils/session.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final _namaController = TextEditingController();
  final List<Kategori> _kategoriList = [];

  Future<void> _getKategori() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse(Api.getKategori),
        body: {'user_id': userId},
      );

      final res = jsonDecode(response.body);
      if (res['status'] == 200) {
        final List data = res['result'];
        setState(() {
          _kategoriList.clear();
          _kategoriList.addAll(data.map((e) => Kategori.fromJson(e)));
        });
      }
    } catch (e) {
      print("Get kategori error: $e");
    }
  }

  Future<void> _tambahKategori() async {
    final userId = await SessionManager.getUserId();
    final namaKategori = _namaController.text.trim();

    print("DEBUG: userId = $userId");
    print("DEBUG: namaKategori = $namaKategori");

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User belum login")));
      return;
    }

    if (namaKategori.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama kategori tidak boleh kosong")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Api.insertKategori),
        body: {'user_id': userId, 'nama_kategori': namaKategori},
      );

      print("DEBUG: Response = ${response.body}");

      final res = jsonDecode(response.body);
      if (res['status'] == 200) {
        _namaController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        _getKategori();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['result'] ?? 'Gagal menambahkan kategori'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Insert kategori error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat menambahkan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateKategori(int id, String namaBaru) async {
    try {
      final response = await http.post(
        Uri.parse(Api.updateKategori),
        body: {'id': id.toString(), 'nama_kategori': namaBaru},
      );

      final res = jsonDecode(response.body);
      if (res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kategori berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
        _getKategori();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['result'] ?? "Gagal memperbarui kategori"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Update kategori error: $e");
    }
  }

  Future<void> _deleteKategori(int id) async {
    try {
      final response = await http.post(
        Uri.parse(Api.delKategori),
        body: {'id': id.toString()},
      );

      final res = jsonDecode(response.body);
      if (res['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kategori berhasil dihapus"),
            backgroundColor: Colors.red,
          ),
        );
        _getKategori();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['result'] ?? "Gagal menghapus kategori"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Delete kategori error: $e");
    }
  }

  void _showEditDialog(Kategori kategori) {
    final _editController = TextEditingController(text: kategori.namaKategori);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Kategori"),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(hintText: "Nama baru"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = _editController.text.trim();
              if (newName.isNotEmpty) {
                _updateKategori(kategori.id, newName);
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Kategori kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kategori"),
        content: Text(
          "Hapus '${kategori.namaKategori}'? \nTransaksi yang terkait akan terhapus.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteKategori(kategori.id);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getKategori();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kelola Kategori",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFDFD0B8),
          ),
        ),
        backgroundColor: const Color(0xFF222831),
        iconTheme: const IconThemeData(color: Color(0xFFDFD0B8)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222831),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Nama kategori',
                      filled: true,
                      fillColor: const Color(0xFFFFF1DC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _tambahKategori,
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF393E46),
                    foregroundColor: const Color(0xFFDFD0B8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Daftar Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222831),
              ),
            ),
            const SizedBox(height: 12),
            if (_kategoriList.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "Belum ada kategori.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                itemCount: _kategoriList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final kategori = _kategoriList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1DC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFF393E46),
                      ),
                      title: Text(
                        kategori.namaKategori,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Color(0xFF222831),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(kategori);
                          } else if (value == 'delete') {
                            _confirmDelete(kategori);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ],
                        color: const Color(0xFFFFF1DC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
