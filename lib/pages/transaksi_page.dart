import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dompetku/config/api.dart';
import 'package:dompetku/models/transaksi.dart';
import 'package:dompetku/utils/session.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final List<Transaksi> _transaksiList = [];
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _tanggalController = TextEditingController();

  String _jenis = 'pemasukan';
  int? _selectedKategoriId;
  List<Map<String, dynamic>> _kategoriList = [];

  final formatRupiah = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final formatTanggalTampil = DateFormat('dd-MM-yyyy');
  final formatTanggalKirim = DateFormat('yyyy-MM-dd');
  final formatTanggalInput = DateFormat('dd-MM-yyyy');

  String? _userId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final userId = await SessionManager.getUserId();
    if (userId == null || userId.isEmpty) {
      print("User ID belum tersedia");
      return;
    }

    _userId = userId;
    await _getKategori();
    await _getTransaksi();
  }

  Future<void> _getKategori() async {
    final res = await http.post(
      Uri.parse(Api.getKategori),
      body: {'user_id': _userId},
    );
    final data = jsonDecode(res.body);
    if (data['status'] == 200) {
      setState(() {
        _kategoriList = List<Map<String, dynamic>>.from(data['result']);
        if (_kategoriList.isNotEmpty) {
          _selectedKategoriId = int.parse(_kategoriList[0]['id']);
        }
      });
    }
  }

  Future<void> _getTransaksi() async {
    try {
      final response = await http.post(
        Uri.parse(Api.getTransaksi),
        body: {'user_id': _userId},
      );
      final res = jsonDecode(response.body);

      if (res['status'] == 200) {
        final List data = res['result'];
        setState(() {
          _transaksiList.clear();
          _transaksiList.addAll(data.map((e) => Transaksi.fromJson(e)));
        });
      }
    } catch (e) {
      print("Get transaksi error: $e");
    }
  }

  Future<void> _submitTransaksi({int? id}) async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    String tanggalIso = '';
    try {
      final parsed = formatTanggalInput.parse(_tanggalController.text);
      tanggalIso = formatTanggalKirim.format(parsed);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Format tanggal salah')));
      return;
    }

    final url = id == null ? Api.insertTransaksi : Api.updateTransaksi;
    final body = {
      'user_id': _userId,
      'kategori_id': _selectedKategoriId.toString(),
      'jenis': _jenis,
      'nominal': _nominalController.text,
      'keterangan': _keteranganController.text,
      'tanggal': tanggalIso,
    };
    if (id != null) body['id'] = id.toString();

    try {
      final res = await http.post(Uri.parse(url), body: body);
      final data = jsonDecode(res.body);
      if (data['status'] == 200) {
        Navigator.pop(context);
        _getTransaksi();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              id == null
                  ? 'Berhasil menambah transaksi'
                  : 'Berhasil mengubah transaksi',
            ),
          ),
        );
      }
    } catch (e) {
      print("Submit transaksi error: $e");
    }
  }

  void _showBottomSheet({Transaksi? transaksi}) {
    if (transaksi != null) {
      _nominalController.text = transaksi.nominal.toStringAsFixed(0);
      _keteranganController.text = transaksi.keterangan;

      try {
        final parsed = DateTime.parse(transaksi.tanggal);
        _tanggalController.text = formatTanggalInput.format(parsed);
      } catch (_) {
        _tanggalController.text = transaksi.tanggal;
      }

      _jenis = transaksi.jenis;
      _selectedKategoriId = transaksi.kategoriId;
    } else {
      _nominalController.clear();
      _keteranganController.clear();
      _tanggalController.clear();
      _jenis = 'pemasukan';
      if (_kategoriList.isNotEmpty) {
        _selectedKategoriId = int.parse(_kategoriList[0]['id']);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFDFD0B8),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    transaksi == null ? 'Tambah Transaksi' : 'Edit Transaksi',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF222831),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Kategori
                Text(
                  'Kategori',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                DropdownButtonFormField(
                  value: _selectedKategoriId,
                  onChanged: (val) =>
                      setState(() => _selectedKategoriId = val as int),
                  items: _kategoriList.map((e) {
                    return DropdownMenuItem(
                      value: int.parse(e['id']),
                      child: Text(e['nama_kategori']),
                    );
                  }).toList(),
                  dropdownColor: Color(0xFFFFF1DC),
                  decoration: InputDecoration(
                    hintText: 'Kategori',
                    filled: true,
                    fillColor: Color(0xFFFFF1DC),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Jenis
                Text(
                  'Jenis',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                DropdownButtonFormField(
                  value: _jenis,
                  onChanged: (val) => setState(() => _jenis = val.toString()),
                  items: ['pemasukan', 'pengeluaran'].map((jenis) {
                    return DropdownMenuItem(value: jenis, child: Text(jenis));
                  }).toList(),
                  dropdownColor: Color(0xFFFFF1DC),
                  decoration: InputDecoration(
                    hintText: 'Jenis',
                    filled: true,
                    fillColor: Color(0xFFFFF1DC),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Nominal
                Text(
                  'Nominal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Rp.',
                    filled: true,
                    fillColor: Color(0xFFFFF1DC),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Isi nominal' : null,
                ),
                const SizedBox(height: 12),

                // Keterangan
                Text(
                  'Keterangan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _keteranganController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFFFF1DC),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Tanggal
                Text(
                  'Tanggal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _tanggalController,
                  decoration: InputDecoration(
                    hintText: '(DD-MM-YYYY)',
                    filled: true,
                    fillColor: Color(0xFFFFF1DC),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Isi tanggal' : null,
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _submitTransaksi(id: transaksi?.id),
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF393E46),
                      foregroundColor: const Color(0xFFDFD0B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTransaksi(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        backgroundColor: const Color(0xFFDFD0B8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Hapus'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return; // batal

    // lanjut hapus jika user konfirmasi
    final res = await http.post(
      Uri.parse(Api.delTransaksi),
      body: {'id': id.toString()},
    );
    final data = jsonDecode(res.body);
    if (data['status'] == 200) {
      _getTransaksi();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menghapus transaksi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF222831),
        title: const Text(
          "Kelola Transaksi",
          style: TextStyle(
            color: Color(0xFFDFD0B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFDFD0B8)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(),
        backgroundColor: const Color(0xFF393E46),
        foregroundColor: const Color(0xFFDFD0B8),
        child: const Icon(Icons.add),
      ),
      body: _transaksiList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada transaksi',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _transaksiList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _transaksiList[index];
                final kategoriNama = _kategoriList.firstWhere(
                  (e) => int.parse(e['id']) == item.kategoriId,
                  orElse: () => {'nama_kategori': 'Tidak diketahui'},
                )['nama_kategori'];

                final parsedTanggal = DateTime.tryParse(item.tanggal);
                final tampilanTanggal = parsedTanggal != null
                    ? formatTanggalTampil.format(parsedTanggal)
                    : item.tanggal;

                final isPemasukan = item.jenis.toLowerCase() == 'pemasukan';

                return Container(
                  decoration: BoxDecoration(
                    color: isPemasukan ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPemasukan ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      formatRupiah.format(item.nominal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPemasukan
                            ? Colors.green[800]
                            : Colors.red[800],
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "${item.jenis.toUpperCase()} - ${item.keterangan.isEmpty ? '(Tanpa Keterangan)' : item.keterangan}\n"
                        "Kategori: $kategoriNama | Tanggal: $tampilanTanggal",
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showBottomSheet(transaksi: item);
                        } else if (value == 'delete') {
                          _deleteTransaksi(item.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text("Edit")),
                        PopupMenuItem(value: 'delete', child: Text("Hapus")),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
