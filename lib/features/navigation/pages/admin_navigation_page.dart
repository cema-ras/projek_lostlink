import 'package:flutter/material.dart';

import '../../admin/pages/admin_page.dart';
import '../../notifikasi/pages/notifikasi_page.dart';
import '../../profil/pages/profil_page.dart';
import '../../profil/pages/edit_profil_page.dart';
import '../../profil/pages/keamanan_akun_page.dart';
import '../../profil/pages/riwayat_laporan_page.dart';

class AdminNavigationPage extends StatefulWidget {
  const AdminNavigationPage({super.key});

  @override
  State<AdminNavigationPage> createState() => _AdminNavigationPageState();
}

class _AdminNavigationPageState extends State<AdminNavigationPage> {
  int currentIndex = 0;
  Widget? halamanTambahan;

  void pindahHalaman(int index) {
    setState(() {
      currentIndex = index;
      halamanTambahan = null;
    });
  }

  void bukaEditProfil() {
    setState(() {
      currentIndex = 2;
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
      currentIndex = 2;
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
      currentIndex = 2;
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
    final List<Widget> halamanAdmin = [
      const AdminPage(),
      const NotifikasiPage(),
      ProfilPage(
        nama: 'Admin LOSTLINK',
        deskripsi: 'Pengelola Sistem LOSTLINK',
        onOpenEditProfile: bukaEditProfil,
        onOpenSecurity: bukaKeamananAkun,
        onOpenHistory: bukaRiwayatLaporan,
      ),
    ];

    return Scaffold(
      body: halamanTambahan ??
          IndexedStack(
            index: currentIndex,
            children: halamanAdmin,
          ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: pindahHalaman,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            label: 'Admin',
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