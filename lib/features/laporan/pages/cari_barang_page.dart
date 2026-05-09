import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Tambahan untuk ambil data
import 'detail_laporan_page.dart';

class CariBarangPage extends StatefulWidget {
  const CariBarangPage({super.key});

  @override
  State<CariBarangPage> createState() => _CariBarangPageState();
}

class _CariBarangPageState extends State<CariBarangPage> {
  // Variabel untuk menampung status filter
  String filterAktif = 'Semua'; // Tab Hilang/Temuan
  String searchQuery = ''; // Kata kunci pencarian
  String filterKategori = 'Semua Kategori'; // Dropdown kategori

  // Referensi ke tabel database (sesuaikan jika nama tabelmu berbeda, misal: 'reports')
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('reports');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column( // Ubah dari SingleChildScrollView jadi Column agar list bisa scroll sendiri
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoHeader(),
                  const SizedBox(height: 24),
                  const Text('Cari Barang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Cari barang berdasarkan nama, kategori, atau lokasi', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 15),
                  _buildFilterTabs(),
                  const SizedBox(height: 15),
                  _buildDropdownRow(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // BAGIAN INI YANG KITA UBAH MENJADI STREAMBUILDER (LIVE DATA)
            Expanded(
              child: StreamBuilder(
                stream: _dbRef.onValue,
                builder: (context, snapshot) {
                  // Jika masih loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Jika tidak ada data
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(child: Text('Belum ada laporan yang tersedia.'));
                  }

                  // Ambil data dari Firebase dan ubah ke bentuk List
                  Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> listLaporan = [];
                  
                  dataMap.forEach((key, value) {
                    var item = value as Map<dynamic, dynamic>;
                    item['id'] = key; // simpan ID unik
                    listLaporan.add(item);
                  });

                  // LAKUKAN PENYARINGAN (FILTERING)
                  var filteredList = listLaporan.where((item) {
                    bool matchTab = filterAktif == 'Semua' || 
                                    item['jenis'].toString().toLowerCase() == filterAktif.toLowerCase();
                    
                    bool matchSearch = item['namaBarang'].toString().toLowerCase().contains(searchQuery.toLowerCase());
                    
                    bool matchKategori = filterKategori == 'Semua Kategori' || 
                                         item['kategoriId'].toString().toLowerCase() == filterKategori.toLowerCase();

                    return matchTab && matchSearch && matchKategori;
                  }).toList();

                  // Urutkan dari yang terbaru (opsional, tergantung struktur tanggal/ID)
                  filteredList = filteredList.reversed.toList();

                  if (filteredList.isEmpty) {
                    return const Center(child: Text('Barang tidak ditemukan.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      var item = filteredList[index];
                      
                      return _buildItemCard(
                        item: item, // <-- INI YANG DITAMBAHKAN AGAR DATANYA TERKIRIM
                        title: item['namaBarang'] ?? 'Tanpa Nama',
                        loc: item['lokasi'] ?? 'Lokasi tidak diketahui',
                        date: item['tanggalKejadian'] ?? '-',
                        tag: item['jenis'].toString().toUpperCase(),
                        tagColor: item['jenis'].toString().toLowerCase() == 'hilang' ? Colors.red : Colors.blue,
                        status: item['status'] ?? 'Menunggu',
                        fotoUrl: item['fotoUrl'],
                        kategori: item['kategoriId']?.toString().toUpperCase() ?? 'LAINNYA',
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
      onChanged: (value) {
        // Update state setiap kali user mengetik
        setState(() { searchQuery = value; });
      },
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
              onTap: () { setState(() { filterAktif = tab; }); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isAktif ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isAktif ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isAktif ? Colors.black : Colors.grey),
                  ),
                ),
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
        // Menggunakan DropdownButton asli agar bisa diklik
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: filterKategori,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                items: ['Semua Kategori', 'Elektronik', 'Aksesoris', 'Dokumen', 'Kendaraan', 'Lainnya'].map((String val) {
                  return DropdownMenuItem<String>(value: val, child: Text(val));
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) setState(() { filterKategori = newValue; });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Parameter _buildItemCard disesuaikan agar menerima Map "item"
  Widget _buildItemCard({
    required Map<dynamic, dynamic> item, // <-- INI YANG DITAMBAHKAN
    required String title,
    required String loc,
    required String date,
    required String tag,
    required Color tagColor,
    required String status,
    required String? fotoUrl,
    required String kategori,
  }) {
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
                child: Container(
                  color: Colors.grey[300],
                  width: 80,
                  height: 80,
                  // Menampilkan foto dari internet (ImgBB)
                  child: fotoUrl != null && fotoUrl.isNotEmpty
                      ? Image.network(
                          fotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KATEGORI: $kategori', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // Navigasi dengan membawa seluruh data item ke halaman detail
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => DetailLaporanPage(reportData: item), // Sekarang aman karena 'item' sudah dikenali!
                    )
                  );
                },
                child: const Text('Lihat Detail >', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}