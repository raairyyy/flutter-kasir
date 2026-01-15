import 'package:flutter/material.dart';
// Ganti path sesuai dengan folder project Anda
import 'package:latihan_ukk/product/product_list.dart'; 
import 'package:latihan_ukk/screens/report/report_page.dart';

class MainPage extends StatefulWidget {
  final String role;
  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Indeks halaman aktif
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const ProductList(), // Index 0
    const ReportPage(),  // Index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga 'state' halaman agar tidak reload dari awal
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D3B36), // Hijau tua seperti tema Anda
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}