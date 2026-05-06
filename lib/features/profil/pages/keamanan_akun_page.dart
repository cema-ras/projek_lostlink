import 'package:flutter/material.dart';

class KeamananAkunPage extends StatefulWidget {
  final VoidCallback? onBack;

  const KeamananAkunPage({
    super.key,
    this.onBack,
  });

  @override
  State<KeamananAkunPage> createState() => _KeamananAkunPageState();
}

class _KeamananAkunPageState extends State<KeamananAkunPage> {
  final TextEditingController sandiLamaController = TextEditingController();
  final TextEditingController sandiBaruController = TextEditingController();
  final TextEditingController konfirmasiSandiController =
      TextEditingController();

  bool obscureLama = true;
  bool obscureBaru = true;
  bool obscureKonfirmasi = true;

  @override
  void dispose() {
    sandiLamaController.dispose();
    sandiBaruController.dispose();
    konfirmasiSandiController.dispose();
    super.dispose();
  }

  void ubahKataSandi() {
    final lama = sandiLamaController.text.trim();
    final baru = sandiBaruController.text.trim();
    final konfirmasi = konfirmasiSandiController.text.trim();

    if (lama.isEmpty || baru.isEmpty || konfirmasi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom wajib diisi.'),
        ),
      );
      return;
    }

    if (baru != konfirmasi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak sesuai.'),
        ),
      );
      return;
    }

    if (baru.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru minimal 6 karakter.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil diperbarui.'),
      ),
    );

    sandiLamaController.clear();
    sandiBaruController.clear();
    konfirmasiSandiController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 24),

              const Text(
                'Keamanan Akun',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Ubah kata sandi akun agar tetap aman.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Gunakan kata sandi yang kuat dan jangan bagikan kepada orang lain.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildLabel('Kata Sandi Lama'),
              _buildPasswordField(
                controller: sandiLamaController,
                hint: 'Masukkan kata sandi lama',
                obscureText: obscureLama,
                onToggle: () {
                  setState(() {
                    obscureLama = !obscureLama;
                  });
                },
              ),

              _buildLabel('Kata Sandi Baru'),
              _buildPasswordField(
                controller: sandiBaruController,
                hint: 'Masukkan kata sandi baru',
                obscureText: obscureBaru,
                onToggle: () {
                  setState(() {
                    obscureBaru = !obscureBaru;
                  });
                },
              ),

              _buildLabel('Konfirmasi Kata Sandi Baru'),
              _buildPasswordField(
                controller: konfirmasiSandiController,
                hint: 'Ulangi kata sandi baru',
                obscureText: obscureKonfirmasi,
                onToggle: () {
                  setState(() {
                    obscureKonfirmasi = !obscureKonfirmasi;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: ubahKataSandi,
                  icon: const Icon(Icons.lock_reset, color: Colors.white),
                  label: const Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
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