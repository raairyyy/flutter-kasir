import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan", 
          style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text("Halaman Laporan Akan Muncul di Sini"),
      ),
    );
  }
}