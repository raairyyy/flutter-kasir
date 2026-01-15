import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../product/product_create.dart';
import '../product/product_edit.dart';
import '../screens/profile/profile_page.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  // Inisialisasi client Supabase
  final supabase = Supabase.instance.client;

  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Fungsi untuk mengambil data dari tabel 'products'
Future<List<Map<String, dynamic>>> fetchProducts() async {
  try {
    // Mulai dengan query dasar
    var query = supabase.from('produk').select();

    // Jika user mengetik sesuatu, tambahkan filter 'ilike' (tidak peka huruf besar/kecil)
    if (_searchQuery.isNotEmpty) {
      query = query.ilike('namaproduk', '%$_searchQuery%');
    }

    final response = await query.order('namaproduk', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw Exception('Gagal mengambil data: $e');
  }
}

  // Fungsi untuk menghapus produk
  Future<void> deleteProduct(int productId) async {
    try {
      await supabase.from('produk').delete().eq('produkid', productId);
      setState(() {}); // Refresh list after delete
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // Dialog konfirmasi hapus
// Dialog konfirmasi hapus sesuai desain
  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Peringatan (Lingkaran merah muda dengan ikon !)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE), // Merah sangat muda
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Judul
                const Text(
                  'Hapus Produk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Konten Teks dengan RichText untuk mewarnai Nama Produk
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    children: [
                      const TextSpan(text: 'Apakah anda yakin ingin\nmenghapus produk '),
                      TextSpan(
                        text: '${product['namaproduk']}?',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Tombol Aksi (Batal & Hapus)
                Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black54,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Tombol Hapus
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await deleteProduct(product['produkid']);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Produk berhasil dihapus!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 120,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Produk",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
              Text(
                "Tambah produk dan sesuaikan",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: IconButton(
              icon: const Icon(Icons.person_outline,
                  color: Color(0xFF0B4A46), size: 35),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },

            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController, // Hubungkan controller
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value; // Update state dan trigger build ulang
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari Produk",
                      prefixIcon: const Icon(Icons.search),
                      // Tombol hapus pencarian (opsional tapi disarankan)
                      suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() { _searchQuery = ""; });
                              },
                            ) 
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFEEEEEE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Icon(Icons.tune, color: Colors.grey),
                )
              ],
            ),
          ),

          // GRID PRODUK DENGAN FUTUREBUILDER
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada produk."));
                }

                final products = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}), // Tarik kebawah untuk refresh
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductEdit(product: product),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        onDelete: () => _showDeleteConfirmation(context, product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductCreate()),
          ).then((_) => setState(() {})); // Refresh data setelah kembali dari form tambah
        },
        backgroundColor: const Color(0xFF8BAEAA),
        child: const Icon(Icons.add, size: 35, color: Colors.white),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: product['gambar'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              product['gambar'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product['namaproduk'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Rp ${product['harga']}",
                  style: const TextStyle(
                      color: Color(0xFF3FB185), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Badge stok
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (product['stok'] ?? 0) <= 1
                    ? const Color(0xFFE58B8B)
                    : const Color(0xFF8BAEAA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${product['stok'] ?? 0}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Popup Menu untuk Edit/Delete
          Positioned(
            bottom: 5,
            right: 0,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              // Menghilangkan padding default menu agar Container berwarna bisa tampil penuh
              padding: EdgeInsets.zero, 
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit!();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                // ITEM EDIT
                PopupMenuItem(
                  value: 'edit',
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8E6C9), // Hijau muda (Green 100)
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // ITEM HAPUS
                PopupMenuItem(
                  value: 'delete',
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2), // Merah muda (Red 100)
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}