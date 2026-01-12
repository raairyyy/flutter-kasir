import 'dart:io';
import 'package:flutter/foundation.dart'; // Penting untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductCreate extends StatefulWidget {
  const ProductCreate({super.key});

  @override
  State<ProductCreate> createState() => _ProductCreateState();
}

class _ProductCreateState extends State<ProductCreate> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Controller input
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  int? _selectedKategoriId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  // Variabel Gambar (Support Web & Mobile)
  XFile? _pickedXFile;      // Menyimpan data file dari picker
  Uint8List? _webImage;     // Untuk menampilkan gambar di Web
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  // Fungsi Pilih Gambar
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        // Jika di Web, baca sebagai Bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedXFile = pickedFile;
        });
      } else {
        // Jika di Mobile/Desktop
        setState(() {
          _pickedXFile = pickedFile;
        });
      }
    }
  }

  Future<void> _fetchKategori() async {
    try {
      final data = await _supabase.from('kategori').select();
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Error fetching kategori: $e");
    }
  }

Future<void> _saveProduct() async {
  if (!_formKey.currentState!.validate() || _selectedKategoriId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lengkapi data dan pilih kategori!")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    String? imageUrl;

// --- PROSES UPLOAD YANG BENAR ---
if (_pickedXFile != null) {
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final path = 'product_photos/$fileName';

  final imageBytes = await _pickedXFile!.readAsBytes();

  await _supabase.storage.from('product_images').uploadBinary(
    path,
    imageBytes, // ✅ Uint8List langsung
    fileOptions: const FileOptions(
      contentType: 'image/jpeg',
      upsert: false,
    ),
  );

  imageUrl =
      _supabase.storage.from('produk_images').getPublicUrl(path);
}


    // Simpan ke tabel 'produk'
    await _supabase.from('produk').insert({
      'namaproduk': _namaController.text,
      'harga': double.tryParse(_hargaController.text) ?? 0,
      'stok': int.tryParse(_stokController.text) ?? 0,
      'kategoriid': _selectedKategoriId,
      'stok_minimum': 1,
      'gambar': imageUrl,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil ditambahkan!")),
      );
      Navigator.pop(context, true);
    }
  } catch (e) {
    debugPrint("Gagal menyimpan: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhotoPicker(),
                const SizedBox(height: 25),
                _buildLabel("Nama Produk"),
                _buildTextField(_namaController, "Masukkan nama produk"),
                _buildLabel("Kategori"),
                _buildDropdownKategori(),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Harga Produk"),
                          _buildTextField(_hargaController, "Rp", isNumber: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Stok"),
                          _buildTextField(_stokController, "0", isNumber: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFF5F5F5),
          ),
          child: _pickedXFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: kIsWeb
                      ? Image.memory(_webImage!, fit: BoxFit.cover)
                      : Image.file(File(_pickedXFile!.path), fit: BoxFit.cover),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Tambah Foto", style: TextStyle(color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 140,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tambah Produk", 
            style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 15),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B36),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 15),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      );

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value == null || value.isEmpty ? "Wajib diisi" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFD6E4E2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFD6E4E2), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedKategoriId,
          hint: const Text("Pilih kategori"),
          isExpanded: true,
          items: _categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat['kategoriid'],
              child: Text(cat['namakategori']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedKategoriId = val),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D3B36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
            : const Text("Tambahkan", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}