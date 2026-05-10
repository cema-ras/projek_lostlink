import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class DetailLaporanPage extends StatefulWidget {
  final Map<dynamic, dynamic> reportData;

  const DetailLaporanPage({super.key, required this.reportData});

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  final TextEditingController _buktiController = TextEditingController();
  bool _isLoading = false; 

  Future<void> _submitKlaim() async {
    if (_buktiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form tidak boleh kosong!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final DatabaseReference claimsRef = FirebaseDatabase.instance.ref('claims');
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      
      String? newClaimKey = claimsRef.push().key;

      if (newClaimKey != null) {
        // 1. Simpan data respon/klaim ke tabel 'claims'
        await claimsRef.child(newClaimKey).set({
          'reportId': widget.reportData['id'], 
          'userId': userId ?? 'user_tidak_dikenal', 
          'deskripsiBukti': _buktiController.text.trim(),
          'buktiFoto': '', 
          'status': 'menunggu',
          'createdAt': DateTime.now().toIso8601String(),
        });

        // 2. ---> TAMBAHAN BARU: Update status di tabel 'reports' <---
        // Ubah status laporan menjadi 'verifikasi' agar terdeteksi oleh Admin Page
        await FirebaseDatabase.instance.ref('reports/${widget.reportData['id']}').update({
          'status': 'verifikasi'
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil diajukan! Menunggu konfirmasi.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); 
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
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
    final String namaBarang = widget.reportData['namaBarang'] ?? 'Tanpa Nama';
    final String status = widget.reportData['status'] ?? 'Menunggu';
    final String jenis = widget.reportData['jenis']?.toString().toUpperCase() ?? 'HILANG';
    final String kategori = widget.reportData['kategoriId']?.toString().toUpperCase() ?? 'LAINNYA';
    final String tanggal = widget.reportData['tanggalKejadian'] ?? '-';
    final String deskripsi = widget.reportData['deskripsi'] ?? 'Tidak ada deskripsi.';
    final String lokasi = widget.reportData['lokasi'] ?? 'Lokasi tidak diketahui.';
    final String? fotoUrl = widget.reportData['fotoUrl'];
    
    // AMBIL ID USER PEMBUAT LAPORAN DAN USER YANG SEDANG LOGIN
    final String reportUserId = widget.reportData['userId'] ?? '';
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isOwnReport = currentUserId == reportUserId;

    // WARNA STATUS DINAMIS
    Color statusColor;
    String statusTeks = status.toUpperCase();
    if (statusTeks == 'MENUNGGU') {
      statusColor = Colors.orange;
    } else if (statusTeks == 'TERVERIFIKASI') {
      statusColor = Colors.blue;
    } else if (statusTeks == 'SELESAI') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey; 
    }

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
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusTeks, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

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

            _buildImageSection(fotoUrl),
            const SizedBox(height: 25),

            _buildInfoItem(Icons.info_outline, 'DESKRIPSI LENGKAP', deskripsi),
            const Divider(height: 30),
            _buildInfoItem(Icons.location_on_outlined, 'LOKASI KEJADIAN', lokasi),
            const Divider(height: 30),
            _buildInfoItem(Icons.calendar_today_outlined, 'WAKTU KEJADIAN', tanggal),
            const Divider(height: 30),
            _buildInfoItem(Icons.local_offer_outlined, 'KATEGORI BARANG', kategori),
            const SizedBox(height: 30),

            // LOGIKA PENTING: Hanya tampilkan form jika status BUKAN selesai DAN user BUKAN pemilik postingan
            if (status.toLowerCase() != 'selesai' && !isOwnReport) 
              _buildKlaimForm(jenis),
            
            // Berikan pesan jika ini adalah postingan miliknya sendiri
            if (isOwnReport)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Ini adalah laporan Anda sendiri.',
                    style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              
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
                    // TAMBAHAN: Menampilkan indikator loading saat gambar sedang diunduh
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  )
                : const Icon(Icons.laptop_mac, size: 80, color: Colors.grey),
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

  // MENERIMA PARAMETER 'jenis' UNTUK MENYESUAIKAN TEKS
  Widget _buildKlaimForm(String jenisLaporan) {
    String today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    // Sesuaikan judul dan deskripsi berdasarkan jenis laporan
    String judulForm = jenisLaporan == 'HILANG' ? 'Laporkan Penemuan' : 'Ajukan Klaim Kepemilikan';
    String deskripsiForm = jenisLaporan == 'HILANG'
        ? 'Apakah Anda menemukan barang ini? Berikan informasi dan bukti bahwa barang tersebut ada pada Anda.'
        : 'Ajukan klaim jika Anda adalah pemilik sah. Wajib menyertakan bukti kuat atas barang ini.';
    String labelInput = jenisLaporan == 'HILANG' ? 'Informasi Penemuan / Ciri Spesifik' : 'Bukti Kepemilikan';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judulForm, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(deskripsiForm, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          
          const Text('Tanggal Form', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            readOnly: true, 
            controller: TextEditingController(text: today),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),

          Text(labelInput, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _buktiController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan detail selengkapnya di sini...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

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
                  : const Text('Kirim Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}