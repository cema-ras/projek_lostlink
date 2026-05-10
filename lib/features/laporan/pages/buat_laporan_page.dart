import 'dart:convert';
import 'dart:typed_data'; // Digunakan untuk tipe data Uint8List
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../models/report_model.dart';
import '../../../../services/report_service.dart';

class BuatLaporanPage extends StatefulWidget {
  const BuatLaporanPage({super.key});

  @override
  State<BuatLaporanPage> createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  String tipeLaporan = 'Hilang';
  String? kategoriPilihan;
  
  XFile? _imageFile; 
  Uint8List? _imageBytes; // Tambahan: Menyimpan data gambar dalam bentuk memori (Aman untuk Web & HP)
  final ImagePicker _picker = ImagePicker();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, 
      );
      
      if (pickedFile != null) {
        // Langsung baca sebagai bytes saat dipilih
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile; 
          _imageBytes = bytes; // Simpan bytes untuk ditampilkan di UI
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime(2020),   
      lastDate: DateTime.now(),    
    );
    if (picked != null) {
      setState(() {
        tanggalController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Menggunakan Uint8List yang sudah kita simpan di state
  Future<String?> _unggahFotoKeImgBB(Uint8List imageBytes) async {
    try {
      String base64Image = base64Encode(imageBytes);

      String apiKey = '68c8cee554632938c8412ee7eb804d60'; 

      Uri url = Uri.parse('https://api.imgbb.com/1/upload');
      var response = await http.post(url, body: {
        'key': apiKey,
        'image': base64Image,
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['url']; 
      } else {
        debugPrint("Gagal upload: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error upload ImgBB: $e");
      return null;
    }
  }

  void prosesSimpanLaporan() async {
    if (namaController.text.isEmpty ||
        kategoriPilihan == null ||
        deskripsiController.text.isEmpty ||
        lokasiController.text.isEmpty ||
        tanggalController.text.isEmpty ||
        _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom dan foto wajib diisi!')),
      );
      return;
    }

    setState(() { isLoading = true; });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Anda harus login untuk membuat laporan!");
      }

      // Gunakan imageBytes yang sudah ada di memori
      String? finalImageUrl = await _unggahFotoKeImgBB(_imageBytes!);
      
      if (finalImageUrl == null) {
        throw Exception("Gagal mengunggah foto ke server.");
      }

      ReportModel laporanBaru = ReportModel(
        id: "",
        namaBarang: namaController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        fotoUrl: finalImageUrl, 
        jenis: tipeLaporan.toLowerCase(),
        kategoriId: kategoriPilihan!,
        lokasi: lokasiController.text.trim(),
        status: "menunggu",
        tanggalKejadian: tanggalController.text.trim(),
        userId: currentUser.uid,
      );

      await ReportService().tambahLaporan(laporanBaru);

      setState(() { isLoading = false; });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil! Laporan Anda telah disimpan.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Bersihkan form setelah berhasil
      namaController.clear();
      deskripsiController.clear();
      lokasiController.clear();
      tanggalController.clear();
      setState(() { 
        kategoriPilihan = null; 
        _imageFile = null; 
        _imageBytes = null;
      });

    } catch (e) {
      setState(() { isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan laporan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
              const Text('Buat Laporan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Berikan detail informasi barang untuk mempermudah pencarian.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Jenis Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
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
              _buildTextField(controller: namaController, hint: 'Contoh: Dompet Kulit Hitam', icon: Icons.inventory_2_outlined),
              
              _buildLabel('Kategori'),
              _buildDropdownField('Pilih kategori barang'),
              
              _buildLabel('Deskripsi'),
              _buildTextField(controller: deskripsiController, hint: 'Tambahkan detail tambahan...', icon: Icons.description_outlined, maxLines: 3),
              
              _buildLabel('Lokasi Kejadian'),
              _buildTextField(controller: lokasiController, hint: 'Contoh: Gedung A, Lantai 2', icon: Icons.location_on_outlined),
              
              _buildLabel('Tanggal Kejadian'),
              GestureDetector(
                onTap: () => _pilihTanggal(context),
                child: AbsorbPointer( 
                  child: _buildTextField(
                    controller: tanggalController, 
                    hint: 'Pilih Tanggal', 
                    icon: Icons.calendar_today_outlined
                  ),
                ),
              ),
              
              _buildLabel('Foto Barang'),
              _buildUploadBox(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : prosesSimpanLaporan,
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    isLoading ? 'Menyimpan & Mengunggah...' : 'Simpan Laporan',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: isLoading ? null : _pilihFoto, 
      child: Container(
        width: double.infinity,
        padding: _imageBytes == null ? const EdgeInsets.all(24) : EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[100]!, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[50]!.withOpacity(0.3),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // KODE BARU: Menggunakan Image.memory() yang 100% aman untuk Web dan HP
                    Image.memory(
                      _imageBytes!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      onPressed: () {
                        setState(() { 
                          _imageFile = null; 
                          _imageBytes = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: Colors.blue[300]),
                  const SizedBox(height: 8),
                  const Text('Unggah Foto Barang', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Ketuk area ini untuk memilih foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildTypeTab(String title) {
    bool isSelected = tipeLaporan == title;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() { tipeLaporan = title; }); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(top: 16, bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          value: kategoriPilihan,
          items: const [
            DropdownMenuItem(value: 'elektronik', child: Text('Elektronik')),
            DropdownMenuItem(value: 'aksesoris', child: Text('Aksesoris')),
            DropdownMenuItem(value: 'dokumen', child: Text('Dokumen')),
            DropdownMenuItem(value: 'kendaraan', child: Text('Kendaraan')),
            DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
          ],
          onChanged: (value) { setState(() { kategoriPilihan = value; }); },
        ),
      ),
    );
  }
}