import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Wajib di-import untuk query langsung

// --- 1. MODEL KHUSUS UNTUK HALAMAN INI ---
// Menggabungkan Laporan dan Klaim agar bisa ditampilkan dalam satu List yang sama
class ItemAktivitas {
  final String id;
  final String judul;
  final String tanggal;
  final String status;
  final String tipe; // Isinya 'LAPORAN' atau 'KLAIM'
  final String jenisBarang; // 'hilang' atau 'ditemukan'

  ItemAktivitas({
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.status,
    required this.tipe,
    required this.jenisBarang,
  });
}

class StatusKlaimPage extends StatefulWidget {
  const StatusKlaimPage({super.key});

  @override
  State<StatusKlaimPage> createState() => _StatusKlaimPageState();
}

class _StatusKlaimPageState extends State<StatusKlaimPage> {
  // 2. VARIABEL PENAMPUNG DATA TERPADU
  List<ItemAktivitas> daftarAktivitas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataStatus();
  }

  // 3. FUNGSI QUERY EFISIEN & PENGGABUNGAN DATA
  Future<void> _ambilDataStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        setState(() => isLoading = false);
        return;
      }

      String uid = currentUser.uid;
      List<ItemAktivitas> tempList = [];
      final db = FirebaseDatabase.instance.ref();

      // --- A. QUERY EFISIEN UNTUK LAPORAN ---
      // Hanya menyuruh Firebase mencari data yang userId-nya cocok (Sangat Cepat & Hemat)
      final laporanSnapshot = await db.child('reports').orderByChild('userId').equalTo(uid).get();
      
      if (laporanSnapshot.exists) {
        Map<dynamic, dynamic> reportsMap = laporanSnapshot.value as Map<dynamic, dynamic>;
        reportsMap.forEach((key, value) {
          tempList.add(ItemAktivitas(
            id: key.toString(),
            judul: value['namaBarang'] ?? 'Tanpa Nama',
            // Gunakan createdAt jika ada, jika tidak pakai tanggalKejadian
            tanggal: value['createdAt'] ?? value['tanggalKejadian'] ?? '-',
            status: value['status'] ?? 'menunggu',
            tipe: 'LAPORAN',
            jenisBarang: value['jenis']?.toString().toLowerCase() ?? 'hilang',
          ));
        });
      }

      // --- B. QUERY EFISIEN UNTUK KLAIM ---
      final klaimSnapshot = await db.child('claims').orderByChild('userId').equalTo(uid).get();
      
      if (klaimSnapshot.exists) {
        Map<dynamic, dynamic> claimsMap = klaimSnapshot.value as Map<dynamic, dynamic>;
        
        for (var entry in claimsMap.entries) {
          String claimId = entry.key;
          var claimData = entry.value;
          String reportId = claimData['reportId'] ?? '';

          // KARENA KLAIM HANYA PUNYA reportId, KITA HARUS CARI NAMA BARANGNYA
          String namaBarangDiklaim = 'Barang Laporan';
          String jenisBarang = 'hilang';
          
          if (reportId.isNotEmpty) {
            final parentReportSnap = await db.child('reports/$reportId').get();
            if (parentReportSnap.exists) {
              var parentData = parentReportSnap.value as Map<dynamic, dynamic>;
              namaBarangDiklaim = parentData['namaBarang'] ?? 'Tanpa Nama';
              jenisBarang = parentData['jenis']?.toString().toLowerCase() ?? 'hilang';
            }
          }

          tempList.add(ItemAktivitas(
            id: claimId,
            judul: namaBarangDiklaim,
            tanggal: claimData['createdAt'] ?? '-',
            status: claimData['status'] ?? 'menunggu',
            tipe: 'KLAIM', // Menandakan ini adalah barang yang kita klaim
            jenisBarang: jenisBarang,
          ));
        }
      }

      // --- C. URUTKAN DATA ---
      // Urutkan dari yang terbaru ke terlama berdasarkan string tanggal (ISO8601)
      tempList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      setState(() {
        daftarAktivitas = tempList;
        isLoading = false;
      });

    } catch (e) {
      print("Gagal mengambil status: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoHeader(),
                    const SizedBox(height: 24),
                    const Text(
                      'Status Barang',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Pantau status laporan dan klaim barang Anda.',
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 25),

                    if (daftarAktivitas.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'Anda belum membuat laporan atau klaim apa pun.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ...daftarAktivitas.map((aktivitas) {
                        // WARNA STATUS
                        Color warnaStatus;
                        String teksStatus = aktivitas.status.toUpperCase();
                        
                        if (teksStatus == 'SELESAI') {
                          warnaStatus = Colors.green;
                        } else if (teksStatus == 'TERVERIFIKASI' || teksStatus == 'DITERIMA') {
                          warnaStatus = Colors.blue;
                        } else if (teksStatus == 'DITOLAK') {
                          warnaStatus = Colors.red;
                        } else {
                          warnaStatus = Colors.orange; 
                        }

                        // FORMAT TANGGAL SIMPEL UNTUK UI (Potong jam-nya jika format ISO)
                        String tanggalUI = aktivitas.tanggal.length > 10 
                            ? aktivitas.tanggal.substring(0, 10) 
                            : aktivitas.tanggal;

                        return _buildStatusCard(
                          context: context,
                          itemName: aktivitas.judul,
                          claimDate: tanggalUI,
                          status: teksStatus,
                          statusColor: warnaStatus,
                          tipe: aktivitas.tipe, // Kirim tipe untuk membedakan UI
                          icon: aktivitas.jenisBarang == 'hilang' 
                              ? Icons.search_off 
                              : Icons.inventory_2_outlined,
                        );
                      }).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle),
          child: const Icon(Icons.search, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          'LOSTLINK',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  // WIDGET CARD DIMODIFIKASI UNTUK MENAMPILKAN LABEL 'LAPORAN' ATAU 'KLAIM'
  Widget _buildStatusCard({
    required BuildContext context,
    required String itemName,
    required String claimDate,
    required String status,
    required Color statusColor,
    required String tipe,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Beda warna icon dikit biar ada variasi antara Laporan dan Klaim
                  color: tipe == 'LAPORAN' ? Colors.blue.shade50 : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: tipe == 'LAPORAN' ? Colors.blue : Colors.purple, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BADGE KECIL UNTUK MEMBEDAKAN TIPE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tipe == 'LAPORAN' ? Colors.blue.shade100 : Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tipe,
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold,
                          color: tipe == 'LAPORAN' ? Colors.blue.shade800 : Colors.purple.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: $claimDate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STATUS',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Munculkan Bottom Sheet Detail
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Detail $tipe: $itemName',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Divider(height: 30),
                            Text(
                              '• Tanggal: $claimDate',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              tipe == 'LAPORAN' 
                                ? 'Ini adalah laporan yang Anda publikasikan.' 
                                : 'Ini adalah pengajuan klaim Anda terhadap laporan ini.',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              '• Status Saat Ini',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              status,
                              style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tutup'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  side: BorderSide(color: Colors.blue.shade100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                child: const Text('Detail', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}