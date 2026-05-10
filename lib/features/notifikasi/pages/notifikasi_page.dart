import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late Query _notifikasiQuery;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserId != null) {
      _notifikasiQuery = FirebaseDatabase.instance
          .ref('notifications')
          .orderByChild('userId')
          .equalTo(currentUserId);
    }
  }

  // --- FUNGSI BARU: Mengubah status 'unread' menjadi 'read' di Firebase ---
  Future<void> _tandaiSudahDibaca(String notifId) async {
    try {
      await FirebaseDatabase.instance
          .ref('notifications')
          .child(notifId)
          .update({'status': 'read'});
    } catch (e) {
      debugPrint("Gagal update status notifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 24),
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pantau informasi terbaru dari laporan dan klaim Anda.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              StreamBuilder(
                stream: _notifikasiQuery.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Belum ada notifikasi baru.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  Map<dynamic, dynamic> dataMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<Map<dynamic, dynamic>> listNotifikasi = [];

                  dataMap.forEach((key, value) {
                    var item = value as Map<dynamic, dynamic>;
                    item['id'] = key;
                    listNotifikasi.add(item);
                  });

                  listNotifikasi = listNotifikasi.reversed.toList();

                  return ListView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: listNotifikasi.length,
                    itemBuilder: (context, index) {
                      var notif = listNotifikasi[index];

                      IconData iconNotif = Icons.notifications_none;
                      String tipe = (notif['tipe'] ?? '').toString().toLowerCase();
                      
                      if (tipe == 'temuan' || tipe == 'hilang') {
                        iconNotif = Icons.search;
                      } else if (tipe == 'verifikasi') {
                        iconNotif = Icons.verified_outlined;
                      } else if (tipe == 'klaim') {
                        iconNotif = Icons.assignment_turned_in_outlined;
                      } else {
                        iconNotif = Icons.info_outline; 
                      }

                      bool isUnread = notif['status'] == 'unread';

                      return _buildNotificationCard(
                        icon: iconNotif,
                        title: notif['judul'] ?? 'Pemberitahuan',
                        description: notif['pesan'] ?? 'Tidak ada pesan.',
                        time: notif['createdAt'] ?? notif['cretedAt'] ?? 'Baru saja',
                        isNew: isUnread, 
                        // --- PARAMETER BARU: Aksi saat kartu diklik ---
                        onTap: () {
                          if (isUnread) {
                            _tandaiSudahDibaca(notif['id']);
                          }
                        },
                      );
                    },
                  );
                },
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
          child: const Icon(Icons.search, color: Colors.white, size: 18),
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

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required bool isNew,
    required VoidCallback onTap, // Menerima fungsi dari luar
  }) {
    // --- BUNGKUS DENGAN INKWELL AGAR BISA DIKLIK DAN ADA EFEK RIPPLE ---
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNew ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Menggunakan transparent agar background Container tetap terlihat
        child: InkWell(
          onTap: onTap, // Menjalankan fungsi saat diklik
          borderRadius: BorderRadius.circular(18), // Menyesuaikan lengkungan efek klik
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isNew ? Colors.blue.shade50 : Colors.grey.shade100,
                  child: Icon(
                    icon,
                    color: isNew ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isNew)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}