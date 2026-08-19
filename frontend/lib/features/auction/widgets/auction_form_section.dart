import 'package:flutter/material.dart';

class AuctionFormSection extends StatelessWidget {
  const AuctionFormSection({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class AuctionTextField extends StatelessWidget {
  const AuctionTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefixText,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<dynamic>? inputFormatters;
  final String? prefixText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters?.cast(),
      style: const TextStyle(fontSize: 17, color: Color(0xFF212124)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF9A9CA2),
          fontWeight: FontWeight.w400,
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontSize: 17, color: Color(0xFF868B94)),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 18 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD1D3D8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF868B94)),
        ),
      ),
    );
  }
}
