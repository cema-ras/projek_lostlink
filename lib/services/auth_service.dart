import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart'; 
import '../models/user_model.dart'; 

class AuthService {
  // Buka koneksi ke Auth dan Realtime Database
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.refFromURL("https://lostlink-536b9-default-rtdb.asia-southeast1.firebasedatabase.app/");
  
  // Inisialisasi GoogleSignIn satu kali agar bisa dipanggil berulang (Logout & Login)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '592999106220-97av2ckve1327qm6gbmq01ogjdnmevs4.apps.googleusercontent.com',
  );

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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      UserModel userBaru = UserModel(
        id: userId,
        email: email,
        nama: nama,
        noTelepon: noTelepon,
        role: 'user',
        jurusan: "-", // Nilai default saat pertama daftar manual
      );

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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      DataSnapshot snapshot = await _db.child('users').child(userId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        print('Berhasil: Login sukses!');
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
  // 3. FUNGSI UNTUK LOGIN GOOGLE (SSO) - FIKS!
  // ===============================================
  Future<UserModel?> loginDenganGoogle() async {
    try {
      // 1. Memunculkan pop-up pilihan akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Dibatalkan: User tidak jadi login Google.');
        return null; 
      }

      // 2. Mengambil kunci akses dari Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Masuk ke Firebase Authentication
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      String userId = userCredential.user!.uid;

      // 4. Cek database
      DataSnapshot snapshot = await _db.child('users').child(userId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        print('Berhasil: Login Google (User Lama) sukses!');
        return UserModel.fromJson(data, userId);
      } else {
        // JIKA PENGGUNA BARU:
        UserModel userBaru = UserModel(
          id: userId,
          email: userCredential.user!.email ?? '',
          nama: userCredential.user!.displayName ?? 'User Google',
          noTelepon: 0, 
          role: 'user',
          jurusan: "-", // Tambahkan jurusan default
        );

        await _db.child('users').child(userId).set(userBaru.toJson());
        print('Berhasil: Akun baru Google didaftarkan!');
        return userBaru;
      }
    } catch (e) {
      print('Gagal Login Google: $e');
      return null;
    }
  }

  // ===============================================
  // 4. FUNGSI UPDATE DATA USER (UNTUK EDIT PROFIL)
  // ===============================================
  Future<bool> updateUserProfile({
    required String userId,
    required String namaBaru,
    required int noTeleponBaru,
    required String jurusanBaru,
  }) async {
    try {
      // Menggunakan .update() agar tidak menimpa data yang tidak diedit (seperti email)
      await _db.child('users').child(userId).update({
        'nama': namaBaru,
        'noTelepon': noTeleponBaru,
        'jurusan': jurusanBaru,
      });

      print('Berhasil: Profil diperbarui di Database!');
      return true; // Kembalikan true jika berhasil disimpan
    } catch (e) {
      print('Gagal update profil: $e');
      return false; // Kembalikan false jika ada error
    }
  }

  // ===============================================
  // 5. FUNGSI UNTUK KELUAR (LOGOUT)
  // ===============================================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); 
      print('Berhasil: Logout sukses!');
    } catch (e) {
      print('Error saat logout: $e');
    }
  }
}