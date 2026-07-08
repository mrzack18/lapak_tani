import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapak_tani/models/feedback_model.dart';
import 'package:lapak_tani/services/feedback_service.dart';

class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        title: const Text(
          'Masukan Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<FeedbackModel>>(
        stream: FeedbackService().getFeedbacksStream(),
        builder: (context, snapshot) {
          // ── Loading State ──────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B8040)),
            );
          }

          // ── Error State ────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final feedbacks = snapshot.data ?? [];

          // ── Empty State ────────────────────────────────────────────────
          if (feedbacks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada masukan dari pengguna',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // ── Feedback List ──────────────────────────────────────────────
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final fb = feedbacks[index];
              final isRead = fb.isRead;

              final roleColor = fb.userRole.toLowerCase() == 'petani'
                  ? const Color(0xFF1B8040) // Green
                  : const Color(0xFF0284C7); // Blue

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isRead
                        ? Colors.grey.shade200
                        : const Color(0xFF1B8040).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: isRead
                      ? [] // Tanpa shadow jika sudah dibaca
                      : [
                          BoxShadow(
                            color: const Color(0xFF1B8040).withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card (Profil & Waktu)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ikon Profil
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              fb.userRole.toLowerCase() == 'petani'
                                  ? Icons.storefront_rounded
                                  : Icons.person_outline_rounded,
                              color: roleColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Nama & Role
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fb.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        fb.userRole.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: roleColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'dd MMM yyyy, HH:mm',
                                      ).format(fb.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Pesan Feedback
                      Text(
                        fb.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead
                              ? Colors.grey.shade700
                              : const Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Action Row (Tandai Dibaca / Sudah Dibaca)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isRead)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1B8040),
                                backgroundColor: const Color(
                                  0xFF1B8040,
                                ).withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                FeedbackService().markAsRead(fb.id);
                              },
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Tandai Dibaca',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.done_all_rounded,
                                    color: Colors.green.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sudah dibaca',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
