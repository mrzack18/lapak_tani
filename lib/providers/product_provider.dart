import 'package:flutter/material.dart';
import 'package:lapak_tani/models/product_model.dart';
import 'package:lapak_tani/models/category_model.dart';
import 'package:lapak_tani/services/product_service.dart';
import 'package:lapak_tani/services/category_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  List<ProductModel> _products = [];
  List<ProductModel> _searchResults = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;
  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get searchResults => _searchResults;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all active products from Firestore
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _products = await _productService.getAllProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat produk: $e';
      notifyListeners();
    }
  }

  /// Fetch all categories from Firestore
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _categoryService.getAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  /// Search products by name query
  Future<void> searchProducts(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (query.trim().isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = await _productService.searchProducts(query);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mencari produk: $e';
      notifyListeners();
    }
  }

  /// Filter products by category ID (null = show all)
  Future<void> filterByCategory(String? categoryId) async {
    try {
      _isLoading = true;
      _selectedCategoryId = categoryId;
      _error = null;
      notifyListeners();

      if (categoryId == null || categoryId.isEmpty) {
        _products = await _productService.getAllProducts();
      } else {
        _products = await _productService.getProductsByCategory(categoryId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memfilter produk: $e';
      notifyListeners();
    }
  }

  /// Fetch a single product by ID and set as selectedProduct
  Future<void> fetchProductById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedProduct = await _productService.getProductById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat detail produk: $e';
      notifyListeners();
    }
  }

  /// Fetch products belonging to a specific seller
  Future<List<ProductModel>> fetchSellerProducts(String sellerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final sellerProducts =
          await _productService.getSellerProducts(sellerId);
      _isLoading = false;
      notifyListeners();
      return sellerProducts;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat produk penjual: $e';
      notifyListeners();
      return [];
    }
  }

  /// Add a new product (seller)
  Future<bool> addProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.addProduct(product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal menambah produk: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing product (seller)
  Future<bool> updateProduct(ProductModel product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.updateProduct(product);

      // Update local list if product exists
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }

      // Update selected product if it's the same
      if (_selectedProduct?.id == product.id) {
        _selectedProduct = product;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mengupdate produk: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a product by ID (seller)
  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);

      if (_selectedProduct?.id == productId) {
        _selectedProduct = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal menghapus produk: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update product stock (seller)
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.updateStock(productId, newStock);

      // Update local state
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stock: newStock);
      }

      if (_selectedProduct?.id == productId) {
        _selectedProduct = _selectedProduct!.copyWith(stock: newStock);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal mengupdate stok: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
