import 'package:flutter/material.dart';

class RiwayatLaporanPage extends StatelessWidget {
  final VoidCallback? onBack;

  const RiwayatLaporanPage({
    super.key,
    this.onBack,
  });

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

              _buildHistoryCard(
                title: 'Dompet Kulit Hitam',
                type: 'HILANG',
                location: 'Perpustakaan Pusat',
                date: '10/05/2024',
                status: 'Aktif',
                color: Colors.red,
                icon: Icons.wallet_outlined,
              ),

              _buildHistoryCard(
                title: 'Kunci Motor Honda',
                type: 'HILANG',
                location: 'Parkiran Gedung A',
                date: '12/05/2024',
                status: 'Barang Mirip Ditemukan',
                color: Colors.orange,
                icon: Icons.vpn_key_outlined,
              ),

              _buildHistoryCard(
                title: 'Laptop MacBook Air',
                type: 'TEMUAN',
                location: 'Kantin Kejujuran Lt. 2',
                date: '11/05/2024',
                status: 'Menunggu Verifikasi',
                color: Colors.blue,
                icon: Icons.laptop_mac,
              ),

              _buildHistoryCard(
                title: 'MacBook Pro M2',
                type: 'KLAIM',
                location: 'Perpustakaan Pusat',
                date: '25/10/2023',
                status: 'Disetujui',
                color: Colors.green,
                icon: Icons.assignment_turned_in_outlined,
              ),

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
          onPressed: onBack,
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
            count: '2',
            label: 'Hilang',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallBox(
            count: '1',
            label: 'Temuan',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallBox(
            count: '1',
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$location • $date',
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