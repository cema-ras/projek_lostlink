import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {}, // Nanti bisa diisi menu 'Tandai semua dibaca'
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifikasi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              'Lihat informasi terbaru terkait laporan dan klaim barang Anda',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 25),

            // Kelompok: HARI INI
            _buildSectionTitle('HARI INI'),
            const SizedBox(height: 10),
            _buildNotifCard(
              icon: Icons.check_circle_outline,
              iconBgColor: Colors.white,
              title: 'Klaim Disetujui!',
              time: '2 jam yang lalu',
              description: 'Klaim Anda untuk "MacBook Pro 2021" telah disetujui oleh pemilik. Silakan hubungi pemilik',
              isUnread: true,
            ),
            _buildNotifCard(
              icon: Icons.search,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue,
              title: 'Laporan Barang Ditemukan',
              time: '5 jam yang lalu',
              description: 'Seseorang melaporkan telah menemukan "Kunci Mobil BMW" yang mirip dengan laporan',
              isUnread: true,
            ),
            _buildNotifCard(
              icon: Icons.error_outline,
              iconBgColor: Colors.white,
              title: 'Pembaruan Keamanan',
              time: 'Hari ini, 09:12',
              description: 'Akun Anda berhasil masuk dari perangkat baru di Jakarta, Indonesia.',
              isUnread: false,
            ),
            const SizedBox(height: 20),

            // Kelompok: SEBELUMNYA
            _buildSectionTitle('SEBELUMNYA'),
            const SizedBox(height: 10),
            _buildNotifCard(
              icon: Icons.access_time,
              iconBgColor: Colors.white,
              title: 'Status Klaim Berubah',
              time: 'Kemarin, 18:45',
              description: 'Permintaan klaim untuk "Dompet Kulit Cokelat" sedang ditinjau oleh tim verifikasi LOSTLINK.',
              isUnread: false,
            ),
            _buildNotifCard(
              icon: Icons.inventory_2_outlined,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue,
              title: 'Barang Berhasil Dikembalikan',
              time: '2 hari yang lalu',
              description: 'Terima kasih telah menggunakan LOSTLINK! Laporan "iPhone 13" Anda telah ditutup.',
              isUnread: false,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Header Logo (Konsisten dengan halaman lain)
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

  // Helper untuk Judul Seksi (Hari Ini / Sebelumnya)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
    );
  }

  // Helper untuk Kartu Notifikasi
  Widget _buildNotifCard({
    required IconData icon,
    required Color iconBgColor,
    Color iconColor = Colors.black87,
    required String title,
    required String time,
    required String description,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: iconBgColor == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isUnread)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          ),
                        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}