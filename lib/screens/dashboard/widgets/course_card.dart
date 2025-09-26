import 'package:flutter/material.dart';

/// Reusable course card
/// - Rounded corners (14), elevation 2, padding 12
/// - Thumbnail, title, progress bar, locked state
/// - Tappable to trigger navigation
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.title,
    required this.thumbnailUrl,
    required this.progressPercent,
    this.isLocked = false,
    this.onTap,
    this.width,
  });

  final String title;
  final String thumbnailUrl;
  final double progressPercent; // 0.0 - 1.0
  final bool isLocked;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 110, // Constrained to avoid overflows in small cards
                    child: Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: progressPercent.clamp(0.0, 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progressPercent * 100).round()}%',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                if (isLocked) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.lock, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Locked',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


