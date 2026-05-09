import 'package:firebase_database/firebase_database.dart';
import '../models/claim_model.dart'; // Ingat, pakai 's' di kata models ya!

class ClaimService {
  // Buka koneksi ke Database
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ===============================================
  // 1. FUNGSI UNTUK MENGAJUKAN KLAIM BARANG
  // ===============================================
  Future<void> ajukanKlaim(ClaimModel klaim) async {
    try {
      // Membuat ID baru otomatis untuk klaim di tabel 'claims'
      DatabaseReference refBaru = _db.child('claims').push();
      
      // Kirim datanya ke Firebase
      await refBaru.set(klaim.toJson());
      
      print('Berhasil: Pengajuan klaim berhasil dikirim!');
    } catch (e) {
      print('Gagal mengajukan klaim: $e');
    }
  }

  // ===============================================
  // 2. FUNGSI UNTUK PETUGAS (TERIMA/TOLAK KLAIM)
  // ===============================================
  Future<void> updateStatusKlaim(String claimId, String statusBaru) async {
    try {
      // statusBaru isinya bisa: 'diterima' atau 'ditolak'
      await _db.child('claims').child(claimId).update({
        'status': statusBaru
      });
      
      print('Berhasil: Status klaim diubah menjadi $statusBaru!');
    } catch (e) {
      print('Gagal mengubah status klaim: $e');
    }
  }
}