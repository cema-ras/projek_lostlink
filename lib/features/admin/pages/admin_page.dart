import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Tambahan untuk Firebase

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Referensi ke database Firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('reports');

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
              const Text('Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Kelola laporan barang hilang, barang temuan, dan klaim pengguna.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // KITA BUNGKUS DARI STATISTIK SAMPAI DAFTAR LAPORAN DENGAN STREAMBUILDER
              StreamBuilder(
                stream: _dbRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  }

                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Belum ada data laporan.')));
                  }

                  // 1. Ambil Data dan Konversi ke List
                  Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> listLaporan = [];
                  
                  // Variabel untuk menghitung statistik secara live!
                  int totalLaporan = 0;
                  int totalMenunggu = 0;
                  int totalSelesai = 0;
                  int totalDitolak = 0;

                  dataMap.forEach((key, value) {
                    var item = value as Map<dynamic, dynamic>;
                    item['id'] = key; // Simpan ID unik dari firebase
                    listLaporan.add(item);
                    
                    totalLaporan++;
                    String status = (item['status'] ?? '').toString().toLowerCase();
                    if (status.contains('menunggu')) totalMenunggu++;
                    else if (status.contains('selesai') || status.contains('disetujui') || status.contains('aktif')) totalSelesai++;
                    else if (status.contains('ditolak')) totalDitolak++;
                  });

                  // Urutkan laporan dari yang terbaru
                  listLaporan = listLaporan.reversed.toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. BAGIAN STATISTIK (Angkanya sekarang dinamis!)
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(count: '$totalLaporan', label: 'Laporan', icon: Icons.assignment_outlined, color: Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(count: '$totalMenunggu', label: 'Verifikasi', icon: Icons.verified_outlined, color: Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(count: '$totalSelesai', label: 'Selesai/Aktif', icon: Icons.assignment_turned_in_outlined, color: Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(count: '$totalDitolak', label: 'Ditolak', icon: Icons.cancel_outlined, color: Colors.red)),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      const Text('LAPORAN MASUK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 14),

                      // 3. DAFTAR LAPORAN MENGGUNAKAN LISTVIEW.BUILDER
                      ListView.builder(
                        // Penting: shrinkWrap dan physics ini wajib dipakai kalau ListView ada di dalam SingleChildScrollView
                        shrinkWrap: true, 
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listLaporan.length,
                        itemBuilder: (context, index) {
                          var item = listLaporan[index];
                          
                          // Tentukan warna icon berdasarkan jenis laporan
                          Color iconColor = item['jenis'].toString().toLowerCase() == 'hilang' ? Colors.red : Colors.blue;
                          IconData iconTipe = item['jenis'].toString().toLowerCase() == 'hilang' ? Icons.wallet_outlined : Icons.laptop_mac;

                          return _buildReportCard(
                            context,
                            item: item, // Oper data lengkap untuk keperluan Update Status
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

  // Tambahkan parameter 'item' berbentuk Map agar kita tahu data mana yang diklik
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
              // Mengubah warna teks status bergantung dari valuenya
              Text(
                status,
                style: TextStyle(
                  color: status.toLowerCase().contains('menunggu') ? Colors.orange 
                       : status.toLowerCase().contains('tolak') ? Colors.red 
                       : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // UPDATE FIREBASE: Mengubah status menjadi 'Aktif/Disetujui'
                      FirebaseDatabase.instance.ref('reports/${item['id']}').update({'status': 'Aktif'});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$itemName disetujui.'), backgroundColor: Colors.green));
                    },
                    child: const Text('Setujui', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () {
                      // UPDATE FIREBASE: Mengubah status menjadi 'Ditolak'
                      FirebaseDatabase.instance.ref('reports/${item['id']}').update({'status': 'Ditolak'});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$itemName ditolak.'), backgroundColor: Colors.red));
                    },
                    child: const Text('Tolak', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}