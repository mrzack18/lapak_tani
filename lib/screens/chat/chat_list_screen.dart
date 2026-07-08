import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/services/chat_service.dart';
import 'package:lapak_tani/models/chat_room_model.dart';
import 'package:lapak_tani/screens/chat/chat_detail_screen.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('Harap login')));

    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatService.getUserChatRooms(user.uid, user.role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(child: Text('Belum ada pesan.'));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              // Jika role pembeli, tampilkan nama penjual, dan sebaliknya.
              final isBuyer = user.role == 'pembeli';
              final displayName = isBuyer ? room.sellerName : room.buyerName;
              final unreadCount = isBuyer ? room.unreadCountBuyer : room.unreadCountSeller;
              
              final timeStr = DateFormat('dd MMM, HH:mm').format(room.lastMessageTime);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  room.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(room: room),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
