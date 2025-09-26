import 'package:flutter/material.dart';
import '../../../core/widgets/app_button.dart';

/// Suggestive Learning CTA card
/// - Large image, short description, CTA button
class SuggestiveLearningCard extends StatelessWidget {
  const SuggestiveLearningCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            AppButton(
              onPressed: onPressed,
              label: 'Start Learning',
              isStyled: true,
            ),
          ],
        ),
      ),
    );
  }
}


