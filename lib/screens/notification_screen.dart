import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/services/notification_service.dart';
import 'package:lapak_tani/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Harap login')));
    }

    final notifService = NotificationService();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B8040)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final timeStr = DateFormat(
                'dd MMM, HH:mm',
              ).format(notif.createdAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: notif.isRead
                      ? Colors.white
                      : const Color(0xFF1B8040).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isRead
                        ? Colors.black.withValues(alpha: 0.04)
                        : const Color(0xFF1B8040).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.type == 'order'
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notif.type == 'order'
                          ? Icons.shopping_bag_rounded
                          : Icons.info_outline_rounded,
                      color: notif.type == 'order'
                          ? Colors.green.shade600
                          : Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead
                          ? FontWeight.w500
                          : FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
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
