import 'package:flutter/material.dart';

/// Reusable Authentication Text Field Widget.
/// Listens to [FocusNode] focus events so the placeholder text clears immediately upon selection.
class CustomAuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const CustomAuthTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<CustomAuthTextField> createState() => _CustomAuthTextFieldState();
}

class _CustomAuthTextFieldState extends State<CustomAuthTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Re-render field on focus node state change to clear placeholder text instantly
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        // Clears placeholder text immediately when the text field receives focus
        hintText: _focusNode.hasFocus ? null : widget.placeholder,
        hintStyle: const TextStyle(color: Color(0xFF444748)),
        prefixIcon: Icon(widget.prefixIcon, color: const Color(0xFF444748)),
        filled: true,
        fillColor: const Color(0xFFF5F3F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
