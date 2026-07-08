import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/services/notification_service.dart';
import 'package:lapak_tani/models/notification_model.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('Harap login')));

    final notifService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tandai semua dibaca',
            onPressed: () {
              notifService.markAllAsRead(user.uid, user.role);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notifService.getUserNotifications(user.uid, user.role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final timeStr = DateFormat('dd MMM, HH:mm').format(notif.createdAt);

              return Container(
                color: notif.isRead ? Colors.transparent : Theme.of(context).primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notif.type == 'order' ? Colors.green : Colors.blue,
                    child: Icon(
                      notif.type == 'order' ? Icons.shopping_bag : Icons.info,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold),
                  ),
                  subtitle: Text(notif.message),
                  trailing: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  onTap: () {
                    if (!notif.isRead) {
                      notifService.markAsRead(notif.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
