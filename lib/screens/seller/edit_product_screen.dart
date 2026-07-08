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
    _priceController = TextEditingController(text: widget.product.price.toInt().toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final provider = context.read<ProductProvider>();
    final category = provider.categories.firstWhere((c) => c.id == _selectedCategoryId);

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil diupdate'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengupdate produk'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<ProductProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nama Produk',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                label: 'Deskripsi',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Harga',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (v) {
                        if (v!.isEmpty) return 'Wajib diisi';
                        if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Harga tidak valid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Satuan', border: OutlineInputBorder()),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
                validator: (v) {
                  if (v!.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null || int.parse(v) < 0) return 'Stok tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageController,
                label: 'URL Gambar Produk',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              if (_imageController.text.isNotEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(
                    _imageController.text,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Text('URL Gambar Tidak Valid')),
                  ),
                ),
                
              const SizedBox(height: 32),
              
              if (_isProcessing)
                const LoadingWidget()
              else
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Update Produk'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
