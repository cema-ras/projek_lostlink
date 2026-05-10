class UserModel {
  final String id; // ID unik dari Firebase (userId)
  final String email;
  final String nama;
  final int noTelepon;
  final String role;
  final String jurusan; // TAMBAHAN: Field baru untuk jurusan

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.noTelepon,
    required this.role,
    required this.jurusan, // TAMBAHAN: Wajib diisi saat membuat objek
  });

  // Fungsi untuk mengubah data dari Firebase ke objek UserModel di Flutter
  factory UserModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'] ?? '',
      nama: json['nama'] ?? '',
      // Menangani jika noTelepon tersimpan sebagai String di DB agar tidak crash
      noTelepon: json['noTelepon'] is int ? json['noTelepon'] : int.tryParse(json['noTelepon'].toString()) ?? 0,
      role: json['role'] ?? 'user',
      jurusan: json['jurusan'] ?? '-', // Jika kosong di DB, tampilkan tanda strip
    );
  }

  // Fungsi untuk mengubah objek UserModel dari Flutter ke format Firebase (JSON)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nama': nama,
      'noTelepon': noTelepon,
      'role': role,
      'jurusan': jurusan, // TAMBAHAN: Agar tersimpan ke database
    };
  }
}