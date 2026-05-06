import 'package:flutter/material.dart';

import '../../dashboard/pages/dashboard_page.dart';
import '../../laporan/pages/cari_barang_page.dart';
import '../../laporan/pages/buat_laporan_page.dart';
import '../../notifikasi/pages/notifikasi_page.dart';
import '../../profil/pages/profil_page.dart';
import '../../profil/pages/edit_profil_page.dart';
import '../../profil/pages/keamanan_akun_page.dart';
import '../../profil/pages/riwayat_laporan_page.dart';
import '../../klaim/pages/status_klaim_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int currentIndex = 0;
  Widget? halamanTambahan;

  void pindahHalaman(int index) {
    setState(() {
      currentIndex = index;
      halamanTambahan = null;
    });
  }

  void bukaStatusBarang() {
    setState(() {
      currentIndex = 0;
      halamanTambahan = const StatusKlaimPage();
    });
  }

  void bukaEditProfil() {
    setState(() {
      currentIndex = 4;
      halamanTambahan = EditProfilPage(
        onBack: () {
          setState(() {
            halamanTambahan = null;
          });
        },
      );
    });
  }

  void bukaKeamananAkun() {
    setState(() {
      currentIndex = 4;
      halamanTambahan = KeamananAkunPage(
        onBack: () {
          setState(() {
            halamanTambahan = null;
          });
        },
      );
    });
  }

  void bukaRiwayatLaporan() {
    setState(() {
      currentIndex = 4;
      halamanTambahan = RiwayatLaporanPage(
        onBack: () {
          setState(() {
            halamanTambahan = null;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> halamanUtama = [
      DashboardPage(
        onNavigate: pindahHalaman,
        onOpenStatus: bukaStatusBarang,
      ),
      const CariBarangPage(),
      const BuatLaporanPage(),
      const NotifikasiPage(),
      ProfilPage(
        onOpenEditProfile: bukaEditProfil,
        onOpenSecurity: bukaKeamananAkun,
        onOpenHistory: bukaRiwayatLaporan,
      ),
    ];

    return Scaffold(
      body: halamanTambahan ??
          IndexedStack(
            index: currentIndex,
            children: halamanUtama,
          ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        showUnselectedLabels: true,
        onTap: pindahHalaman,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}