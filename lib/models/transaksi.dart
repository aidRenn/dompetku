class Transaksi {
  final int id;
  final int userId;
  final int kategoriId;
  final String jenis;
  final double nominal;
  final String keterangan;
  final String tanggal;

  Transaksi({
    required this.id,
    required this.userId,
    required this.kategoriId,
    required this.jenis,
    required this.nominal,
    required this.keterangan,
    required this.tanggal,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: int.parse(json['id']),
      userId: int.parse(json['user_id']),
      kategoriId: int.parse(json['kategori_id']),
      jenis: json['jenis'],
      nominal: double.parse(json['nominal']),
      keterangan: json['keterangan'],
      tanggal: json['tanggal'],
    );
  }
}
