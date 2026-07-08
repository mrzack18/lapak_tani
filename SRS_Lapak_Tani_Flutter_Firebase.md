# Software Requirements Specification (SRS)

# Aplikasi Mobile **Lapak Tani**

**Tema:** Lumbung Panen\
**Platform:** Flutter (Android & iOS)\
**Backend:** Firebase

------------------------------------------------------------------------

# 1. Pendahuluan

## 1.1 Tujuan

Dokumen Software Requirements Specification (SRS) ini bertujuan sebagai
acuan dalam pengembangan aplikasi **Lapak Tani**, yaitu aplikasi
marketplace hasil pertanian yang mempertemukan petani dengan pembeli
secara langsung. Aplikasi ini dibangun menggunakan **Flutter** sebagai
framework mobile dan **Firebase** sebagai layanan backend.

Dokumen ini mendefinisikan kebutuhan fungsional, non-fungsional, batasan
sistem, serta rancangan fitur yang akan dikembangkan.

## 1.2 Lingkup Sistem

Lapak Tani merupakan aplikasi mobile yang memiliki fungsi utama:

-   Media jual beli hasil panen.
-   Membantu petani memasarkan hasil panennya.
-   Memudahkan masyarakat memperoleh hasil pertanian segar.
-   Menyediakan informasi produk pertanian.
-   Menyediakan sistem transaksi sederhana.
-   Menampilkan lokasi penjual menggunakan Google Maps.
-   Menyediakan sistem ulasan dan penilaian.

## 1.3 Definisi

  Istilah                   Keterangan
  ------------------------- -----------------------------------
  Petani                    Pengguna yang menjual hasil panen
  Pembeli                   Pengguna yang membeli hasil panen
  Admin                     Pengelola aplikasi
  Produk                    Hasil pertanian yang dijual
  Order                     Pesanan pembelian
  Firebase                  Backend Cloud
  Firestore                 Database NoSQL
  Firebase Storage          Penyimpanan gambar
  Firebase Authentication   Login pengguna

------------------------------------------------------------------------

# 2. Deskripsi Umum

## 2.1 Perspektif Produk

Arsitektur sistem:

``` text
Flutter Mobile Apps
        │
        ▼
Firebase Authentication
        │
        ▼
Cloud Firestore
        │
        ▼
Firebase Storage
        │
        ▼
Firebase Cloud Messaging
        │
        ▼
Google Maps API
```

## 2.2 Fungsi Produk

-   Registrasi akun
-   Login
-   Manajemen profil
-   Menampilkan produk
-   Pencarian dan filter
-   Wishlist
-   Keranjang
-   Checkout
-   Riwayat pesanan
-   Upload/Edit/Hapus produk
-   Rating & Review
-   Maps lokasi petani
-   Notifikasi

## 2.3 Karakteristik Pengguna

### Petani

-   Mengelola produk
-   Mengelola stok
-   Mengelola pesanan

### Pembeli

-   Mencari produk
-   Membeli produk
-   Memberikan ulasan

### Admin

-   Mengelola pengguna
-   Monitoring produk
-   Menghapus produk bermasalah

## 2.4 Batasan

-   Android minimal 8.0
-   Internet wajib aktif
-   Firebase sebagai backend
-   Maksimal gambar 5 MB
-   Login Email & Google

------------------------------------------------------------------------

# 3. Kebutuhan Fungsional

  Kode    Fitur
  ------- ------------------
  FR-01   Registrasi
  FR-02   Login
  FR-03   Lupa Password
  FR-04   Dashboard
  FR-05   Pencarian Produk
  FR-06   Detail Produk
  FR-07   Wishlist
  FR-08   Keranjang
  FR-09   Checkout
  FR-10   Riwayat Pesanan
  FR-11   Upload Produk
  FR-12   Edit Produk
  FR-13   Hapus Produk
  FR-14   Kelola Stok
  FR-15   Rating
  FR-16   Review
  FR-17   Maps Lokasi
  FR-18   Profil
  FR-19   Notifikasi
  FR-20   Logout

------------------------------------------------------------------------

# 4. Kebutuhan Non-Fungsional

-   Loading \< 3 detik
-   Firebase Authentication
-   Firestore Security Rules
-   HTTPS
-   Material Design 3
-   Responsive
-   Android & iOS

------------------------------------------------------------------------

# 5. Aktor

## Pembeli

-   Registrasi/Login
-   Cari produk
-   Wishlist
-   Keranjang
-   Checkout
-   Riwayat
-   Review

## Petani

-   Upload produk
-   Edit produk
-   Kelola stok
-   Kelola pesanan

## Admin

-   Kelola pengguna
-   Kelola produk
-   Monitoring aplikasi

------------------------------------------------------------------------

# 6. Struktur Database Firestore

## users

``` text
users/
 └── uid
      ├── name
      ├── email
      ├── phone
      ├── role
      ├── photo
      ├── address
      └── createdAt
```

## products

``` text
products/
 └── productId
      ├── sellerId
      ├── categoryId
      ├── name
      ├── description
      ├── price
      ├── stock
      ├── weight
      ├── image
      ├── latitude
      ├── longitude
      └── createdAt
```

## orders

``` text
orders/
 └── orderId
      ├── buyerId
      ├── sellerId
      ├── total
      ├── status
      ├── paymentMethod
      ├── address
      └── createdAt
```

## reviews

``` text
reviews/
 └── reviewId
      ├── productId
      ├── userId
      ├── rating
      ├── comment
      └── createdAt
```

------------------------------------------------------------------------

# 7. Firebase Storage

``` text
/users/{uid}
/products/{productId}
/reviews/{reviewId}
```

------------------------------------------------------------------------

# 8. Screen Aplikasi

## Authentication

-   Splash
-   Onboarding
-   Login
-   Register
-   Forgot Password

## Pembeli

-   Home
-   Search
-   Category
-   Detail Produk
-   Wishlist
-   Cart
-   Checkout
-   Order History
-   Notification
-   Profile

## Petani

-   Dashboard
-   Produk Saya
-   Tambah Produk
-   Edit Produk
-   Kelola Stok
-   Pesanan
-   Statistik

## Admin

-   Dashboard
-   Kelola Pengguna
-   Kelola Produk
-   Laporan

------------------------------------------------------------------------

# 9. Teknologi

## Frontend

-   Flutter
-   Dart
-   Provider
-   Go Router
-   Google Maps Flutter
-   Image Picker

## Backend

-   Firebase Authentication
-   Cloud Firestore
-   Firebase Storage
-   Firebase Cloud Messaging
-   Firebase Analytics
-   Firebase Crashlytics

------------------------------------------------------------------------

# 10. Sprint

  Sprint   Modul
  -------- ----------------------
  1        Authentication
  2        Home & Produk
  3        Cart & Checkout
  4        Manajemen Produk
  5        Pesanan & Review
  6        Testing & Deployment

------------------------------------------------------------------------

# 11. Kesimpulan

Lapak Tani adalah aplikasi marketplace hasil pertanian berbasis Flutter
dan Firebase yang menghubungkan petani dengan pembeli secara langsung
melalui platform mobile yang modern, aman, dan mudah digunakan.
