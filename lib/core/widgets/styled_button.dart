import 'package:flutter/material.dart';

/// Styled button matching the design with light blue background and arrow icon
class StyledButton extends StatelessWidget {
  const StyledButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.isExpanded = true,
  });

  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 8),
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
}
