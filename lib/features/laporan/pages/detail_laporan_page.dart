import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mengambil User ID

class DetailLaporanPage extends StatefulWidget {
  // Variabel untuk menangkap data dari halaman Cari Barang
  final Map<dynamic, dynamic> reportData;

  const DetailLaporanPage({super.key, required this.reportData});

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  // Controller untuk form Bukti Kepemilikan
  final TextEditingController _buktiController = TextEditingController();
  bool _isLoading = false; // Untuk efek loading saat tombol ditekan

  // Fungsi untuk mengirim data klaim ke Firebase
  Future<void> _submitKlaim() async {
    if (_buktiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti kepemilikan tidak boleh kosong!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final DatabaseReference claimsRef = FirebaseDatabase.instance.ref('claims');
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      // Membuat ID unik untuk klaim baru
      String? newClaimKey = claimsRef.push().key;

      if (newClaimKey != null) {
        await claimsRef.child(newClaimKey).set({
          'reportId': widget.reportData['id'], // ID Laporan yang diklaim
          'userId': userId ?? 'user_tidak_dikenal', // ID User yang login
          'deskripsiBukti': _buktiController.text.trim(),
          'buktiFoto': '', // Kosongkan dulu jika belum ada fitur upload foto bukti
          'status': 'menunggu',
          'createdAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Klaim berhasil diajukan!')),
          );
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _buktiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dengan aman (berikan nilai default jika null)
    final String namaBarang = widget.reportData['namaBarang'] ?? 'Tanpa Nama';
    final String status = widget.reportData['status'] ?? 'Menunggu';
    final String jenis = widget.reportData['jenis']?.toString().toUpperCase() ?? 'HILANG';
    final String kategori = widget.reportData['kategoriId']?.toString().toUpperCase() ?? 'LAINNYA';
    final String tanggal = widget.reportData['tanggalKejadian'] ?? '-';
    final String deskripsi = widget.reportData['deskripsi'] ?? 'Tidak ada deskripsi.';
    final String lokasi = widget.reportData['lokasi'] ?? 'Lokasi tidak diketahui.';
    final String? fotoUrl = widget.reportData['fotoUrl'];

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
                Expanded(
                  child: Text(
                    namaBarang,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kategori dan Tanggal
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: jenis == 'HILANG' ? Colors.red[50] : Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                  child: Text(jenis, style: TextStyle(color: jenis == 'HILANG' ? Colors.red[700] : Colors.blue[700], fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Text('• $kategori • $tanggal', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),

            // Foto Barang
            _buildImageSection(fotoUrl),
            const SizedBox(height: 25),

            // Detail Informasi
            _buildInfoItem(Icons.info_outline, 'DESKRIPSI LENGKAP', deskripsi),
            const Divider(height: 30),
            _buildInfoItem(Icons.location_on_outlined, 'LOKASI KEJADIAN', lokasi),
            const Divider(height: 30),
            _buildInfoItem(Icons.calendar_today_outlined, 'WAKTU KEJADIAN', tanggal),
            const Divider(height: 30),
            _buildInfoItem(Icons.local_offer_outlined, 'KATEGORI BARANG', kategori),
            const SizedBox(height: 30),

            // Form Ajukan Klaim (Hanya tampil jika status belum selesai)
            if (status.toLowerCase() != 'selesai') _buildKlaimForm(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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

  Widget _buildImageSection(String? url) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: url != null && url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  )
                : const Icon(Icons.laptop_mac, size: 80, color: Colors.grey),
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

  Widget _buildKlaimForm() {
    // Format tanggal hari ini untuk ditampilkan di textfield
    String today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

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
            readOnly: true, // Dibuat read-only karena ini tanggal hari ini
            controller: TextEditingController(text: today),
            decoration: InputDecoration(
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
            controller: _buktiController,
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

          // Tombol Simpan Klaim
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitKlaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Klaim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}