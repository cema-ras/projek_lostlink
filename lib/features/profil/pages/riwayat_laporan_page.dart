import 'dart:async'; // Wajib ditambahkan untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RiwayatLaporanPage extends StatefulWidget {
  final VoidCallback? onBack;

  const RiwayatLaporanPage({
    super.key,
    this.onBack,
  });

  @override
  State<RiwayatLaporanPage> createState() => _RiwayatLaporanPageState();
}

class _RiwayatLaporanPageState extends State<RiwayatLaporanPage> {
  bool _isLoading = true;
  
  // List terpisah untuk menampung data sementara
  List<Map<dynamic, dynamic>> _rawReports = [];
  List<Map<dynamic, dynamic>> _rawClaims = [];
  
  // List utama yang akan ditampilkan
  List<Map<dynamic, dynamic>> _riwayatList = [];
  
  int _countHilang = 0;
  int _countTemuan = 0;
  int _countKlaim = 0;

  // Tambahkan variabel ini untuk menyimpan "jalur" koneksi ke Firebase
  StreamSubscription<DatabaseEvent>? _reportsSubscription;
  StreamSubscription<DatabaseEvent>? _claimsSubscription;

  @override
  void initState() {
    super.initState();
    _loadRiwayatLaporan();
  }

  // JANGAN LUPA: Matikan koneksi saat halaman ditutup
  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _claimsSubscription?.cancel();
    super.dispose();
  }

  void _loadRiwayatLaporan() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    // 1. Mengambil data dari node 'reports'
    DatabaseReference reportsRef = FirebaseDatabase.instance.ref('reports');
    _reportsSubscription = reportsRef.orderByChild('userId').equalTo(user.uid).onValue.listen((event) {
      List<Map<dynamic, dynamic>> tempReports = [];
      int hilang = 0;
      int temuan = 0;

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          String jenis = (value['jenis'] ?? '').toString().toUpperCase();
          
          if (jenis == 'HILANG') {
            hilang++;
          } else if (jenis == 'TEMUAN') {
            temuan++;
          }

          tempReports.add({
            'id': key,
            'title': value['namaBarang'] ?? 'Barang Tanpa Nama',
            'type': jenis.isEmpty ? 'HILANG' : jenis,
            'location': value['lokasi'] ?? 'Lokasi tidak diketahui',
            // Pastikan mengambil timestamp untuk memudahkan sorting
            'date': value['tanggalKejadian'] ?? '-', 
            'timestamp': value['tanggalKejadian'] ?? 0, // Gunakan untuk sorting
            'status': value['status'] ?? 'Menunggu',
          });
        });
      }

      if (mounted) {
        setState(() {
          _rawReports = tempReports;
          _countHilang = hilang;
          _countTemuan = temuan;
          _combineLists(); 
        });
      }
    });

    // 2. Mengambil data dari node 'claims'
    DatabaseReference claimsRef = FirebaseDatabase.instance.ref('claims');
    _claimsSubscription = claimsRef.orderByChild('userId').equalTo(user.uid).onValue.listen((event) {
      List<Map<dynamic, dynamic>> tempClaims = [];
      int klaim = 0;

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          klaim++;
          
          tempClaims.add({
            'id': key,
            'title': 'Pengajuan Klaim Barang', 
            'type': 'KLAIM',
            'location': '-', 
            'date': value['createdAt'] ?? '-',
            'timestamp': value['createdAt'] ?? 0, // Gunakan untuk sorting
            'status': value['status'] ?? 'Menunggu',
          });
        });
      }

      if (mounted) {
        setState(() {
          _rawClaims = tempClaims;
          _countKlaim = klaim;
          _combineLists(); 
        });
      }
    });
  }

  // Fungsi untuk menggabungkan dan MENGURUTKAN data
  void _combineLists() {
    List<Map<dynamic, dynamic>> combined = [..._rawReports, ..._rawClaims];

    // Mengurutkan data dari yang terbaru ke terlama berdasarkan string/timestamp
    combined.sort((a, b) {
      String dateA = a['timestamp'].toString();
      String dateB = b['timestamp'].toString();
      return dateB.compareTo(dateA); 
    });

    setState(() {
      _riwayatList = combined;
      _isLoading = false;
    });
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
              _buildHeader(),

              const SizedBox(height: 24),

              const Text(
                'Riwayat Laporan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Daftar laporan hilang, temuan, dan klaim yang pernah Anda buat.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              _buildFilterSummary(),

              const SizedBox(height: 18),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_riwayatList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                      'Belum ada riwayat laporan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._riwayatList.map((item) {
                  String tipe = item['type'].toString().toUpperCase();
                  Color warnaCard = Colors.red;
                  IconData ikonCard = Icons.warning_amber_rounded;

                  if (tipe == 'TEMUAN') {
                    warnaCard = Colors.blue;
                    ikonCard = Icons.find_in_page_outlined;
                  } else if (tipe == 'KLAIM') {
                    warnaCard = Colors.green;
                    ikonCard = Icons.assignment_turned_in_outlined;
                  }

                  String statusText = item['status'].toString();
                  if (statusText.isNotEmpty) {
                    statusText = statusText[0].toUpperCase() + statusText.substring(1);
                  }

                  return _buildHistoryCard(
                    title: item['title'],
                    type: tipe,
                    location: item['location'],
                    date: item['date'].toString(), // Pastikan dijadikan string
                    status: statusText,
                    color: warnaCard,
                    icon: ikonCard,
                  );
                }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'LOSTLINK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48), 
      ],
    );
  }

  Widget _buildFilterSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallBox(
            count: _countHilang.toString(),
            label: 'Hilang',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallBox(
            count: _countTemuan.toString(),
            label: 'Temuan',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallBox(
            count: _countKlaim.toString(),
            label: 'Klaim',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBox({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String type,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location == '-' ? date : '$location • $date',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}