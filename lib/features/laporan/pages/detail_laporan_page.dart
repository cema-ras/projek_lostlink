import 'package:flutter/material.dart';

class DetailLaporanPage extends StatelessWidget {
  const DetailLaporanPage({super.key});

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
            const Text('Detail Laporan', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Judul dan Badge Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'MacBook Pro M2 14"\nSpace Grey',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kategori dan Tanggal
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                  child: Text('Kehilangan', style: TextStyle(color: Colors.blue[700], fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Text('• Elektronik • 24 Okt 2023', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            // Foto Barang
            _buildImageSection(),
            const SizedBox(height: 25),

            // Detail Informasi (Deskripsi, Lokasi, dll)
            _buildInfoItem(Icons.info_outline, 'DESKRIPSI LENGKAP', "MacBook dengan stiker logo 'React' di bagian casing depan. Terakhir terlihat di meja perpustakaan lantai 2. Ada sedikit goresan di pojok kiri bawah."),
            const Divider(height: 30),
            _buildInfoItem(Icons.location_on_outlined, 'LOKASI KEJADIAN', 'Perpustakaan Pusat, Lantai 2 Sayap Timur'),
            const Divider(height: 30),
            _buildInfoItem(Icons.calendar_today_outlined, 'WAKTU KEJADIAN', 'Selasa, 24 Oktober 2023 • 14:30 WIB'),
            const Divider(height: 30),
            _buildInfoItem(Icons.local_offer_outlined, 'KATEGORI BARANG', 'Elektronik & Gadget'),
            const SizedBox(height: 30),

            // Form Ajukan Klaim
            _buildKlaimForm(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // Opsional: Tambahkan BottomNavigationBar di sini jika Anda ingin persis seperti desain
    );
  }

  // Header Logo konsisten dengan halaman lain
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

  // Bagian Foto Barang
  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200], // Mockup background foto
            child: const Icon(Icons.laptop_mac, size: 80, color: Colors.grey),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.camera_alt_outlined, size: 16),
                SizedBox(width: 4),
                Text('Lihat Foto Penuh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Pembuat list informasi agar rapi
  Widget _buildInfoItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[300], size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // Form Kotak Biru Muda
  Widget _buildKlaimForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ajukan Klaim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Ajukan klaim jika Anda adalah pemilik sah atau memiliki bukti kuat atas barang ini.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          
          const Text('Tanggal Klaim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: '2023-10-25',
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),

          const Text('Bukti Kepemilikan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Contoh: Nomor seri, foto box, atau ciri khusus lainnya...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 8),
          const Text('*Wajib menyertakan bukti visual atau deskripsi teknis.', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),

          // Status Awal Box
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.2))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('STATUS AWAL', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text('Menunggu Verifikasi', style: TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(Icons.info_outline, color: Colors.blue[300]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol Simpan Klaim
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Klaim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}