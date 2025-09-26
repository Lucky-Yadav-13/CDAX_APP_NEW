import 'package:flutter/material.dart';

/// Styled ElevatedButton used across the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = true,
    this.isStyled = false,
  });

  final String? label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isExpanded;
  final bool isStyled;

  @override
  Widget build(BuildContext context) {
    if (isStyled) {
      final Widget buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) const SizedBox(width: 8),
          ],
          if (icon != null)
            Icon(
              icon,
              color: Colors.black87,
              size: 20,
            ),
        ],
      );

      final Widget button = Container(
        decoration: BoxDecoration(
          color: const Color(0xFF87CEEB), // Light blue background
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: buttonChild,
            ),
          ),
        ),
      );

      if (isExpanded) {
        return SizedBox(width: double.infinity, child: button);
      }
      return button;
    }

    final Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        if (label != null) Text(label!),
      ],
    );

    final Widget button = ElevatedButton(
      onPressed: onPressed,
      child: buttonChild,
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}


