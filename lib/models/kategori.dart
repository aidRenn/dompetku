class Kategori {
  int id;
  int userId;
  String namaKategori;

  Kategori({
    required this.id,
    required this.userId,
    required this.namaKategori,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
    id: int.parse(json['id']),
    userId: int.parse(json['user_id']),
    namaKategori: json['nama_kategori'],
  );

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'user_id': userId.toString(),
    'nama_kategori': namaKategori,
  };
}
