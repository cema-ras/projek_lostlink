import 'package:flutter/material.dart';
import 'detail_laporan_page.dart';

class CariBarangPage extends StatefulWidget {
  const CariBarangPage({super.key});

  @override
  State<CariBarangPage> createState() => _CariBarangPageState();
}

class _CariBarangPageState extends State<CariBarangPage> {
  String filterAktif = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildLogoHeader(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cari Barang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Cari barang berdasarkan nama, kategori, atau lokasi', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 15),

            // Tab Filter (Semua, Hilang, Temuan)
            _buildFilterTabs(),
            const SizedBox(height: 15),

            // Dropdown Kategori & Status
            _buildDropdownRow(),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Menampilkan 4 laporan terbaru', style: TextStyle(fontSize: 12, color: Colors.grey)),
                _buildBadgeTerverifikasi(),
              ],
            ),
            const SizedBox(height: 15),

            // List Barang (Mockup)
            _buildItemCard('Kunci Motor Honda', 'Parkiran Gedung A', '12/05/2024', 'HILANG', Colors.red, 'Aktif'),
            _buildItemCard('Laptop MacBook Air', 'Kantin Kejujuran Lt. 2', '11/05/2024', 'TEMUAN', Colors.blue, 'Menunggu Verifikasi'),
            _buildItemCard('Dompet Kulit Cokelat', 'Perpustakaan Pusat', '10/05/2024', 'HILANG', Colors.red, 'Aktif'),
            
            const SizedBox(height: 20),
            _buildLoadMoreButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Logo di Header (Konsisten dengan Buat Laporan)
  Widget _buildLogoHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle),
          child: const Icon(Icons.search, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text('LOSTLINK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari berdasarkan nama barang...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ['Semua', 'Hilang', 'Temuan'].map((tab) {
          bool isAktif = filterAktif == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => filterAktif = tab),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isAktif ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isAktif ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                child: Center(child: Text(tab, style: TextStyle(fontWeight: FontWeight.bold, color: isAktif ? Colors.black : Colors.grey))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: [
        Expanded(child: _buildSmallDropdown('Semua Kategori')),
        const SizedBox(width: 10),
        Expanded(child: _buildSmallDropdown('Laporan Aktif')),
      ],
    );
  }

  Widget _buildSmallDropdown(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildItemCard(String title, String loc, String date, String tag, Color tagColor, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(color: Colors.grey[300], width: 80, height: 80, child: const Icon(Icons.image, color: Colors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(6)),
                          child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text(status, style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                    Row(children: [const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('KATEGORI: AKSESORIS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DetailLaporanPage()),
                  );
                }, 
                child: const Text('Lihat Detail >', style: TextStyle(fontSize: 12))
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadgeTerverifikasi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(Icons.check_circle, size: 14, color: Colors.blue[600]), const SizedBox(width: 4), Text('TERVERIFIKASI', style: TextStyle(color: Colors.blue[600], fontSize: 10, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Muat Lebih Banyak', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}