import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ModernHudDropdown<T> extends StatelessWidget {
  final T? selectedValue;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool disabled;

  const ModernHudDropdown({
    super.key,
    required this.selectedValue,
    required this.hintText,
    required this.items,
    this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: Opacity(
        opacity: 1.0,
        child: DropdownButtonFormField2<T>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(hintText),

          items: items,

          onChanged: disabled ? null : onChanged,

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),

          buttonStyleData: const ButtonStyleData(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 8),
          ),

          dropdownStyleData: DropdownStyleData(
            maxHeight: 280,
            elevation: 4,
            offset: const Offset(0, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // ✅ 提高透明度，可读性好
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          menuItemStyleData: const MenuItemStyleData(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
