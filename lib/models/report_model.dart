class ReportModel {
  final String id; // ID unik laporan dari Firebase (reportId)
  final String namaBarang;
  final String deskripsi;
  final String fotoUrl;
  final String jenis; // isinya: 'hilang' atau 'temuan'
  final String kategoriId;
  final String lokasi;
  final String status; // isinya: 'menunggu', 'terverifikasi', atau 'selesai'
  final String tanggalKejadian;
  final String userId; // ID orang yang membuat laporan

  ReportModel({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.fotoUrl,
    required this.jenis,
    required this.kategoriId,
    required this.lokasi,
    required this.status,
    required this.tanggalKejadian,
    required this.userId,
  });

  // Mengubah data dari Firebase (JSON) ke bentuk Objek di Flutter
  factory ReportModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return ReportModel(
      id: id,
      namaBarang: json['namaBarang'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      fotoUrl: json['fotoUrl'] ?? '',
      jenis: json['jenis'] ?? '',
      kategoriId: json['kategoriId'] ?? '',
      lokasi: json['lokasi'] ?? '',
      status: json['status'] ?? 'menunggu', // Default status saat baru dibuat
      tanggalKejadian: json['tanggalKejadian'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  // Mengubah objek dari Flutter ke bentuk JSON untuk disimpan ke Firebase
  Map<String, dynamic> toJson() {
    return {
      'namaBarang': namaBarang,
      'deskripsi': deskripsi,
      'fotoUrl': fotoUrl,
      'jenis': jenis,
      'kategoriId': kategoriId,
      'lokasi': lokasi,
      'status': status,
      'tanggalKejadian': tanggalKejadian,
      'userId': userId,
    };
  }
}