import 'package:flutter/material.dart';
// 1. TAMBAHKAN IMPORT AUTH SERVICE DI SINI
import '../../../../services/auth_service.dart'; // Sesuaikan jika folder berbeda

// 2. UBAH MENJADI STATEFUL WIDGET AGAR BISA MEMBACA KETIKAN
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 3. BUAT CONTROLLER UNTUK MENANGKAP INPUT TEKS
  final TextEditingController namaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    namaController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // 4. BUAT FUNGSI UNTUK MENGIRIM DATA KE BACKEND
  void prosesDaftar() async {
    final nama = namaController.text.trim();
    final telepon = phoneController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final konfirmasi = confirmPasswordController.text.trim();

    // Validasi 1: Cek apakah ada yang kosong
    if (nama.isEmpty || telepon.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi!')),
      );
      return;
    }

    // Validasi 2: Cek apakah password dan konfirmasi sama
    if (password != konfirmasi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi dan konfirmasi tidak cocok!')),
      );
      return;
    }

    // Ubah string telepon jadi angka (integer) sesuai model database
    int? nomorTelepon = int.tryParse(telepon);
    if (nomorTelepon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon harus berupa angka!')),
      );
      return;
    }

    // Tampilkan loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sedang mendaftarkan akun...')),
    );

    // Panggil mesin Backend AuthService
    var userBaru = await AuthService().registerUser(
      email: email,
      password: password,
      nama: nama,
      noTelepon: nomorTelepon,
    );

    // Logika setelah berhasil atau gagal
    if (userBaru != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran Berhasil! Silakan Login.'),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman Login
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendaftar! Email mungkin sudah digunakan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Header logo kecil
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search, color: Colors.black, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'LOSTLINK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(thickness: 1),
                const SizedBox(height: 20),

                // Logo besar
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF111827),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'LOSTLINK',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Sistem Pelaporan Barang Hilang Kampus',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 24),

                // Card form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab switch
                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Center(
                                  child: Text(
                                    'Masuk',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Daftar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const _FieldLabel('NAMA LENGKAP'),
                      const SizedBox(height: 8),
                      // 5. PASANG CONTROLLER DI SINI
                      _CustomField(
                        controller: namaController,
                        hintText: 'Masukkan nama lengkap Anda',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('NO. TELEPON'),
                      const SizedBox(height: 8),
                      _CustomField(
                        controller: phoneController,
                        hintText: 'Contoh: 08123456789',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('EMAIL'),
                      const SizedBox(height: 8),
                      _CustomField(
                        controller: emailController,
                        hintText: 'Masukkan email Anda',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('KATA SANDI'),
                      const SizedBox(height: 8),
                      _CustomField(
                        controller: passwordController,
                        hintText: 'Buat kata sandi yang aman',
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        showEyeIcon: true,
                        onEyeTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('KONFIRMASI KATA SANDI'),
                      const SizedBox(height: 8),
                      _CustomField(
                        controller: confirmPasswordController,
                        hintText: 'Ulangi kata sandi',
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        showEyeIcon: true,
                        onEyeTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          // 6. PANGGIL FUNGSI prosesDaftar SAAT TOMBOL DITEKAN
                          onPressed: prosesDaftar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                          children: [
                            TextSpan(text: 'Dengan mendaftar, Anda menyetujui '),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: '\nserta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                            ),
                            TextSpan(text: ' LOSTLINK Kampus.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// 7. WIDGET CUSTOM FIELD DIUBAH AGAR BISA MENERIMA CONTROLLER
class _CustomField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool showEyeIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final VoidCallback? onEyeTap;

  const _CustomField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.showEyeIcon = false,
    this.controller,
    this.keyboardType,
    this.onEyeTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: showEyeIcon
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: onEyeTap,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}