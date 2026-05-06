import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

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
                'Notifikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Pantau informasi terbaru dari laporan dan klaim Anda.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              _buildNotificationCard(
                icon: Icons.search,
                title: 'Barang Mirip Ditemukan',
                description:
                    'Barang temuan yang mirip dengan kunci motor Anda ditemukan di Parkiran Gedung A.',
                time: '15 menit lalu',
                isNew: true,
              ),

              _buildNotificationCard(
                icon: Icons.verified_outlined,
                title: 'Laporan Diverifikasi',
                description:
                    "Laporan barang hilang 'Dompet Hitam' sedang diverifikasi oleh admin.",
                time: '2 jam lalu',
                isNew: false,
              ),

              _buildNotificationCard(
                icon: Icons.assignment_turned_in_outlined,
                title: 'Status Klaim Diperbarui',
                description:
                    'Klaim barang Anda sedang menunggu pemeriksaan bukti kepemilikan.',
                time: 'Kemarin',
                isNew: false,
              ),

              _buildNotificationCard(
                icon: Icons.info_outline,
                title: 'Informasi Sistem',
                description:
                    'Pastikan data laporan barang hilang dibuat dengan jelas dan lengkap.',
                time: '2 hari lalu',
                isNew: false,
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

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNew ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: isNew ? Colors.blue.shade50 : Colors.grey.shade100,
            child: Icon(
              icon,
              color: isNew ? Colors.blue : Colors.grey,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}