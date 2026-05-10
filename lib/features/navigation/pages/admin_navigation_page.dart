import 'package:flutter/material.dart';

import '../../admin/pages/admin_page.dart';
import '../../admin/pages/admin_profil_page.dart';
import '../../admin/pages/admin_edit_profil_page.dart';
import '../../profil/pages/keamanan_akun_page.dart';

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
      currentIndex = 1; // Berubah dari 2 ke 1 karena tab Notifikasi dihapus
      halamanTambahan = AdminEditProfilPage(
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
      currentIndex = 1; // Berubah dari 2 ke 1 karena tab Notifikasi dihapus
      halamanTambahan = KeamananAkunPage(
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
      AdminProfilPage(
        onOpenEditProfile: bukaEditProfil,
        onOpenSecurity: bukaKeamananAkun,
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
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}