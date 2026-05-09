import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart'; // Memanggil cetakan User

class AuthService {
  // Buka koneksi ke Auth (Keamanan) dan DB (Database)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ===============================================
  // 1. FUNGSI UNTUK DAFTAR (REGISTER)
  // ===============================================
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String nama,
    required int noTelepon,
  }) async {
    try {
      // 1. Daftarkan email & password ke Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // 2. Buat objek User baru menggunakan cetakan UserModel
      UserModel userBaru = UserModel(
        id: userId,
        email: email,
        nama: nama,
        noTelepon: noTelepon,
        role: 'user', // Default saat daftar adalah 'user' biasa
      );

      // 3. Simpan data lengkapnya ke tabel 'users' di Realtime Database
      await _db.child('users').child(userId).set(userBaru.toJson());
      
      print('Berhasil: Akun baru didaftarkan!');
      return userBaru;
    } catch (e) {
      print('Gagal mendaftar: $e');
      return null;
    }
  }

  // ===============================================
  // 2. FUNGSI UNTUK MASUK (LOGIN)
  // ===============================================
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      // 1. Cek email & password di Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // 2. Tarik data lengkapnya (seperti role admin/user) dari Realtime DB
      DataSnapshot snapshot = await _db.child('users').child(userId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        print('Berhasil: Login sukses!');
        
        // Ubah JSON dari database menjadi Objek UserModel
        return UserModel.fromJson(data, userId);
      } else {
        print('Gagal: Data user tidak ditemukan di database.');
        return null;
      }
    } catch (e) {
      print('Gagal login: $e');
      return null;
    }
  }

  // ===============================================
  // 3. FUNGSI UNTUK KELUAR (LOGOUT)
  // ===============================================
  Future<void> logout() async {
    await _auth.signOut();
    print('Berhasil: Logout sukses!');
  }
}