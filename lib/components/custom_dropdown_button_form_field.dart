import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final T? selectedValue;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final void Function(dynamic)? onChanged;

  const CustomDropdownButtonFormField({
    super.key,
    required this.selectedValue,
    required this.hintText,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      value: selectedValue,
      hint: Text(hintText),
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      style: const TextStyle(
        fontSize: AppTexts.fontSizeMedium,
        color: Colors.black87,
      ),
      buttonStyleData: const ButtonStyleData(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        elevation: 4,
        offset: const Offset(0, 8),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
