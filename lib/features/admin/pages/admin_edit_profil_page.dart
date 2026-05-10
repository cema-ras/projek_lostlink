import 'dart:convert';
import 'dart:typed_data'; // PENTING: Pengganti dart:io untuk Web
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../services/auth_service.dart'; 

class AdminEditProfilPage extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminEditProfilPage({
    super.key,
    this.onBack,
  });

  @override
  State<AdminEditProfilPage> createState() => _AdminEditProfilPageState();
}

class _AdminEditProfilPageState extends State<AdminEditProfilPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  bool isLoading = true; 
  bool isSaving = false; 

  // PERBAIKAN 1: Ganti File? menjadi Uint8List? agar support Web
  Uint8List? _imageBytes; 
  String? _currentFotoUrl;
  final ImagePicker _picker = ImagePicker();
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadDataUser();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    teleponController.dispose();
    super.dispose();
  }

  Future<void> _loadDataUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/${currentUser.uid}');

      try {
        DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          Map data = snapshot.value as Map;
          setState(() {
            namaController.text = data['nama'] ?? '';
            emailController.text = data['email'] ?? '';
            teleponController.text = data['noTelepon']?.toString() ?? '';
            
            String? dbFoto = data['fotoUrl'];
            _currentFotoUrl = (dbFoto != null && dbFoto.trim().isNotEmpty) ? dbFoto : null;
            
            isLoading = false;
          });
        } else {
          setState(() { isLoading = false; });
        }
      } catch (e) {
        setState(() { isLoading = false; });
        print("Gagal mengambil data: $e");
      }
    }
  }

  // PERBAIKAN 2: Ambil gambar sebagai Bytes, bukan File path
  Future<void> _pilihFoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        // Gunakan readAsBytes() agar aman di Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showSnackBar('Gagal memilih foto: $e', Colors.red);
    }
  }

  // PERBAIKAN 3: Kirim gambar via fromBytes (Support Web & Mobile)
  Future<String?> _unggahFotoKeImgBB(Uint8List imageBytes) async {
    try {
      String apiKey = '68c8cee554632938c8412ee7eb804d60';
      Uri url = Uri.parse('https://api.imgbb.com/1/upload');

      var request = http.MultipartRequest('POST', url);
      request.fields['key'] = apiKey;
      
      // Pakai fromBytes karena Web tidak punya "path"
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'upload.png'));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['data']['url']; 
      } else {
        print("Gagal upload ImgBB, status: ${response.statusCode}, pesan: $responseData");
        return null;
      }
    } catch (e) {
      print("Error upload ImgBB: $e");
      return null;
    }
  }

  Future<void> simpanProfil() async {
    if (namaController.text.trim().isEmpty || teleponController.text.trim().isEmpty) {
      _showSnackBar('Nama dan Nomor Telepon wajib diisi!', Colors.orange);
      return;
    }

    int? parsedTelepon = int.tryParse(teleponController.text.trim());
    if (parsedTelepon == null) {
      _showSnackBar('Nomor telepon tidak valid!', Colors.orange);
      return;
    }

    setState(() { isSaving = true; });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User tidak ditemukan.");

      String? finalFotoUrl = _currentFotoUrl; 

      // Unggah foto jika ada (sekarang memakai _imageBytes)
      if (_imageBytes != null) {
        String? newUploadedUrl = await _unggahFotoKeImgBB(_imageBytes!);
        if (newUploadedUrl != null) {
          finalFotoUrl = newUploadedUrl;
        } else {
          throw Exception("Gagal mengunggah foto profil.");
        }
      }

      bool isUpdateSuccess = await _authService.updateUserProfile(
        userId: currentUser.uid,
        namaBaru: namaController.text.trim(),
        noTeleponBaru: parsedTelepon,
        jurusanBaru: "-", // Tetap dikirim default "-" agar tidak error di auth_service.dart
      );

      if (!isUpdateSuccess) {
        throw Exception("Gagal memperbarui profil teks.");
      }

      if (finalFotoUrl != _currentFotoUrl) {
         await FirebaseDatabase.instance
            .ref('users/${currentUser.uid}')
            .update({'fotoUrl': finalFotoUrl});
      }

      setState(() {
        _currentFotoUrl = finalFotoUrl;
        _imageBytes = null; 
      });

      _showSnackBar('Profil berhasil diperbarui.', Colors.green);
    } catch (e) {
      _showSnackBar('Gagal menyimpan profil: $e', Colors.red);
    } finally {
      setState(() { isSaving = false; });
    }
  }

  void _showSnackBar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    const Text(
                      'Edit Profil Admin',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pastikan data nama dan nomor telepon Anda sudah benar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // FOTO PROFIL SECTION
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _getProfileImage(),
                            child: (_imageBytes == null && (_currentFotoUrl == null || _currentFotoUrl!.isEmpty))
                                ? const Icon(Icons.admin_panel_settings, size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 18,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: isSaving ? null : _pilihFoto,
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildLabel('Nama Lengkap'),
                    _buildTextField(
                      controller: namaController,
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                    ),

                    _buildLabel('Email'),
                    _buildTextField(
                      controller: emailController,
                      hint: 'Masukkan email',
                      icon: Icons.email_outlined,
                      isReadOnly: true, 
                    ),

                    _buildLabel('Nomor WhatsApp (Aktif)'),
                    _buildTextField(
                      controller: teleponController,
                      hint: 'Contoh: 08123...',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL SIMPAN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : simpanProfil,
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : const Icon(Icons.save_outlined, color: Colors.white),
                        label: Text(
                          isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

  // PERBAIKAN 4: Tampilkan MemoryImage untuk preview foto baru
  ImageProvider? _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!); 
    if (_currentFotoUrl != null && _currentFotoUrl!.trim().isNotEmpty) {
      return NetworkImage(_currentFotoUrl!); 
    }
    return null; 
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
        const Expanded(
          child: Center(
            child: Text('LOSTLINK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: isReadOnly ? Colors.grey[700] : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isReadOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}