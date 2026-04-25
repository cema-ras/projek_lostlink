import 'package:flutter/material.dart';
import '../../laporan/pages/buat_laporan_page.dart';
import '../../laporan/pages/cari_barang_page.dart';
import '../../notifikasi/pages/notifikasi_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Halo, Budi Raharjo',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text('Selamat datang di LOSTLINK', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  )
                ],
              ),
              const SizedBox(height: 25),

              // Statistik Ringkas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('2', 'HILANG', Colors.red.shade100, Colors.red),
                  _buildStatItem('1', 'TEMUAN', Colors.blue.shade100, Colors.blue),
                  _buildStatItem('0', 'KLAIM', Colors.green.shade100, Colors.green),
                ],
              ),
              const SizedBox(height: 30),

              const Text('MENU UTAMA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              // Grid Menu
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2,
                children: [
                  _buildMenuCard(context, 'Laporan Hilang', Icons.add_box_outlined, Colors.blue),
                  _buildMenuCard(context, 'Laporan Temuan', Icons.inventory_2_outlined, Colors.blue),
                  _buildMenuCard(context, 'Cari Barang', Icons.search, Colors.blue),
                  _buildMenuCard(context, 'Ajukan Klaim', Icons.assignment_turned_in_outlined, Colors.blue),
                ],
              ),
              const SizedBox(height: 30),

              const Text('NOTIFIKASI TERBARU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),

              // Daftar Notifikasi (Mockup)
              _buildNotifItem('Barang temuan yang mirip dengan kunci Anda ditemukan.', '15 menit lalu', true),
              _buildNotifItem("Laporan barang hilang 'Dompet Hitam' sedang diverifikasi.", '2 jam lalu', false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, 
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) { // 1: Tombol 'Cari'
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CariBarangPage()));
          } else if (index == 2) { // 2: Tombol 'Lapor'
            Navigator.push(context, MaterialPageRoute(builder: (context) => const BuatLaporanPage()));
          } else if (index == 3) { // 3: Tombol 'Notifikasi'
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiPage()));
          }
        }, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline, 
              size: 35, 
            ), 
            label: 'Lapor'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color bgColor, Color textColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // 1. Logika untuk Laporan Hilang & Temuan
        if (title == 'Laporan Hilang' || title == 'Laporan Temuan') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuatLaporanPage()),
          );
        } 
        // 2. Logika BARU untuk Cari Barang
        else if (title == 'Cari Barang') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CariBarangPage()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Ikon & Teks kembali ke tengah secara vertikal
          crossAxisAlignment: CrossAxisAlignment.center, // Ikon & Teks kembali ke tengah secara horizontal
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10), // Jarak yang pas antara ikon dan teks
            Text(
              title, 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(String text, String time, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: isNew ? Colors.blue : Colors.transparent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}