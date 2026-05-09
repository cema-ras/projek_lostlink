import 'package:firebase_database/firebase_database.dart';
import '../models/report_model.dart'; // Memanggil cetakan yang kamu buat tadi

class ReportService {
  // Membuka koneksi ke Firebase Realtime Database
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 1. FUNGSI UNTUK MENAMBAH LAPORAN BARU
  Future<void> tambahLaporan(ReportModel laporan) async {
    try {
      // Membuat ID baru secara otomatis di tabel 'reports'
      DatabaseReference refBaru = _db.child('reports').push();
      
      // Mengirim data ke Firebase menggunakan fungsi toJson() dari modelmu
      await refBaru.set(laporan.toJson());
      
      print('Berhasil: Laporan barang ditambahkan ke Firebase!');
    } catch (e) {
      print('Gagal menambah laporan: $e');
    }
  }

  // 2. FUNGSI UNTUK MENGAMBIL SEMUA DAFTAR LAPORAN
  Future<List<ReportModel>> ambilSemuaLaporan() async {
    List<ReportModel> daftarLaporan = [];
    try {
      DataSnapshot snapshot = await _db.child('reports').get();
      
      if (snapshot.exists) {
        // Jika data ada, kita ubah JSON berantakan menjadi list Objek yang rapi
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        
        values.forEach((key, value) {
          // Memasukkan data ke dalam cetakan ReportModel menggunakan fromJson()
          ReportModel laporan = ReportModel.fromJson(value, key);
          daftarLaporan.add(laporan);
        });
      }
    } catch (e) {
      print('Gagal mengambil laporan: $e');
    }
    return daftarLaporan;
  }
}