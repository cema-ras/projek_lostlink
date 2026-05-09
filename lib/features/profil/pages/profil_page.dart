import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilPage extends StatefulWidget {
  final VoidCallback? onOpenEditProfile;
  final VoidCallback? onOpenSecurity;
  final VoidCallback? onOpenHistory;

  const ProfilPage({
    super.key,
    this.onOpenEditProfile,
    this.onOpenSecurity,
    this.onOpenHistory,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _nama = 'Memuat...';
  String _deskripsi = 'Memuat data...';
  String? _fotoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Mengambil data user secara realtime
  void _loadUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/${user.uid}');
      
      // Menggunakan onValue agar ketika diedit, halaman ini otomatis update
      userRef.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map;
          if (mounted) {
            setState(() {
              _nama = data['nama'] ?? 'Pengguna LOSTLINK';
              _deskripsi = data['jurusan'] ?? 'Belum ada jurusan';
              _fotoUrl = data['fotoUrl'];
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _nama = 'Pengguna Tidak Ditemukan';
              _deskripsi = '-';
              _isLoading = false;
            });
          }
        }
      });
    }
  }

  // Fungsi untuk Logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Aplikasi otomatis akan diarahkan ke halaman login jika kamu
      // sudah menggunakan StreamBuilder (authStateChanges) di main.dart
      // atau file navigasi utamamu.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e'), backgroundColor: Colors.red),
      );
    }
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
              _buildLogoHeader(),

              const SizedBox(height: 24),

              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Kelola informasi akun dan aktivitas laporan Anda.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // KARTU PROFIL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _fotoUrl != null && _fotoUrl!.isNotEmpty
                                ? NetworkImage(_fotoUrl!)
                                : null,
                            child: _fotoUrl == null || _fotoUrl!.isEmpty
                                ? const Icon(Icons.person, size: 45, color: Colors.grey)
                                : null,
                          ),

                          const SizedBox(height: 14),

                          Text(
                            _nama,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _deskripsi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Akun Terverifikasi',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // INFO CARD (STATISTIK DUMMY SEMENTARA)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      count: '2', // Bisa dikoneksikan ke hitungan tabel laporan nantinya
                      label: 'Laporan Hilang',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      count: '1',
                      label: 'Laporan Temuan',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      count: '3',
                      label: 'Status',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'PENGATURAN AKUN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 14),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                subtitle: 'Ubah nama, email, dan nomor telepon',
                onTap: widget.onOpenEditProfile ?? () {},
              ),

              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Keamanan Akun',
                subtitle: 'Ubah kata sandi akun Anda',
                onTap: widget.onOpenSecurity ?? () {},
              ),

              _buildMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Riwayat Laporan',
                subtitle: 'Lihat laporan hilang, temuan, dan klaim',
                onTap: widget.onOpenHistory ?? () {},
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                subtitle: 'Panduan penggunaan aplikasi LOSTLINK',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur bantuan belum tersedia.'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // TOMBOL LOGOUT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Tampilkan dialog konfirmasi sebelum benar-benar keluar
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar Akun'),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Tutup dialog
                              _logout(); // Panggil fungsi logout
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
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
        const SizedBox(width: 10),
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

  Widget _buildInfoCard({
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ),
    );
  }
}