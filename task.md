# Task List — Lapak Tani Development

---

## Sprint 1: Foundation & Authentication

### Config & Dependencies
- [ ] Tambah dependencies `provider` dan `intl` di `pubspec.yaml`
- [ ] Buat `lib/config/app_theme.dart` — Material 3 theme hijau (pertanian)

### Models (semua dengan `fromMap`, `toMap`, `fromFirestore`)
- [ ] Buat `lib/models/user_model.dart`
- [ ] Buat `lib/models/category_model.dart`
- [ ] Buat `lib/models/product_model.dart`
- [ ] Buat `lib/models/cart_item_model.dart`
- [ ] Buat `lib/models/order_model.dart`
- [ ] Buat `lib/models/order_item_model.dart`
- [ ] Buat `lib/models/review_model.dart`

### Services
- [ ] Buat `lib/services/auth_service.dart` — register, login, logout, resetPassword
- [ ] Buat `lib/services/user_service.dart` — CRUD user Firestore

### Providers
- [ ] Buat `lib/providers/auth_provider.dart` — state auth, currentUser, role-based

### Widgets (reusable)
- [ ] Buat `lib/widgets/custom_text_field.dart`
- [ ] Buat `lib/widgets/loading_widget.dart`

### Screens — Auth
- [ ] Buat `lib/screens/splash_screen.dart` — logo, cek auth → navigate
- [ ] Buat `lib/screens/auth/login_screen.dart` — form email+password, link register & lupa pw
- [ ] Buat `lib/screens/auth/register_screen.dart` — form lengkap + pilih role
- [ ] Buat `lib/screens/auth/forgot_password_screen.dart` — form email reset

### Main Entry Point
- [ ] Modifikasi `lib/main.dart` — Firebase init, MultiProvider, routing splash → auth/home

---

## Sprint 2: Home & Produk (Pembeli)

### Services
- [ ] Buat `lib/services/product_service.dart` — getAllProducts, getById, getByCategory, search
- [ ] Buat `lib/services/category_service.dart` — getAllCategories

### Providers
- [ ] Buat `lib/providers/product_provider.dart` — state produk, fetch, search, filter

### Widgets
- [ ] Buat `lib/widgets/product_card.dart` — card produk grid
- [ ] Buat `lib/widgets/category_chip.dart` — chip kategori horizontal

### Screens — Buyer
- [ ] Buat `lib/screens/buyer/home_screen.dart` — search bar, kategori scroll, produk grid, bottom nav
- [ ] Buat `lib/screens/buyer/search_screen.dart` — pencarian + filter kategori
- [ ] Buat `lib/screens/buyer/product_detail_screen.dart` — gambar, info, harga, stok, add cart, wishlist, reviews

---

## Sprint 3: Cart, Checkout & Wishlist

### Services
- [ ] Buat `lib/services/cart_service.dart` — getItems, add, updateQty, remove, clear

### Providers
- [ ] Buat `lib/providers/cart_provider.dart` — state keranjang
- [ ] Buat `lib/providers/wishlist_provider.dart` — state wishlist

### Screens — Buyer
- [ ] Buat `lib/screens/buyer/cart_screen.dart` — list item, ubah qty, hapus, total, tombol checkout
- [ ] Buat `lib/screens/buyer/checkout_screen.dart` — alamat, metode bayar, ringkasan, tombol pesan
- [ ] Buat `lib/screens/buyer/wishlist_screen.dart` — grid produk wishlist, toggle

---

## Sprint 4: Manajemen Produk (Petani)

### Services (extend product_service.dart)
- [ ] Tambah method: `addProduct`, `updateProduct`, `deleteProduct`, `getSellerProducts`, `updateStock`

### Screens — Seller
- [ ] Buat `lib/screens/seller/seller_dashboard_screen.dart` — ringkasan: produk, pesanan, pendapatan
- [ ] Buat `lib/screens/seller/my_products_screen.dart` — list produk sendiri, kelola stok, edit, hapus
- [ ] Buat `lib/screens/seller/add_product_screen.dart` — form tambah produk + URL gambar
- [ ] Buat `lib/screens/seller/edit_product_screen.dart` — form edit pre-filled

---

## Sprint 5: Pesanan, Review & Admin

### Services
- [ ] Buat `lib/services/order_service.dart` — createOrder, getByBuyer, getBySeller, updateStatus
- [ ] Buat `lib/services/review_service.dart` — addReview, getByProduct, updateProductRating

### Providers
- [ ] Buat `lib/providers/order_provider.dart` — state pesanan

### Widgets
- [ ] Buat `lib/widgets/order_status_badge.dart` — badge warna per status
- [ ] Buat `lib/widgets/review_card.dart` — card review + rating stars

### Screens — Buyer
- [ ] Buat `lib/screens/buyer/order_history_screen.dart` — list pesanan + status, tombol review
- [ ] Buat `lib/screens/buyer/profile_screen.dart` — info profil, edit, logout

### Screens — Seller
- [ ] Buat `lib/screens/seller/seller_orders_screen.dart` — pesanan masuk, update status

### Screens — Admin
- [ ] Buat `lib/screens/admin/admin_dashboard_screen.dart` — total user, produk, order + tombol seeder
- [ ] Buat `lib/screens/admin/manage_users_screen.dart` — list user, detail
- [ ] Buat `lib/screens/admin/manage_products_screen.dart` — list produk, hapus

---

## Sprint 6: Seeder & Final

### Seeder
- [ ] Buat `lib/seeder/firestore_seeder.dart` — seedAll, seedUsers, seedCategories, seedProducts, seedOrders, seedReviews

### Verification
- [ ] Jalankan `flutter analyze` — pastikan 0 error
- [ ] Jalankan `flutter build apk --debug` — pastikan build sukses
- [ ] Test manual semua flow: register → login → browse → cart → checkout → review
- [ ] Test role-based: pembeli, petani, admin masing-masing masuk dashboard benar
