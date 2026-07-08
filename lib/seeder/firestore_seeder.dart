// lib\seeder\firestore_seeder.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed all data in order: categories → users → products → orders → reviews
  Future<String> seedAll() async {
    String log = '';
    try {
      log += await seedCategories();
      log += await seedUsers();
      log += await seedProducts();
      log += await seedOrders();
      log += await seedReviews();
      return log;
    } catch (e) {
      return log + '\nError: $e';
    }
  }

  /// Seed 3 users via Firebase Auth, then add profiles to Firestore
  Future<String> seedUsers() async {
    String log = '\n--- Seeding Users ---\n';

    final users = [
      {
        'email': 'admin@lapaktani.com',
        'password': 'admin123',
        'name': 'Admin Lapak Tani',
        'role': 'admin',
        'phone': '',
        'address': '',
      },
      {
        'email': 'petani@lapaktani.com',
        'password': 'petani123',
        'name': 'Pak Tono',
        'role': 'petani',
        'phone': '081234567890',
        'address': 'Desa Sukamaju, Kec. Cianjur, Jawa Barat',
      },
      {
        'email': 'pembeli@lapaktani.com',
        'password': 'pembeli123',
        'name': 'Budi Santoso',
        'role': 'pembeli',
        'phone': '089876543210',
        'address': 'Jl. Merdeka No. 45, Bandung, Jawa Barat',
      },
    ];

    for (final userData in users) {
      try {
        // Create user in Firebase Auth
        final credential = await _auth.createUserWithEmailAndPassword(
          email: userData['email']!,
          password: userData['password']!,
        );

        final uid = credential.user!.uid;

        // Save user profile to Firestore
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': userData['name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'role': userData['role'],
          'photoUrl': '',
          'address': userData['address'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        log += '✅ User created: ${userData['name']} (${userData['role']})\n';
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          log += '⚠️ User already exists: ${userData['email']} - skipping\n';
        } else {
          log += '❌ Error creating user ${userData['email']}: $e\n';
        }
      }
    }

    // Sign out after seeding so app doesn't auto-login as last seeded user
    await _auth.signOut();
    return log;
  }

  /// Seed 6 categories with predictable IDs
  Future<String> seedCategories() async {
    String log = '\n--- Seeding Categories ---\n';

    final categories = [
      {'id': 'cat_sayuran', 'name': 'Sayuran', 'icon': 'eco'},
      {'id': 'cat_buah', 'name': 'Buah-buahan', 'icon': 'nutrition'},
      {'id': 'cat_beras', 'name': 'Beras & Padi', 'icon': 'grain'},
      {'id': 'cat_rempah', 'name': 'Rempah-rempah', 'icon': 'spa'},
      {'id': 'cat_umbi', 'name': 'Umbi-umbian', 'icon': 'grass'},
      {'id': 'cat_kacang', 'name': 'Kacang-kacangan', 'icon': 'scatter_plot'},
    ];

    for (final cat in categories) {
      try {
        await _firestore.collection('categories').doc(cat['id']).set({
          'name': cat['name'],
          'icon': cat['icon'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        log += '✅ Category created: ${cat['name']}\n';
      } catch (e) {
        log += '❌ Error creating category ${cat['name']}: $e\n';
      }
    }

    return log;
  }

  /// Seed 12 products linked to the petani user
  Future<String> seedProducts() async {
    String log = '\n--- Seeding Products ---\n';

    try {
      // Find petani user by querying users where role == 'petani'
      final petaniQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'petani')
          .limit(1)
          .get();

      if (petaniQuery.docs.isEmpty) {
        return log + '❌ No petani user found. Seed users first.\n';
      }

      final petaniDoc = petaniQuery.docs.first;
      final petaniUid = petaniDoc.id;
      final petaniName = petaniDoc.data()['name'] as String? ?? 'Pak Tono';

      final products = [
        {
          'id': 'prod_bayam',
          'name': 'Bayam Segar',
          'description':
              'Bayam segar organik langsung dari kebun. Daun hijau tebal dan lebar, cocok untuk tumis, sayur bening, atau gado-gado.',
          'categoryId': 'cat_sayuran',
          'categoryName': 'Sayuran',
          'price': 5000.0,
          'stock': 50,
          'unit': 'ikat',
          'imageUrl':
              'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
        },
        {
          'id': 'prod_kangkung',
          'name': 'Kangkung Organik',
          'description':
              'Kangkung organik segar tanpa pestisida. Batang renyah dan daun hijau cerah, ideal untuk cah kangkung atau pecel.',
          'categoryId': 'cat_sayuran',
          'categoryName': 'Sayuran',
          'price': 4000.0,
          'stock': 80,
          'unit': 'ikat',
          'imageUrl':
              'https://images.unsplash.com/photo-1574316071802-0d684efa7bf5?w=400',
        },
        {
          'id': 'prod_tomat',
          'name': 'Tomat Merah',
          'description':
              'Tomat merah matang sempurna, manis dan segar. Cocok untuk sambal, sup, atau salad segar.',
          'categoryId': 'cat_sayuran',
          'categoryName': 'Sayuran',
          'price': 12000.0,
          'stock': 30,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1546470427-0d4db154ceb8?w=400',
        },
        {
          'id': 'prod_mangga',
          'name': 'Mangga Harumanis',
          'description':
              'Mangga Harumanis pilihan, daging buah tebal berwarna kuning oranye, rasa manis legit dan harum khas.',
          'categoryId': 'cat_buah',
          'categoryName': 'Buah-buahan',
          'price': 25000.0,
          'stock': 20,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
        },
        {
          'id': 'prod_pisang',
          'name': 'Pisang Cavendish',
          'description':
              'Pisang Cavendish premium, kulit kuning mulus dan daging buah lembut. Kaya potasium dan serat.',
          'categoryId': 'cat_buah',
          'categoryName': 'Buah-buahan',
          'price': 18000.0,
          'stock': 40,
          'unit': 'sisir',
          'imageUrl':
              'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
        },
        {
          'id': 'prod_jeruk',
          'name': 'Jeruk Manis',
          'description':
              'Jeruk manis segar dari perkebunan lokal. Rasa manis menyegarkan, kaya vitamin C.',
          'categoryId': 'cat_buah',
          'categoryName': 'Buah-buahan',
          'price': 20000.0,
          'stock': 25,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1582979512210-99b6a53386f9?w=400',
        },
        {
          'id': 'prod_beras_pandan',
          'name': 'Beras Pandan Wangi',
          'description':
              'Beras Pandan Wangi premium, pulen dan beraroma harum alami. Nasi yang dimasak mengembang sempurna.',
          'categoryId': 'cat_beras',
          'categoryName': 'Beras & Padi',
          'price': 65000.0,
          'stock': 100,
          'unit': '5kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400',
        },
        {
          'id': 'prod_beras_merah',
          'name': 'Beras Merah',
          'description':
              'Beras merah organik kaya serat dan nutrisi. Cocok untuk diet sehat dan program penurunan berat badan.',
          'categoryId': 'cat_beras',
          'categoryName': 'Beras & Padi',
          'price': 28000.0,
          'stock': 60,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1536304993881-460e32f50647?w=400',
        },
        {
          'id': 'prod_jahe',
          'name': 'Jahe Merah',
          'description':
              'Jahe merah segar berkualitas tinggi. Rasa pedas khas yang lebih kuat, cocok untuk wedang jahe dan jamu.',
          'categoryId': 'cat_rempah',
          'categoryName': 'Rempah-rempah',
          'price': 35000.0,
          'stock': 15,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400',
        },
        {
          'id': 'prod_kunyit',
          'name': 'Kunyit Segar',
          'description':
              'Kunyit segar alami langsung dari kebun. Warna kuning cerah, ideal untuk bumbu masakan dan jamu tradisional.',
          'categoryId': 'cat_rempah',
          'categoryName': 'Rempah-rempah',
          'price': 15000.0,
          'stock': 40,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400',
        },
        {
          'id': 'prod_singkong',
          'name': 'Singkong',
          'description':
              'Singkong segar pilihan, daging putih bersih dan empuk saat dimasak. Cocok untuk keripik, gorengan, atau tape.',
          'categoryId': 'cat_umbi',
          'categoryName': 'Umbi-umbian',
          'price': 8000.0,
          'stock': 50,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
        },
        {
          'id': 'prod_kacang_tanah',
          'name': 'Kacang Tanah',
          'description':
              'Kacang tanah pilihan, biji besar dan utuh. Sempurna untuk bumbu pecel, gado-gado, atau camilan goreng.',
          'categoryId': 'cat_kacang',
          'categoryName': 'Kacang-kacangan',
          'price': 30000.0,
          'stock': 35,
          'unit': 'kg',
          'imageUrl':
              'https://images.unsplash.com/photo-1567892320421-1c657571ea4a?w=400',
        },
      ];

      for (final product in products) {
        try {
          await _firestore
              .collection('products')
              .doc(product['id'] as String)
              .set({
                'sellerId': petaniUid,
                'sellerName': petaniName,
                'categoryId': product['categoryId'],
                'categoryName': product['categoryName'],
                'name': product['name'],
                'description': product['description'],
                'price': product['price'],
                'unit': product['unit'],
                'stock': product['stock'],
                'imageUrl': product['imageUrl'],
                'rating': 0.0,
                'reviewCount': 0,
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
          log += '✅ Product created: ${product['name']}\n';
        } catch (e) {
          log += '❌ Error creating product ${product['name']}: $e\n';
        }
      }
    } catch (e) {
      log += '❌ Error seeding products: $e\n';
    }

    return log;
  }

  /// Seed 2 sample orders
  Future<String> seedOrders() async {
    String log = '\n--- Seeding Orders ---\n';

    try {
      // Query pembeli and petani UIDs
      final pembeliQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pembeli')
          .limit(1)
          .get();

      final petaniQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'petani')
          .limit(1)
          .get();

      if (pembeliQuery.docs.isEmpty || petaniQuery.docs.isEmpty) {
        return log + '❌ Pembeli or petani user not found. Seed users first.\n';
      }

      final pembeliUid = pembeliQuery.docs.first.id;
      final pembeliName =
          pembeliQuery.docs.first.data()['name'] as String? ?? 'Budi Santoso';
      final petaniUid = petaniQuery.docs.first.id;
      final petaniName =
          petaniQuery.docs.first.data()['name'] as String? ?? 'Pak Tono';

      // Order 1: Budi buys Bayam 2 ikat + Tomat 1kg, status: 'selesai', COD
      final order1Id = 'order_seed_001';
      await _firestore.collection('orders').doc(order1Id).set({
        'buyerId': pembeliUid,
        'buyerName': pembeliName,
        'sellerId': petaniUid,
        'sellerName': petaniName,
        'items': [
          {
            'productId': 'prod_bayam',
            'productName': 'Bayam Segar',
            'price': 5000.0,
            'quantity': 2,
            'unit': 'ikat',
            'subtotal': 10000.0,
            'imageUrl':
                'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
          },
          {
            'productId': 'prod_tomat',
            'productName': 'Tomat Merah',
            'price': 12000.0,
            'quantity': 1,
            'unit': 'kg',
            'subtotal': 12000.0,
            'imageUrl':
                'https://images.unsplash.com/photo-1546470427-0d4db154ceb8?w=400',
          },
        ],
        'totalAmount': 22000.0,
        'status': 'selesai',
        'paymentMethod': 'COD',
        'shippingAddress': 'Jl. Merdeka No. 45, Bandung, Jawa Barat',
        'note': 'Tolong pilihkan yang segar ya pak',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log += '✅ Order 1 created: Bayam + Tomat (selesai, COD)\n';

      // Order 2: Budi buys Mangga 2kg, status: 'pending', Transfer Bank
      final order2Id = 'order_seed_002';
      await _firestore.collection('orders').doc(order2Id).set({
        'buyerId': pembeliUid,
        'buyerName': pembeliName,
        'sellerId': petaniUid,
        'sellerName': petaniName,
        'items': [
          {
            'productId': 'prod_mangga',
            'productName': 'Mangga Harumanis',
            'price': 25000.0,
            'quantity': 2,
            'unit': 'kg',
            'subtotal': 50000.0,
            'imageUrl':
                'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400',
          },
        ],
        'totalAmount': 50000.0,
        'status': 'pending',
        'paymentMethod': 'Transfer Bank',
        'shippingAddress': 'Jl. Merdeka No. 45, Bandung, Jawa Barat',
        'note': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log += '✅ Order 2 created: Mangga 2kg (pending, Transfer Bank)\n';
    } catch (e) {
      log += '❌ Error seeding orders: $e\n';
    }

    return log;
  }

  /// Seed 2 reviews for completed order products and update product ratings
  Future<String> seedReviews() async {
    String log = '\n--- Seeding Reviews ---\n';

    try {
      // Query pembeli UID
      final pembeliQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pembeli')
          .limit(1)
          .get();

      if (pembeliQuery.docs.isEmpty) {
        return log + '❌ Pembeli user not found. Seed users first.\n';
      }

      final pembeliUid = pembeliQuery.docs.first.id;
      final pembeliName =
          pembeliQuery.docs.first.data()['name'] as String? ?? 'Budi Santoso';

      // Review 1: Budi rates Bayam Segar 5 stars
      await _firestore.collection('reviews').add({
        'productId': 'prod_bayam',
        'orderId': 'order_seed_001',
        'userId': pembeliUid,
        'userName': pembeliName,
        'rating': 5.0,
        'comment': 'Bayamnya segar sekali, pengiriman cepat!',
        'createdAt': FieldValue.serverTimestamp(),
      });
      log += '✅ Review 1: Bayam Segar ⭐⭐⭐⭐⭐\n';

      // Update Bayam product rating
      await _firestore.collection('products').doc('prod_bayam').update({
        'rating': 5.0,
        'reviewCount': 1,
      });
      log += '   Updated prod_bayam rating: 5.0 (1 review)\n';

      // Review 2: Budi rates Tomat Merah 4 stars
      await _firestore.collection('reviews').add({
        'productId': 'prod_tomat',
        'orderId': 'order_seed_001',
        'userId': pembeliUid,
        'userName': pembeliName,
        'rating': 4.0,
        'comment': 'Tomat bagus, cuma ada beberapa yang agak lembek',
        'createdAt': FieldValue.serverTimestamp(),
      });
      log += '✅ Review 2: Tomat Merah ⭐⭐⭐⭐\n';

      // Update Tomat product rating
      await _firestore.collection('products').doc('prod_tomat').update({
        'rating': 4.0,
        'reviewCount': 1,
      });
      log += '   Updated prod_tomat rating: 4.0 (1 review)\n';
    } catch (e) {
      log += '❌ Error seeding reviews: $e\n';
    }

    return log;
  }
}
