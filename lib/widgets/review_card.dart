import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: name + date ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    review.userName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _dateFormat.format(review.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Rating stars ────────────────────────────────────────────
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  size: 18,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 8),

            // ── Comment ─────────────────────────────────────────────────
            if (review.comment.isNotEmpty)
              Text(
                review.comment,
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
