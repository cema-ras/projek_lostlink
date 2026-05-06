import 'package:flutter/material.dart';

class BuatLaporanPage extends StatefulWidget {
  const BuatLaporanPage({super.key});

  @override
  State<BuatLaporanPage> createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  String tipeLaporan = 'Hilang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoHeader(),

              const SizedBox(height: 24),

              const Text(
                'Buat Laporan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Berikan detail informasi barang untuk mempermudah pencarian.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              const Text(
                'Jenis Laporan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTypeTab('Hilang'),
                    _buildTypeTab('Temuan'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Nama Barang'),
              _buildTextField(
                'Contoh: Dompet Kulit Hitam',
                Icons.inventory_2_outlined,
              ),

              _buildLabel('Kategori'),
              _buildDropdownField('Pilih kategori barang'),

              _buildLabel('Deskripsi'),
              _buildTextField(
                'Tambahkan detail tambahan...',
                Icons.description_outlined,
                maxLines: 3,
              ),

              _buildLabel('Lokasi Kejadian'),
              _buildTextField(
                'Contoh: Gedung A, Lantai 2',
                Icons.location_on_outlined,
              ),

              _buildLabel('Tanggal Kejadian'),
              _buildTextField(
                'Pilih Tanggal',
                Icons.calendar_today_outlined,
              ),

              _buildLabel('Foto Barang'),
              _buildUploadBox(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Laporan berhasil disimpan.'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Simpan Laporan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildTypeTab(String title) {
    bool isSelected = tipeLaporan == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            tipeLaporan = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          items: const [
            DropdownMenuItem(
              value: 'Elektronik',
              child: Text('Elektronik'),
            ),
            DropdownMenuItem(
              value: 'Aksesoris',
              child: Text('Aksesoris'),
            ),
            DropdownMenuItem(
              value: 'Dokumen',
              child: Text('Dokumen'),
            ),
            DropdownMenuItem(
              value: 'Lainnya',
              child: Text('Lainnya'),
            ),
          ],
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue[100]!,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue[50]!.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 8),
          const Text(
            'Unggah Foto Barang',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Pastikan foto jelas dan terang',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Pilih Berkas'),
          ),
        ],
      ),
    );
  }
}