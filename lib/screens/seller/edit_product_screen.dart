import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/models/product_model.dart';
import 'package:lapak_tani/widgets/custom_text_field.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;

  late String _selectedUnit;
  late String _selectedCategoryId;
  bool _isProcessing = false;

  final List<String> _units = ['kg', 'ikat', 'buah', 'sisir', '5kg'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(
      text: widget.product.price.toInt().toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _imageController = TextEditingController(text: widget.product.imageUrl);
    _selectedUnit = widget.product.unit;
    _selectedCategoryId = widget.product.categoryId;
  }

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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final provider = context.read<ProductProvider>();
    final category = provider.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    final updatedProduct = widget.product.copyWith(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      unit: _selectedUnit,
      stock: int.parse(_stockController.text.trim()),
      categoryId: category.id,
      categoryName: category.name,
      imageUrl: _imageController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await provider.updateProduct(updatedProduct);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        _showSnackBar('Produk berhasil diupdate', const Color(0xFF1B8040));
        Navigator.pop(context);
      } else {
        _showSnackBar('Gagal mengupdate produk', Colors.red.shade600);
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
          'Edit Produk',
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
                title: 'Informasi Produk',
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nama Produk',
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v!),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descController,
                    label: 'Deskripsi',
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),

              // ── Harga & Stok ─────────────────────────────────────────────
              _buildFormSection(
                title: 'Harga & Inventaris',
                children: [
                  Row(
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
                    label: 'Stok',
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

              // ── Gambar ───────────────────────────────────────────────────
              _buildFormSection(
                title: 'Media Produk',
                children: [
                  CustomTextField(
                    controller: _imageController,
                    label: 'URL Gambar Produk',
                    prefixIcon: Icons.link_rounded,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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

              if (_isProcessing)
                const LoadingWidget()
              else
                ElevatedButton.icon(
                  onPressed: _updateProduct,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Update Produk',
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
