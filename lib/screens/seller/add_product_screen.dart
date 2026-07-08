import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/models/product_model.dart';
import 'package:lapak_tani/widgets/custom_text_field.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageController = TextEditingController();

  String _selectedUnit = 'kg';
  String? _selectedCategoryId;
  bool _isProcessing = false;

  final List<String> _units = ['kg', 'ikat', 'buah', 'sisir', '5kg'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        _showSnackBar(
          'Pilih kategori produk terlebih dahulu',
          Colors.red.shade600,
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    final provider = context.read<ProductProvider>();
    final user = context.read<AuthProvider>().user!;

    final category = provider.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    final product = ProductModel(
      id: '',
      sellerId: user.uid,
      sellerName: user.name,
      categoryId: category.id,
      categoryName: category.name,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      unit: _selectedUnit,
      stock: int.parse(_stockController.text.trim()),
      imageUrl: _imageController.text.trim(),
      rating: 0.0,
      reviewCount: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await provider.addProduct(product);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        _showSnackBar('Produk berhasil ditambahkan', const Color(0xFF1B8040));
        Navigator.pop(context);
      } else {
        _showSnackBar('Gagal menambahkan produk', Colors.red.shade600);
      }
    }
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<ProductProvider>().categories;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Tambah Produk',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Informasi Dasar ──────────────────────────────────────────
              _buildFormSection(
                title: 'Informasi Dasar',
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Produk',
                    validator: (v) =>
                        v!.isEmpty ? 'Nama produk wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descController,
                    label: 'Deskripsi Produk',
                    maxLines: 4,
                    validator: (v) =>
                        v!.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),
                ],
              ),

              // ── Harga & Stok ─────────────────────────────────────────────
              _buildFormSection(
                title: 'Harga & Inventaris',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _priceController,
                          label: 'Harga',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (v) {
                            if (v!.isEmpty) return 'Wajib diisi';
                            if (double.tryParse(v) == null || double.parse(v) <= 0) { return 'Harga tidak valid'; }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: InputDecoration(
                            labelText: 'Satuan',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey.shade600,
                          ),
                          items: _units
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _stockController,
                    label: 'Jumlah Stok',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (v) {
                      if (v!.isEmpty) return 'Wajib diisi';
                      if (int.tryParse(v) == null || int.parse(v) < 0) { return 'Stok tidak valid'; }
                      return null;
                    },
                  ),
                ],
              ),

              // ── Gambar Produk ────────────────────────────────────────────
              _buildFormSection(
                title: 'Media Produk',
                children: [
                  CustomTextField(
                    controller: _imageController,
                    label: 'URL Gambar',
                    prefixIcon: Icons.link_rounded,
                    validator: (v) =>
                        v!.isEmpty ? 'URL Gambar wajib diisi' : null,
                    onChanged: (v) => setState(() {}),
                  ),
                  if (_imageController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          _imageController.text,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'URL Gambar Tidak Valid',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              // ── Tombol Simpan ────────────────────────────────────────────
              if (_isProcessing)
                const LoadingWidget()
              else
                ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Simpan Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8040),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
