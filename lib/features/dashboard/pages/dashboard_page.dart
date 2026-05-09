import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// --- TAMBAHKAN IMPORT MODEL & SERVICE ---
import '../../../../models/report_model.dart'; // Sesuaikan letak folder
import '../../../../services/report_service.dart'; // Sesuaikan letak folder

// 1. UBAH JADI STATEFUL WIDGET AGAR BISA MEMUAT DATA DINAMIS
class DashboardPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onOpenStatus;

  const DashboardPage({
    super.key,
    this.onNavigate,
    this.onOpenStatus,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 2. SIAPKAN VARIABEL UNTUK MENAMPUNG DATA DARI DATABASE
  String namaPengguna = 'Memuat...';
  List<ReportModel> daftarLaporan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 3. PANGGIL FUNGSI AMBIL DATA SAAT HALAMAN DIBUKA
    _ambilData();
  }

  // FUNGSI UNTUK MENARIK DATA DARI FIREBASE
  Future<void> _ambilData() async {
    try {
      // A. Ambil nama user yang sedang login
      User? userAuth = FirebaseAuth.instance.currentUser;
      if (userAuth != null) {
        DataSnapshot snapshot = await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userAuth.uid)
            .get();

        if (snapshot.exists) {
          Map data = snapshot.value as Map;
          namaPengguna = data['nama'] ?? 'Pengguna';
        }
      }

      // B. Ambil semua data laporan dari Mesin ReportService
      List<ReportModel> laporanDb = await ReportService().ambilSemuaLaporan();

      // C. Perbarui tampilan
      setState(() {
        daftarLaporan = laporanDb;
        isLoading = false;
      });
    } catch (e) {
      print("Gagal memuat dashboard: $e");
      setState(() {
        namaPengguna = 'Error memuat profil';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. HITUNG OTOMATIS JUMLAH LAPORAN
    int totalHilang = daftarLaporan.where((r) => r.jenis == 'hilang').length;
    int totalTemuan = daftarLaporan.where((r) => r.jenis == 'temuan').length;
    int totalStatus = daftarLaporan.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Tampilan Loading
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Profil
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 5. TAMPILKAN NAMA ASLI USER
                              Text(
                                'Halo, $namaPengguna',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Selamat datang di LOSTLINK',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onNavigate?.call(4);
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // 6. TAMPILKAN ANGKA STATISTIK ASLI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          totalHilang.toString(),
                          'HILANG',
                          Colors.red.shade100,
                          Colors.red,
                        ),
                        _buildStatItem(
                          totalTemuan.toString(),
                          'TEMUAN',
                          Colors.blue.shade100,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          totalStatus.toString(),
                          'STATUS',
                          Colors.green.shade100,
                          Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'MENU UTAMA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                      children: [
                        _buildMenuCard(
                          title: 'Laporan Hilang',
                          icon: Icons.add_box_outlined,
                          color: Colors.blue,
                          onTap: () => widget.onNavigate?.call(2),
                        ),
                        _buildMenuCard(
                          title: 'Laporan Temuan',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.blue,
                          onTap: () => widget.onNavigate?.call(2),
                        ),
                        _buildMenuCard(
                          title: 'Cari Barang',
                          icon: Icons.search,
                          color: Colors.blue,
                          onTap: () => widget.onNavigate?.call(1),
                        ),
                        _buildMenuCard(
                          title: 'Status Barang',
                          icon: Icons.assignment_turned_in_outlined,
                          color: Colors.blue,
                          onTap: () => widget.onOpenStatus?.call(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'STATUS BARANG TERBARU',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 7. LOOPING DAFTAR LAPORAN DARI DATABASE (Ambil 3 terbaru)
                    if (daftarLaporan.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Belum ada laporan barang."),
                        ),
                      )
                    else
                      ...daftarLaporan.take(3).map((laporan) {
                        return _buildStatusCard(
                          title: laporan.namaBarang,
                          // Tampilkan maksimal 40 karakter dari deskripsi
                          subtitle: laporan.deskripsi.length > 40
                              ? '${laporan.deskripsi.substring(0, 40)}...'
                              : laporan.deskripsi,
                          status: laporan.status.toUpperCase(),
                          // Ubah warna berdasarkan status
                          color: laporan.status == 'selesai'
                              ? Colors.green
                              : (laporan.status == 'terverifikasi'
                                  ? Colors.blue
                                  : Colors.orange),
                          icon: laporan.jenis == 'hilang'
                              ? Icons.search_off
                              : Icons.inventory_2_outlined,
                        );
                      }).toList(),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onOpenStatus?.call(),
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: const Text('Lihat Semua Status Barang'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  // WIDGET BAWAAN DARI TEMANMU (TIDAK ADA YANG BERUBAH)
  Widget _buildStatItem(
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}