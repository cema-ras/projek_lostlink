class ClaimModel {
  final String id; // ID unik klaim (claimId)
  final String buktiFoto;
  final String createdAt;
  final String deskripsiBukti;
  final String reportId; // ID laporan barang yang diklaim
  final String status; // 'menunggu', 'diterima', atau 'ditolak'
  final String userId; // ID user yang melakukan klaim

  ClaimModel({
    required this.id,
    required this.buktiFoto,
    required this.createdAt,
    required this.deskripsiBukti,
    required this.reportId,
    required this.status,
    required this.userId,
  });

  // Mengubah JSON dari Firebase ke Objek Flutter
  factory ClaimModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return ClaimModel(
      id: id,
      buktiFoto: json['buktiFoto'] ?? '',
      createdAt: json['createdAt'] ?? '',
      deskripsiBukti: json['deskripsiBukti'] ?? '',
      reportId: json['reportId'] ?? '',
      // Catatan: Di databasemu sebelumnya ada spasi "status ". 
      // Kita ambil keduanya untuk berjaga-jaga jika belum kamu perbaiki di Firebase.
      status: json['status'] ?? json['status '] ?? 'menunggu', 
      userId: json['userId'] ?? '',
    );
  }

  // Mengubah Objek Flutter ke JSON untuk Firebase
  Map<String, dynamic> toJson() {
    return {
      'buktiFoto': buktiFoto,
      'createdAt': createdAt,
      'deskripsiBukti': deskripsiBukti,
      'reportId': reportId,
      'status': status,
      'userId': userId,
    };
  }
}