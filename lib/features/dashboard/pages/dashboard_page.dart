import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
  // Variabel Data User
  String _namaPengguna = 'Memuat...';
  String? _fotoUrl;

  // Variabel Data Laporan & Statistik
  List<Map<dynamic, dynamic>> _daftarLaporan = []; // Ini nanti berisi gabungan reports & claims
  
  // List bantuan untuk menampung data sebelum digabung
  List<Map<dynamic, dynamic>> _dataReports = [];
  List<Map<dynamic, dynamic>> _dataClaims = [];

  bool _isLoading = true;
  int _totalHilang = 0;
  int _totalTemuan = 0;
  int _totalLaporan = 0;

  // Variabel untuk mencegah memory leak
  StreamSubscription<DatabaseEvent>? _userSubscription;
  StreamSubscription<DatabaseEvent>? _reportSubscription;
  StreamSubscription<DatabaseEvent>? _claimSubscription; // <--- BARU: Subscription untuk claims

  @override
  void initState() {
    super.initState();
    _ambilDataRealtime();
  }

  @override
  void dispose() {
    // Matikan listener saat halaman ditutup atau berpindah tab
    _userSubscription?.cancel();
    _reportSubscription?.cancel();
    _claimSubscription?.cancel(); // <--- BARU: Jangan lupa dimatikan
    super.dispose();
  }

  // --- FUNGSI BARU: Menggabungkan Laporan & Klaim, lalu mengurutkan ---
  void _updateDaftarGabungan() {
    List<Map<dynamic, dynamic>> gabungan = [..._dataReports, ..._dataClaims];
    
    // Urutkan dari yang paling baru (descending)
    gabungan.sort((a, b) {
      String dateA = a['timestamp'].toString();
      String dateB = b['timestamp'].toString();
      return dateB.compareTo(dateA); 
    });

    if (mounted) {
      setState(() {
        _daftarLaporan = gabungan;
        _totalLaporan = gabungan.length; // Total status adalah gabungan laporan & klaim
        _isLoading = false;
      });
    }
  }

  // FUNGSI UNTUK MENARIK DATA DARI FIREBASE SECARA REALTIME
  void _ambilDataRealtime() {
    User? userAuth = FirebaseAuth.instance.currentUser;
    if (userAuth == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // 1. Ambil nama dan foto user secara realtime
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${userAuth.uid}');
    _userSubscription = userRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (mounted) {
          setState(() {
            _namaPengguna = data['nama']?.toString() ?? 'Pengguna';
            String? rawUrl = data['fotoUrl']?.toString();
            _fotoUrl = (rawUrl != null && rawUrl.trim().isNotEmpty) ? rawUrl : null;
          });
        }
      }
    });

    // 2. Ambil data laporan (Reports)
    DatabaseReference reportsRef = FirebaseDatabase.instance.ref('reports');
    _reportSubscription = reportsRef.onValue.listen((event) {
      List<Map<dynamic, dynamic>> tempList = [];
      int hitungHilang = 0;
      int hitungTemuan = 0;

      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        data.forEach((key, value) {
          String idPembuatLaporan = (value['userId'] ?? '').toString();

          if (idPembuatLaporan == userAuth.uid) {
            String jenis = (value['jenis'] ?? '').toString().toLowerCase();
            
            if (jenis == 'hilang') hitungHilang++;
            else if (jenis == 'temuan') hitungTemuan++;

            tempList.add({
              'id': key,
              'namaBarang': value['namaBarang'] ?? 'Tanpa Nama',
              'deskripsi': value['deskripsi'] ?? '-',
              'jenis': jenis,
              'status': value['status'] ?? 'menunggu',
              'timestamp': value['tanggalKejadian'] ?? value['createdAt'] ?? 0, 
              'fotoUrl' : value['fotoUrl'],
            });
          }
        });
      }

      _dataReports = tempList;
      if (mounted) {
        setState(() {
          _totalHilang = hitungHilang;
          _totalTemuan = hitungTemuan;
        });
        _updateDaftarGabungan();
      }
    });

    // 3. --- BARU: Ambil data klaim (Claims) ---
    DatabaseReference claimsRef = FirebaseDatabase.instance.ref('claims');
    _claimSubscription = claimsRef.onValue.listen((event) async {
      List<Map<dynamic, dynamic>> tempClaims = [];
      
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        
        for (var entry in data.entries) {
          var key = entry.key;
          var value = entry.value as Map<dynamic, dynamic>;
          
          if (value['userId'] == userAuth.uid) {
            // Kita siapkan default data, in case detail barang gagal ditarik
            String namaBarang = 'Barang Temuan';
            String deskripsi = 'Pengajuan klaim Anda';
            String? fotoUrl;
            
            // Coba ambil info barang dari tabel 'reports' berdasarkan 'laporanId'
            String laporanId = (value['laporanId'] ?? '').toString();
            if (laporanId.isNotEmpty) {
              try {
                DataSnapshot reportSnap = await FirebaseDatabase.instance.ref('reports/$laporanId').get();
                if (reportSnap.exists) {
                  var repData = reportSnap.value as Map<dynamic, dynamic>;
                  namaBarang = repData['namaBarang'] ?? namaBarang;
                  deskripsi = repData['deskripsi'] ?? deskripsi;
                  fotoUrl = repData['fotoUrl'];
                }
              } catch (e) {
                debugPrint('Gagal fetch detail report untuk klaim: $e');
              }
            }
            
            tempClaims.add({
              'id': key,
              'namaBarang': 'Klaim: $namaBarang', // Tambahan teks "Klaim:" sebagai pembeda
              'deskripsi': deskripsi,
              'jenis': 'klaim', // Jenis khusus klaim
              'status': value['status'] ?? 'menunggu',
              'timestamp': value['createdAt'] ?? 0, 
              'fotoUrl' : fotoUrl,
            });
          }
        }
      }
      
      _dataClaims = tempClaims;
      _updateDaftarGabungan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: _isLoading
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
                              Text(
                                'Halo, $_namaPengguna',
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
                            widget.onNavigate?.call(4); // Navigasi ke tab Profil
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                            child: _fotoUrl == null
                                ? const Icon(Icons.person, color: Colors.grey, size: 25)
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // TAMPILKAN ANGKA STATISTIK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          _totalHilang.toString(),
                          'HILANG',
                          Colors.red.shade100,
                          Colors.red,
                        ),
                        _buildStatItem(
                          _totalTemuan.toString(),
                          'TEMUAN',
                          Colors.blue.shade100,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          _totalLaporan.toString(),
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

                    // LOOPING DAFTAR LAPORAN DARI DATABASE (Ambil 3 terbaru)
                    if (_daftarLaporan.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "Belum ada aktivitas laporan atau klaim.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ..._daftarLaporan.take(3).map((laporan) {
                        String desc = laporan['deskripsi'].toString();
                        String shortDesc = desc.length > 40 ? '${desc.substring(0, 40)}...' : desc;
                        String statusText = laporan['status'].toString().toUpperCase();
                        String jenis = laporan['jenis'].toString();

                        // Penyesuaian warna status
                        Color statusColor = Colors.orange; // Default untuk 'menunggu'
                        if (statusText == 'SELESAI' || statusText == 'DISETUJUI') {
                          statusColor = Colors.green;
                        } else if (statusText == 'TERVERIFIKASI') {
                          statusColor = Colors.blue;
                        } else if (statusText == 'DITOLAK') {
                          statusColor = Colors.red;
                        }

                        // Penyesuaian icon berdasarkan jenis (hilang / temuan / klaim)
                        IconData itemIcon;
                        if (jenis == 'hilang') {
                          itemIcon = Icons.search_off;
                        } else if (jenis == 'temuan') {
                          itemIcon = Icons.inventory_2_outlined;
                        } else {
                          itemIcon = Icons.assignment_turned_in_outlined; // Ikon khusus klaim
                        }

                        return _buildStatusCard(
                          title: laporan['namaBarang'].toString(),
                          subtitle: shortDesc,
                          status: statusText,
                          color: statusColor,
                          fotoUrl: laporan['fotoUrl']?.toString(),
                          icon: itemIcon,
                        );
                      }),

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

  // WIDGET BAWAAN (TIDAK ADA YANG BERUBAH SECARA LOGIKA)
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
    String? fotoUrl,
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
            backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty) 
                ? NetworkImage(fotoUrl) 
                : null,
            child: (fotoUrl == null || fotoUrl.isEmpty)
                ? Icon(icon, color: color)
                : null,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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