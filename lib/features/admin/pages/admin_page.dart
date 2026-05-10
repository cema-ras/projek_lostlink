import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('reports');

  // Fungsi Update Status & Kirim Notifikasi Sekaligus
  Future<void> _prosesLaporan(BuildContext context, Map<dynamic, dynamic> item, String statusBaru) async {
    String idLaporan = item['id'];
    String namaBarang = item['namaBarang'] ?? 'Barang';
    String userIdLapor = item['userId'] ?? ''; 

    try {
      await FirebaseDatabase.instance.ref('reports/$idLaporan').update({'status': statusBaru});

      if (userIdLapor.isNotEmpty) {
        String kataStatus = statusBaru.toLowerCase() == 'ditolak' ? 'DITOLAK' : 'DISETUJUI';
        String pesan = statusBaru.toLowerCase() == 'ditolak' 
            ? 'Maaf, klaim/laporan untuk "$namaBarang" ditolak oleh Admin.'
            : 'Selamat! Klaim/laporan untuk "$namaBarang" telah disetujui.';

      }

      if (mounted) {
        Color warnaNotif = statusBaru.toLowerCase() == 'ditolak' ? Colors.red : Colors.green;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan $namaBarang ${statusBaru.toLowerCase()}.'), backgroundColor: warnaNotif),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 24),
              const Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Kelola persetujuan klaim dan status laporan.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              StreamBuilder(
                stream: _dbRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }

                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Belum ada data laporan.')));
                  }

                  Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> listLaporan = [];
                  
                  int totalLaporan = 0;
                  int totalMenungguKlaim = 0; // Untuk status menunggu (belum ada klaim)
                  int totalSelesai = 0;
                  int totalDitolak = 0;

                  dataMap.forEach((key, value) {
                    var item = value as Map<dynamic, dynamic>;
                    item['id'] = key; 
                    listLaporan.add(item);
                    
                    totalLaporan++;
                    String status = (item['status'] ?? '').toString().toLowerCase();
                    
                    if (status.contains('selesai') || status.contains('disetujui') || status.contains('aktif')) {
                      totalSelesai++;
                    } else if (status.contains('ditolak')) {
                      totalDitolak++;
                    } else {
                      totalMenungguKlaim++; // Dihitung sebagai belum diproses sepenuhnya
                    }
                  });

                  // LOGIKA SORTING BARU: 
                  // 1. Yang sedang ada pengajuan Klaim/Verifikasi di posisi paling atas
                  // 2. Jika sama, urutkan dari yang terbaru (berdasarkan ID Firebase)
                  listLaporan.sort((a, b) {
                    String statusA = (a['status'] ?? '').toString().toLowerCase();
                    String statusB = (b['status'] ?? '').toString().toLowerCase();

                    // Asumsi: jika status berubah mengandung kata 'klaim' atau 'verifikasi', berarti ada pengajuan klaim masuk
                    bool aAdaKlaim = statusA.contains('klaim') || statusA.contains('verifikasi');
                    bool bAdaKlaim = statusB.contains('klaim') || statusB.contains('verifikasi');

                    if (aAdaKlaim && !bAdaKlaim) return -1; // A naik ke atas
                    if (!aAdaKlaim && bAdaKlaim) return 1;  // B naik ke atas

                    // Jika prioritas sama, urutkan dari yang terbaru (Z to A)
                    return b['id'].toString().compareTo(a['id'].toString());
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(count: '$totalLaporan', label: 'Total Laporan', icon: Icons.assignment_outlined, color: Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(count: '$totalMenungguKlaim', label: 'Belum Selesai', icon: Icons.pending_actions, color: Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(count: '$totalSelesai', label: 'Selesai', icon: Icons.assignment_turned_in_outlined, color: Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(count: '$totalDitolak', label: 'Ditolak', icon: Icons.cancel_outlined, color: Colors.red)),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      const Text('LAPORAN MASUK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 14),

                      ListView.builder(
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listLaporan.length,
                        itemBuilder: (context, index) {
                          var item = listLaporan[index];
                          
                          Color iconColor = item['jenis'].toString().toLowerCase() == 'hilang' ? Colors.red : Colors.blue;
                          IconData iconTipe = item['jenis'].toString().toLowerCase() == 'hilang' ? Icons.wallet_outlined : Icons.laptop_mac;

                          return _buildReportCard(
                            context,
                            item: item, 
                            itemName: item['namaBarang'] ?? 'Tanpa Nama',
                            reportType: item['jenis'].toString().toUpperCase(),
                            location: item['lokasi'] ?? '-',
                            date: item['tanggalKejadian'] ?? '-',
                            status: item['status'] ?? 'Menunggu',
                            color: iconColor,
                            icon: iconTipe,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
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
        const SizedBox(width: 10),
        const Text('LOSTLINK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildStatCard({required String count, required String label, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
          const SizedBox(height: 14),
          Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required Map<dynamic, dynamic> item, 
    required String itemName,
    required String reportType,
    required String location,
    required String date,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    
    // Mengecek spesifik kondisi status untuk tombol
    String statusKecil = status.toLowerCase();
    
    // Tombol hanya muncul jika ada indikasi klaim masuk
    bool butuhPersetujuanKlaim = statusKecil.contains('klaim') || statusKecil.contains('verifikasi');
    // Cek jika status murni "menunggu" tanpa ada klaim
    bool menungguUser = statusKecil == 'menunggu'; 

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          // Beri border biru muda agar admin langsung tahu mana yang butuh persetujuan
          color: butuhPersetujuanKlaim ? Colors.blue.shade300 : Colors.grey.shade200,
          width: butuhPersetujuanKlaim ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('$location • $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Text(reportType, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: (menungguUser || butuhPersetujuanKlaim) ? Colors.orange 
                       : statusKecil.contains('tolak') ? Colors.red 
                       : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // LOGIKA TOMBOL BARU
              if (butuhPersetujuanKlaim)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _prosesLaporan(context, item, 'Selesai'), // Ubah status menjadi selesai jika disetujui
                      child: const Text('Setujui', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => _prosesLaporan(context, item, 'Ditolak'),
                      child: const Text('Tolak', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              else if (menungguUser)
                const Text(
                  'Menunggu Klaim User', 
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                )
              else
                const Text(
                  'Telah Diproses', 
                  style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ],
      ),
    );
  }
}