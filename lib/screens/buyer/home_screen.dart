import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/cart_provider.dart';
import 'package:lapak_tani/screens/buyer/cart_screen.dart';
import 'package:lapak_tani/screens/buyer/wishlist_screen.dart';
import 'package:lapak_tani/screens/buyer/order_history_screen.dart';
import 'package:lapak_tani/screens/buyer/profile_screen.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/screens/buyer/buyer_home_tab.dart';
import 'package:lapak_tani/screens/chat/chat_list_screen.dart';
import 'package:lapak_tani/screens/notification_screen.dart';
import 'package:lapak_tani/services/chat_service.dart';
import 'package:lapak_tani/services/notification_service.dart';
import 'package:lapak_tani/models/chat_room_model.dart';
import 'package:lapak_tani/models/notification_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().fetchCart(user.uid);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cartItemCount = context.watch<CartProvider>().itemCount;

    final List<Widget> pages = [
      const BuyerHomeTab(),
      const WishlistScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Lapak Tani',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (user != null) ...[
            // ── Notification Bell ───────────────────────────────────────
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationService().getUserNotifications(
                user.uid,
                user.role,
              ),
              builder: (context, snapshot) {
                int unreadNotif = 0;
                if (snapshot.hasData) {
                  unreadNotif = snapshot.data!.where((n) => !n.isRead).length;
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    if (unreadNotif > 0)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadNotif',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // ── Chat Icon ───────────────────────────────────────────────
            StreamBuilder<List<ChatRoomModel>>(
              stream: ChatService().getUserChatRooms(user.uid, user.role),
              builder: (context, snapshot) {
                int totalUnread = 0;
                if (snapshot.hasData) {
                  for (var room in snapshot.data!) {
                    totalUnread +=
                        room.unreadCountBuyer; // since this is buyer screen
                  }
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatListScreen(),
                          ),
                        );
                      },
                    ),
                    if (totalUnread > 0)
                      Positioned(
                        right: 8,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '$totalUnread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: pages[_selectedIndex],

      // ── Floating Action Button (Keranjang) ──────────────────────────
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              backgroundColor: const Color(0xFF1B8040),
              foregroundColor: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cartItemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ), // Agar badge keranjang juga kontras
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '$cartItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,

      // ── Bottom Navigation Bar ─────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF1B8040),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
