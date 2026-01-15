import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// ignore: depend_on_referenced_packages

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  Future<void> _processPdf({required bool isDownload}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("LAPORAN PENJUALAN", 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text("Tanggal Cetak: ${DateTime.now()}"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['No', 'Nama Produk', 'Harga', 'Jumlah'],
                data: [
                  ['1', 'Produk A', 'Rp 10.000', '2'],
                  ['2', 'Produk B', 'Rp 15.000', '1'],
                ],
              ),
            ],
          );
        },
      ),
    );

    if (isDownload) {
      // Opsi 1: LANGSUNG DOWNLOAD (Sangat berguna untuk Web)
      await Printing.sharePdf(
        bytes: await pdf.save(), 
        filename: 'laporan_penjualan_${DateTime.now().millisecondsSinceEpoch}.pdf'
      );
    } else {
      // Opsi 2: PREVIEW DULU (Bisa cetak atau simpan manual)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _processPdf(isDownload: true),
            tooltip: "Download PDF",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _processPdf(isDownload: false),
              icon: const Icon(Icons.remove_red_eye),
              label: const Text("Preview & Cetak"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4A46), foregroundColor: Colors.white),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _processPdf(isDownload: true),
              icon: const Icon(Icons.download),
              label: const Text("Download Langsung"),
            ),
          ],
        ),
      ),
    );
  }
}