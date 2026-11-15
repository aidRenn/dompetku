import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dompetku/config/api.dart';
import 'package:dompetku/utils/session.dart';

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  List<Map<String, dynamic>> _catatanList = [];
  final TextEditingController _isiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final id = await SessionManager.getUserId();
    if (id == null || id.isEmpty) return;
    _userId = id;
    _getCatatan();
  }

  Future<void> _getCatatan() async {
    try {
      final res = await http.post(
        Uri.parse(Api.getCatatan),
        body: {'user_id': _userId},
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 200) {
        setState(() {
          _catatanList = List<Map<String, dynamic>>.from(data['result']);
        });
      }
    } catch (e) {
      print("Get catatan error: $e");
    }
  }

  Future<void> _submitCatatan({int? id}) async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    final url = id == null ? Api.insertCatatan : Api.updateCatatan;
    final body = {'user_id': _userId!, 'isi': _isiController.text};
    if (id != null) body['id'] = id.toString();

    try {
      final res = await http.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['status'] == 200) {
        Navigator.pop(context);
        _getCatatan();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              id == null
                  ? 'Catatan berhasil ditambahkan'
                  : 'Catatan berhasil diperbarui',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Submit catatan error: $e");
    }
  }

  Future<void> _deleteCatatan(int id) async {
    try {
      final res = await http.post(
        Uri.parse(Api.delCatatan),
        body: {'id': id.toString()},
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 200) {
        _getCatatan();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Delete catatan error: $e");
    }
  }

  void _showBottomSheet({Map<String, dynamic>? catatan}) {
    if (catatan != null) {
      _isiController.text = catatan['isi'] ?? '';
    } else {
      _isiController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFFDFD0B8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                catatan == null ? 'Tambah Catatan' : 'Edit Catatan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _isiController,
                maxLines: 5,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _submitCatatan(
                  id: catatan != null
                      ? int.tryParse(catatan['id'].toString())
                      : null,
                ),
                child: const Text('Simpan'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCatatan(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus catatan ini?'),
        backgroundColor: const Color(0xFFDFD0B8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCatatan(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan',
          style: TextStyle(
            color: Color(0xFFDFD0B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF222831),
        iconTheme: const IconThemeData(color: Color(0xFFDFD0B8)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(),
        backgroundColor: const Color(0xFF393E46),
        foregroundColor: const Color(0xFFDFD0B8),
        child: const Icon(Icons.add),
      ),
      backgroundColor: const Color(0xFFDFD0B8),
      body: _catatanList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada catatan',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _catatanList.length,
              itemBuilder: (context, index) {
                final item = _catatanList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1DC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      item['isi'] ?? '-',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF222831),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showBottomSheet(catatan: item);
                        } else if (value == 'delete') {
                          final id = int.tryParse(item['id'].toString());
                          if (id != null) _confirmDeleteCatatan(id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
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
    );
  }
}
