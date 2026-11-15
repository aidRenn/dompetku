class User {
  int id;
  String nama;
  String email;
  String? password;

  User({
    required this.id,
    required this.nama,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id']),
      nama: json['nama'],
      email: json['email'],
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'nama': nama,
    'email': email,
    'password': password ?? '',
  };
}
