import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- TAMBAHKAN IMPORT MODEL & SERVICE ---
import '../../../../models/report_model.dart';
import '../../../../services/report_service.dart';

// 1. UBAH MENJADI STATEFUL WIDGET AGAR BISA MEMUAT DATA
class StatusKlaimPage extends StatefulWidget {
  const StatusKlaimPage({super.key});

  @override
  State<StatusKlaimPage> createState() => _StatusKlaimPageState();
}

class _StatusKlaimPageState extends State<StatusKlaimPage> {
  // 2. SIAPKAN VARIABEL PENAMPUNG DATA
  List<ReportModel> laporanSaya = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDataStatus();
  }

  // 3. FUNGSI UNTUK MENARIK DATA KHUSUS MILIK USER INI
  Future<void> _ambilDataStatus() async {
    try {
      // Ambil ID user yang sedang login
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Ambil SEMUA laporan dari database
        List<ReportModel> semuaLaporan = await ReportService().ambilSemuaLaporan();
        
        // Saring (Filter) HANYA laporan yang dibuat oleh user ini
        setState(() {
          laporanSaya = semuaLaporan.where((laporan) => laporan.userId == currentUser.uid).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Gagal mengambil status: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: isLoading 
            ? const Center(child: CircularProgressIndicator()) // Tampilkan loading
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoHeader(),

                    const SizedBox(height: 24),

                    const Text(
                      'Status Barang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Pantau status laporan, klaim, dan verifikasi barang Anda.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 4. TAMPILKAN DAFTAR LAPORAN SECARA OTOMATIS
                    if (laporanSaya.isEmpty)
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
                      // Melakukan Looping data laporanSaya menjadi Widget Kartu
                      ...laporanSaya.map((laporan) {
                        // Menentukan warna berdasarkan status dari database
                        Color warnaStatus;
                        String teksStatus = laporan.status.toUpperCase();
                        
                        if (laporan.status == 'selesai') {
                          warnaStatus = Colors.green;
                        } else if (laporan.status == 'terverifikasi' || laporan.status == 'diterima') {
                          warnaStatus = Colors.blue;
                        } else if (laporan.status == 'ditolak') {
                          warnaStatus = Colors.red;
                        } else {
                          warnaStatus = Colors.orange; // Default untuk 'menunggu'
                        }

                        return _buildStatusCard(
                          context: context,
                          itemName: laporan.namaBarang,
                          claimDate: laporan.tanggalKejadian, // Menggunakan tanggal dari database
                          status: teksStatus,
                          statusColor: warnaStatus,
                          icon: laporan.jenis == 'hilang' ? Icons.search_off : Icons.inventory_2_outlined,
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
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'LOSTLINK',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // WIDGET CARD DARI TEMANMU (HANYA DIUBAH ISI POP-UP DETAILNYA SEDIKIT)
  Widget _buildStatusCard({
    required BuildContext context,
    required String itemName,
    required String claimDate,
    required String status,
    required Color statusColor,
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: $claimDate',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
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
                              'Detail Status: $itemName',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 30),
                            Text(
                              '• Tanggal Laporan: $claimDate',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              'Laporan telah tercatat di sistem.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              '• Status Saat Ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 14,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                ),
                child: const Text(
                  'Detail',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}