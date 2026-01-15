import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latihan_ukk/screens/auth/login_screen.dart'; // Sesuaikan dengan lokasi file login Anda

class PetugasPage extends StatelessWidget {
  const PetugasPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // 1. Proses Sign Out dari Supabase
      await Supabase.instance.client.auth.signOut();

      if (context.mounted) {
        // 2. Arahkan kembali ke halaman login dan hapus semua history halaman sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Logout: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Petugas"),
        backgroundColor: const Color(0xFF0B4A46),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context), // Panggil fungsi logout
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Halo, Petugas!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Anda masuk sebagai role Petugas"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // 1. Proses Sign Out dari Supabase
                await Supabase.instance.client.auth.signOut();

                // 2. Cek apakah context masih aktif
                if (context.mounted) {
                  // 3. Pindah halaman secara manual tanpa rute
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false, // Menghapus semua tumpukan halaman (history)
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}