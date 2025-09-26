import 'package:flutter/material.dart';

/// Styled text field matching the design with light blue background and icons
class StyledTextField extends StatelessWidget {
  const StyledTextField({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.black54,
                  size: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
