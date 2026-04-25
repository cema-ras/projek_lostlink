import 'package:flutter/material.dart';

class StatusKlaimPage extends StatelessWidget {
  const StatusKlaimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildLogoHeader(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Klaim Saya', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              'Pantau status verifikasi bukti kepemilikan untuk barang yang Anda klaim.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 25),

            // Daftar Klaim (Mockup Data)
            _buildStatusCard(
              context: context,
              itemName: 'MacBook Pro M2 14" Space Grey',
              claimDate: '25 Okt 2023',
              status: 'Menunggu Verifikasi',
              statusColor: Colors.orange,
              icon: Icons.laptop_mac,
            ),
            _buildStatusCard(
              context: context,
              itemName: 'Kunci Mobil BMW',
              claimDate: '22 Okt 2023',
              status: 'Disetujui',
              statusColor: Colors.green,
              icon: Icons.vpn_key_outlined,
            ),
            _buildStatusCard(
              context: context,
              itemName: 'Dompet Kulit Cokelat',
              claimDate: '15 Okt 2023',
              status: 'Ditolak',
              statusColor: Colors.red,
              icon: Icons.wallet_outlined,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Header Logo Konsisten
  Widget _buildLogoHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle),
          child: const Icon(Icons.search, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text('LOSTLINK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  // Helper untuk Kartu Status Klaim
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
              // Icon Barang
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 15),
              // Info Barang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diklaim pada: $claimDate',
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
                  const Text('STATUS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Memunculkan Bottom Sheet dari bawah layar
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
                          mainAxisSize: MainAxisSize.min, // Menyesuaikan tinggi dengan isi
                          children: [
                            Text('Riwayat Klaim: $itemName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(height: 30),
                            
                            // Contoh Timeline Sederhana
                            const Text('• 25 Okt 2023 - 09:00 WIB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const Text('Klaim diajukan ke sistem.', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 15),
                            
                            const Text('• 26 Okt 2023 - 14:30 WIB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const Text('Sedang ditinjau oleh petugas.', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 15),

                            const Text('• Status Saat Ini', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(status, style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context), // Tombol untuk menutup Bottom Sheet
                                child: const Text('Tutup'),
                              ),
                            )
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