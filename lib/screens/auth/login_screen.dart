import 'package:latihan_ukk/screens/main_page.dart';
import 'package:latihan_ukk/screens/petugas_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Abu-abu sangat muda sesuai gambar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER & LOGO (Posisi Logo dinaikkan)
            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38, // Sedikit diperpendek
                width: double.infinity,
                color: const Color(0xFF0B4A46),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20), // Memberi ruang bawah agar logo naik
                    child: Image.asset(
                      'assets/images/logo3.png',
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // 2. JUDUL LOGIN (Dinaikkan jaraknya dan dibuat lebih Bold)
            const SizedBox(height: 20), // Jarak dikurangi agar lebih ke atas
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.w900, // Extra Bold sesuai permintaan
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            // INPUT EMAIL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // INPUT KATA SANDI
            // INPUT KATA SANDI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: passwordController,
                obscureText: _isObscured, // Gunakan variabel _isObscured di sini
                decoration: InputDecoration(
                  hintText: "Kata Sandi",
                  hintStyle: const TextStyle(color: Colors.grey),
                  // GANTI ICON MANUAL DENGAN IconButton
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured; // Membalikkan status saat diklik
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL LOGIN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _login();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4A46),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

Future<void> _login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  // Validasi awal jika input kosong
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email dan kata sandi tidak boleh kosong")),
    );
    return;
  }

  try {
    final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user != null) {
      final userData = await Supabase.instance.client
          .from('users') 
          .select('role')
          .eq('email', email)
          .maybeSingle();

      if (!mounted) return;

      if (userData != null) {
        String role = userData['role'].toString().toLowerCase();
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage(role: role)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PetugasPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data role tidak ditemukan.")),
        );
      }
    }
  } on AuthException catch (error) {
    if (!mounted) return;
    
    // --- LOGIKA PESAN ERROR CUSTOM ---
    String message = "Terjadi kesalahan";
    if (error.message.contains("Invalid login credentials")) {
      message = "Email atau kata sandi salah"; // Pesan custom kamu
    } else {
      message = error.message; // Pesan asli dari server (misal: network error)
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // Agar melayang lebih modern
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  }
}
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height); 
    
    // Lengkungan kiri bawah
    path.quadraticBezierTo(
      0, size.height - 80, 
      80, size.height - 80,
    );
    
    path.lineTo(size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}