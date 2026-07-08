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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kategori produk'), backgroundColor: Colors.red));
      }
      return;
    }

    setState(() => _isProcessing = true);

    final provider = context.read<ProductProvider>();
    final user = context.read<AuthProvider>().user!;
    
    final category = provider.categories.firstWhere((c) => c.id == _selectedCategoryId);

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil ditambahkan'), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambahkan produk'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.read<ProductProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
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
                onChanged: (v) => setState(() => _selectedCategoryId = v),
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
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Simpan Produk'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
