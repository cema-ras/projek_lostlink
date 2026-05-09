import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfilPage extends StatefulWidget {
  final VoidCallback? onBack;

  const EditProfilPage({
    super.key,
    this.onBack,
  });

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController jurusanController = TextEditingController();

  bool isLoading = true; // Untuk loading ambil data awal
  bool isSaving = false; // Untuk loading saat tombol simpan ditekan

  File? _imageFile;
  String? _currentFotoUrl;
  final ImagePicker _picker = ImagePicker();

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
    jurusanController.dispose();
    super.dispose();
  }

  // 1. MENGAMBIL DATA DARI FIREBASE
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
            jurusanController.text = data['jurusan'] ?? '';
            _currentFotoUrl = data['fotoUrl']; // Ambil foto profil jika ada
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

  // 2. MEMILIH FOTO DARI GALERI
  Future<void> _pilihFoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
  }

  // 3. MENGUNGGAH FOTO KE IMGBB
  Future<String?> _unggahFotoKeImgBB(File foto) async {
    try {
      List<int> imageBytes = await foto.readAsBytes();
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
        print("Gagal upload: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error upload ImgBB: $e");
      return null;
    }
  }

  // 4. MENYIMPAN PERUBAHAN KE FIREBASE
  Future<void> simpanProfil() async {
    if (namaController.text.isEmpty || teleponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Nomor Telepon wajib diisi!')),
      );
      return;
    }

    setState(() { isSaving = true; });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User tidak ditemukan.");

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref('users/${currentUser.uid}');

      String? finalFotoUrl = _currentFotoUrl; // Default pakai foto lama

      // Jika user memilih foto baru, unggah dulu ke ImgBB
      if (_imageFile != null) {
        String? newUploadedUrl = await _unggahFotoKeImgBB(_imageFile!);
        if (newUploadedUrl != null) {
          finalFotoUrl = newUploadedUrl;
        } else {
          throw Exception("Gagal mengunggah foto profil.");
        }
      }

      // Update data di Firebase Realtime Database
      await userRef.update({
        'nama': namaController.text.trim(),
        'noTelepon': teleponController.text.trim(),
        'jurusan': jurusanController.text.trim(),
        'fotoUrl': finalFotoUrl,
      });

      // Update state lokal agar foto terbaru langsung tampil tanpa refresh
      setState(() {
        _currentFotoUrl = finalFotoUrl;
        _imageFile = null; // Reset file yang dipilih setelah sukses
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        // Jika data masih ditarik, tampilkan loading layar penuh
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
                      'Edit Profil',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ubah informasi akun Anda dengan data yang benar.',
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
                            child: (_imageFile == null && _currentFotoUrl == null)
                                ? const Icon(Icons.person, size: 50, color: Colors.grey)
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
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 18),
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
                      isReadOnly: true, // Email sebaiknya tidak bisa diubah sembarangan
                    ),

                    _buildLabel('Nomor Telepon'),
                    _buildTextField(
                      controller: teleponController,
                      hint: 'Masukkan nomor telepon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildLabel('Program Studi / Jurusan'),
                    _buildTextField(
                      controller: jurusanController,
                      hint: 'Masukkan jurusan',
                      icon: Icons.school_outlined,
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

  // Fungsi pembantu untuk menentukan gambar mana yang akan dirender
  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!); // Prioritas 1: Gambar yang baru dipilih
    } else if (_currentFotoUrl != null) {
      return NetworkImage(_currentFotoUrl!); // Prioritas 2: Gambar lama dari DB
    }
    return null; // Prioritas 3: Ikon default (diatur di widget child)
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'LOSTLINK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}