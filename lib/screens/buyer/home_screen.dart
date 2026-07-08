import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/product_provider.dart';
import 'package:lapak_tani/providers/cart_provider.dart';
import 'package:lapak_tani/screens/buyer/search_screen.dart';
import 'package:lapak_tani/screens/buyer/cart_screen.dart';
import 'package:lapak_tani/screens/buyer/wishlist_screen.dart';
import 'package:lapak_tani/screens/buyer/order_history_screen.dart';
import 'package:lapak_tani/screens/buyer/profile_screen.dart';
import 'package:lapak_tani/screens/buyer/product_detail_screen.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
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
      appBar: AppBar(
        title: const Text('Lapak Tani'),
        actions: [
          if (user != null) ...[
            // Notification Bell
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationService().getUserNotifications(user.uid, user.role),
              builder: (context, snapshot) {
                int unreadNotif = 0;
                if (snapshot.hasData) {
                  unreadNotif = snapshot.data!.where((n) => !n.isRead).length;
                }
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                      },
                    ),
                    if (unreadNotif > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$unreadNotif',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
            ),
            
            // Chat Icon
            StreamBuilder<List<ChatRoomModel>>(
              stream: ChatService().getUserChatRooms(user.uid, user.role),
              builder: (context, snapshot) {
                int totalUnread = 0;
                if (snapshot.hasData) {
                  for (var room in snapshot.data!) {
                    totalUnread += room.unreadCountBuyer; // since this is buyer screen
                  }
                }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
                    },
                  ),
                  if (totalUnread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$totalUnread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          ]
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.shopping_cart),
            if (cartItemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$cartItemCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
