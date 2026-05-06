import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onOpenStatus;

  const DashboardPage({
    super.key,
    this.onNavigate,
    this.onOpenStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, Budi Raharjo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Selamat datang di LOSTLINK',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onNavigate?.call(4);
                    },
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=11'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    '2',
                    'HILANG',
                    Colors.red.shade100,
                    Colors.red,
                  ),
                  _buildStatItem(
                    '1',
                    'TEMUAN',
                    Colors.blue.shade100,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    '3',
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
                    onTap: () => onNavigate?.call(2),
                  ),
                  _buildMenuCard(
                    title: 'Laporan Temuan',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    onTap: () => onNavigate?.call(2),
                  ),
                  _buildMenuCard(
                    title: 'Cari Barang',
                    icon: Icons.search,
                    color: Colors.blue,
                    onTap: () => onNavigate?.call(1),
                  ),
                  _buildMenuCard(
                    title: 'Status Barang',
                    icon: Icons.assignment_turned_in_outlined,
                    color: Colors.blue,
                    onTap: () => onOpenStatus?.call(),
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

              _buildStatusCard(
                title: 'Dompet Kulit Hitam',
                subtitle: 'Laporan hilang sedang diverifikasi.',
                status: 'Verifikasi',
                color: Colors.orange,
                icon: Icons.wallet_outlined,
              ),
              _buildStatusCard(
                title: 'Kunci Motor Honda',
                subtitle: 'Barang mirip ditemukan di Parkiran Gedung A.',
                status: 'Ditemukan',
                color: Colors.green,
                icon: Icons.vpn_key_outlined,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onOpenStatus?.call(),
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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