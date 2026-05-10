import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('reports');

  // Fungsi 1: Update Status, Kirim Notifikasi, & Tampilkan Info Kontak
  Future<void> _prosesLaporan(BuildContext context, Map<dynamic, dynamic> item, String statusBaru) async {
    String idLaporan = item['id'];
    String namaBarang = item['namaBarang'] ?? 'Barang';
    String userIdLapor = item['userId'] ?? ''; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Update status laporan di database
      await FirebaseDatabase.instance.ref('reports/$idLaporan').update({'status': statusBaru});

      // 2. ---> KIRIM NOTIFIKASI UNTUK PELAPOR <---
      if (userIdLapor.isNotEmpty) {
        String judulNotif = statusBaru.toLowerCase() == 'ditolak' ? 'Laporan Ditolak' : 'Laporan Disetujui!';
        String pesanNotif = statusBaru.toLowerCase() == 'ditolak' 
            ? 'Maaf, proses klaim untuk "$namaBarang" tidak valid atau ditolak oleh Admin.'
            : 'Selamat! Laporan untuk "$namaBarang" telah diverifikasi dan disetujui.';

        await FirebaseDatabase.instance.ref('notifications').push().set({
          'userId': userIdLapor,
          'judul': judulNotif,
          'pesan': pesanNotif,
          'tipe': 'verifikasi',
          'status': 'unread',
          'createdAt': DateTime.now().toIso8601String().substring(0, 16).replaceFirst('T', ' '),
        });
      }

      // 3. Ambil data Pelapor dan Pengklaim
      String noHpPelapor = 'Tidak diketahui';
      String namaPelapor = 'Pembuat Laporan';
      String noHpPengklaim = 'Tidak diketahui';
      String namaPengklaim = 'Pengklaim';

      if (userIdLapor.isNotEmpty) {
        final pelaporSnap = await FirebaseDatabase.instance.ref('users/$userIdLapor').get();
        if (pelaporSnap.exists) {
          var dataPelapor = pelaporSnap.value as Map<dynamic, dynamic>;
          noHpPelapor = dataPelapor['noTelepon'] ?? dataPelapor['telepon'] ?? dataPelapor['noHp'] ?? 'Tidak ada nomor';
          namaPelapor = dataPelapor['nama'] ?? 'User Pelapor';
        }
      }

      final klaimSnap = await FirebaseDatabase.instance.ref('claims').orderByChild('reportId').equalTo(idLaporan).get();
      
      if (klaimSnap.exists) {
        Map<dynamic, dynamic> claimsMap = klaimSnap.value as Map<dynamic, dynamic>;
        var dataKlaim = claimsMap.values.first as Map<dynamic, dynamic>;
        String userIdKlaim = dataKlaim['userId'] ?? '';
        String idKlaimTerkait = claimsMap.keys.first.toString();

        // Update status di tabel klaim juga
        String statusKlaimDb = statusBaru.toLowerCase() == 'ditolak' ? 'Ditolak' : 'Selesai';
        await FirebaseDatabase.instance.ref('claims/$idKlaimTerkait').update({'status': statusKlaimDb});

        if (userIdKlaim.isNotEmpty) {
          final pengklaimSnap = await FirebaseDatabase.instance.ref('users/$userIdKlaim').get();
          if (pengklaimSnap.exists) {
            var dataUserKlaim = pengklaimSnap.value as Map<dynamic, dynamic>;
            noHpPengklaim = dataUserKlaim['noTelepon'] ?? dataUserKlaim['telepon'] ?? dataUserKlaim['noHp'] ?? 'Tidak ada nomor';
            namaPengklaim = dataUserKlaim['nama'] ?? 'User Pengklaim';
          }

          // 4. ---> KIRIM NOTIFIKASI UNTUK PENGKLAIM <---
          String judulNotifKlaim = statusBaru.toLowerCase() == 'ditolak' ? 'Klaim Ditolak' : 'Klaim Disetujui!';
          String pesanNotifKlaim = statusBaru.toLowerCase() == 'ditolak' 
              ? 'Maaf, bukti klaim Anda untuk "$namaBarang" tidak meyakinkan dan ditolak oleh Admin.'
              : 'Selamat! Bukti klaim Anda untuk "$namaBarang" disetujui. Silakan cek aplikasi untuk info lebih lanjut.';

          await FirebaseDatabase.instance.ref('notifications').push().set({
            'userId': userIdKlaim,
            'judul': judulNotifKlaim,
            'pesan': pesanNotifKlaim,
            'tipe': 'klaim',
            'status': 'unread',
            'createdAt': DateTime.now().toIso8601String().substring(0, 16).replaceFirst('T', ' '),
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog

      // 5. Tampilkan hasil akhirnya ke layar Admin
      if (statusBaru.toLowerCase() == 'ditolak') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan $namaBarang berhasil ditolak.'), backgroundColor: Colors.red),
        );
      } else {
        _tampilkanDialogKontak(context, namaBarang, namaPelapor, noHpPelapor, namaPengklaim, noHpPengklaim);
      }

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi 2: Tampilkan Bukti Klaim sebelum Admin setuju/tolak
  Future<void> _lihatBuktiKlaim(BuildContext context, Map<dynamic, dynamic> item) async {
    String idLaporan = item['id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final klaimSnap = await FirebaseDatabase.instance.ref('claims').orderByChild('reportId').equalTo(idLaporan).get();

      if (!mounted) return;
      Navigator.pop(context); 

      if (klaimSnap.exists) {
        Map<dynamic, dynamic> claimsMap = klaimSnap.value as Map<dynamic, dynamic>;
        var dataKlaim = claimsMap.values.first as Map<dynamic, dynamic>;
        String deskripsiBukti = dataKlaim['deskripsiBukti'] ?? 'Tidak ada deskripsi.';

        showDialog(
          context: context,
          builder: (dialogContext) { 
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Periksa Bukti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Keterangan dari pengaju:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(deskripsiBukti, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 10),
                  const Text('Apakah bukti ini valid dan meyakinkan?', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); 
                    _prosesLaporan(context, item, 'Ditolak'); 
                  },
                  child: const Text('Tolak Klaim', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    Navigator.pop(dialogContext); 
                    _prosesLaporan(context, item, 'Selesai'); 
                  },
                  child: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat data klaim.')));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Fungsi 3: Dialog Kontak (dipanggil jika klaim disetujui)
  void _tampilkanDialogKontak(BuildContext context, String namaBarang, String nama1, String hp1, String nama2, String hp2) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Klaim Disetujui!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hubungkan kedua belah pihak untuk barang "$namaBarang":', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pembuat Laporan:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(nama1, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(hp1, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pengaju Klaim / Penemu:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(nama2, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(hp2, style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
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
                  int totalMenungguKlaim = 0;
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
                      totalMenungguKlaim++;
                    }
                  });

                  listLaporan.sort((a, b) {
                    String statusA = (a['status'] ?? '').toString().toLowerCase();
                    String statusB = (b['status'] ?? '').toString().toLowerCase();

                    bool aAdaKlaim = statusA.contains('klaim') || statusA.contains('verifikasi');
                    bool bAdaKlaim = statusB.contains('klaim') || statusB.contains('verifikasi');

                    if (aAdaKlaim && !bAdaKlaim) return -1;
                    if (!aAdaKlaim && bAdaKlaim) return 1;

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
    
    String statusKecil = status.toLowerCase();
    bool butuhPersetujuanKlaim = statusKecil.contains('klaim') || statusKecil.contains('verifikasi');
    bool menungguUser = statusKecil == 'menunggu'; 

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
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
              
              if (butuhPersetujuanKlaim)
                ElevatedButton.icon(
                  onPressed: () => _lihatBuktiKlaim(context, item),
                  icon: const Icon(Icons.fact_check_outlined, size: 16, color: Colors.white),
                  label: const Text('Periksa Bukti', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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