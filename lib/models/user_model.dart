class UserModel {
  final String id; // ID unik dari Firebase (userId)
  final String email;
  final String nama;
  final int noTelepon;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.noTelepon,
    required this.role,
  });

  // Fungsi untuk mengubah data dari Firebase ke objek UserModel di Flutter
  factory UserModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      noTelepon: json['noTelepon'] ?? 0,
      role: json['role'] ?? 'user', // Default role adalah 'user'
    );
  }

  // Fungsi untuk mengubah objek UserModel dari Flutter ke format Firebase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nama': nama,
      'noTelepon': noTelepon,
      'role': role,
    };
  }
}