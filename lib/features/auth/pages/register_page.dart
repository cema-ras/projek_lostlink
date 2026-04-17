import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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

                // Ilustrasi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 8,
                        top: 0,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color: Colors.blue.shade100,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 0,
                        child: Icon(
                          Icons.search,
                          size: 60,
                          color: Colors.blue.shade100,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleIcon(Icons.search, Colors.blue),
                          const SizedBox(width: 14),
                          _circleIcon(Icons.location_on_outlined, Colors.cyan),
                          const SizedBox(width: 14),
                          _circleIcon(Icons.person_outline, Colors.blue),
                        ],
                      ),
                    ],
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
                      const _CustomField(
                        hintText: 'Masukkan nama lengkap Anda',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('NO. TELEPON'),
                      const SizedBox(height: 8),
                      const _CustomField(
                        hintText: 'Contoh: 08123456789',
                        icon: Icons.phone_outlined,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('EMAIL'),
                      const SizedBox(height: 8),
                      const _CustomField(
                        hintText: 'Masukkan email Anda',
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('KATA SANDI'),
                      const SizedBox(height: 8),
                      const _CustomField(
                        hintText: 'Buat kata sandi yang aman',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        showEyeIcon: true,
                      ),

                      const SizedBox(height: 16),

                      const _FieldLabel('KONFIRMASI KATA SANDI'),
                      const SizedBox(height: 8),
                      const _CustomField(
                        hintText: 'Ulangi kata sandi',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        showEyeIcon: true,
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur daftar belum dihubungkan ke backend.'),
                              ),
                            );
                          },
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
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: 'Dengan mendaftar, Anda menyetujui ',
                            ),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: '\nserta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
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

  static Widget _circleIcon(IconData icon, Color color) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 28),
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

class _CustomField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool showEyeIcon;

  const _CustomField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.showEyeIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: showEyeIcon
            ? const Icon(Icons.visibility_outlined, color: Colors.grey)
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