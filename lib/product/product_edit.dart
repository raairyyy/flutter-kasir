import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductEdit extends StatefulWidget {
  final Map<String, dynamic> product;
  
  const ProductEdit({super.key, required this.product});

  @override
  State<ProductEdit> createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;

  int? _selectedKategoriId;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  XFile? _pickedXFile;
  Uint8List? _webImage;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.product['namaproduk'] ?? '');
    _hargaController = TextEditingController(text: widget.product['harga']?.toString() ?? '');
    _stokController = TextEditingController(text: widget.product['stok']?.toString() ?? '');
    _selectedKategoriId = widget.product['kategoriid'];
    _existingImageUrl = widget.product['gambar'];

    // Listener ini penting agar UI (PopScope & Button) 
    // langsung merespon saat user mengetik
    _namaController.addListener(() {
      setState(() {});
    });

    _fetchKategori();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _fetchKategori() async {
    try {
      final data = await _supabase.from('kategori').select();
      setState(() => _categories = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint("Error kategori: $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() { _webImage = bytes; _pickedXFile = pickedFile; });
      } else {
        setState(() => _pickedXFile = pickedFile);
      }
    }
  }

  Future<void> _updateProduct() async {
    // 1. CEK APAKAH NAMA ADA PERUBAHAN
    if (_namaController.text.trim() == widget.product['namaproduk']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silahkan buat perubahan pada nama produk!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. VALIDASI FORM LAINNYA
    if (!_formKey.currentState!.validate() || _selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data dan pilih kategori!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;
      if (_pickedXFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'product_photos/$fileName';
        final imageBytes = await _pickedXFile!.readAsBytes();
        await _supabase.storage.from('product_images').uploadBinary(path, imageBytes);
        imageUrl = _supabase.storage.from('product_images').getPublicUrl(path);
      }

      await _supabase.from('produk').update({
        'namaproduk': _namaController.text,
        'harga': double.tryParse(_hargaController.text) ?? 0,
        'stok': int.tryParse(_stokController.text) ?? 0,
        'kategoriid': _selectedKategoriId,
        'gambar': imageUrl,
      }).eq('produkid', widget.product['produkid']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil diperbarui!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek perubahan secara real-time
    bool isNameChanged = _namaController.text.trim() != widget.product['namaproduk'];

    return PopScope(
      canPop: isNameChanged, // Hanya bisa back jika nama sudah berubah
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ubah nama produk terlebih dahulu untuk keluar!"),
            backgroundColor: Colors.red,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoPicker(),
                  const SizedBox(height: 25),
                  _buildLabel("Nama Produk (Wajib Diubah)"),
                  _buildTextField(_namaController, "Masukkan nama produk baru"),
                  _buildLabel("Kategori"),
                  _buildDropdownKategori(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildNumberInput(_hargaController, "Harga")),
                      const SizedBox(width: 15),
                      Expanded(child: _buildNumberInput(_stokController, "Stok")),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildSubmitButton(isNameChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildNumberInput(TextEditingController ctrl, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        _buildTextField(ctrl, label == "Harga" ? "Rp" : "0", isNumber: true),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      validator: (value) {
        if (value == null || value.isEmpty) return "Wajib diisi";
        if (isNumber && num.tryParse(value) == null) return "Harus angka";
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFD1E3E0),
        errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton(bool active) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D3B36),
          // Jika belum ada perubahan, warna tombol jadi lebih pudar
          disabledBackgroundColor: Colors.grey.shade400, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ... Widget _buildAppBar, _buildPhotoPicker, _buildLabel, _buildDropdownKategori (sama seperti sebelumnya) ...
  // Sertakan kembali widget tersebut di sini agar kode tidak error.
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 120,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Edit Produk", style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF0D3B36), borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDropdownKategori() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFD1E3E0), borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedKategoriId,
          isExpanded: true,
          items: _categories.map((cat) => DropdownMenuItem<int>(
            value: cat['kategoriid'], child: Text(cat['namakategori']))
          ).toList(),
          onChanged: (val) => setState(() => _selectedKategoriId = val),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 150, width: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFF8F8F8),
          ),
          child: _pickedXFile != null
              ? ClipRRect(borderRadius: BorderRadius.circular(20), child: kIsWeb ? Image.memory(_webImage!) : Image.file(File(_pickedXFile!.path), fit: BoxFit.cover))
              : _existingImageUrl != null 
                  ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_existingImageUrl!, fit: BoxFit.cover))
                  : const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
        ),
      ),
    );
  }
}