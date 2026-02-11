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
        child: Theme(
           data: ThemeData.dark().copyWith(
             textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
           ),
           child: DropdownButtonFormField2<T>(
             value: selectedValue,
             decoration: InputDecoration(
               isDense: true,
               contentPadding: EdgeInsets.zero,
               border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(15),
                 borderSide: BorderSide.none,
               ),
               filled: true,
               fillColor: const Color(0xFF2C2C2E),
             ),
             isExpanded: true,
             hint: Text(
               hintText,
               style: const TextStyle(fontSize: 14, color: Colors.grey),
             ),
             items: items,
             onChanged: onChanged,
             dropdownStyleData: DropdownStyleData(
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(15),
                 color: const Color(0xFF1C1C1E),
               ),
               offset: const Offset(0, -5),
               scrollbarTheme: ScrollbarThemeData(
                 radius: const Radius.circular(40),
                 thickness: MaterialStateProperty.all(6),
                 thumbVisibility: MaterialStateProperty.all(true),
               ),
             ),
             menuItemStyleData: const MenuItemStyleData(
               height: 40,
               padding: EdgeInsets.only(left: 14, right: 14),
             ),
             style: const TextStyle(color: Colors.white),
             iconStyleData: const IconStyleData(
               icon: Icon(
                 Icons.keyboard_arrow_down_rounded,
                 color: Colors.grey,
               ),
               iconSize: 14,
             ),
           ),
        ),
      ),
    );
  }
}
          isExpanded: true,
          value: selectedValue,
          hint: Text(hintText, style: const TextStyle(color: Colors.grey)),

          items: items,

          onChanged: disabled ? null : onChanged,

          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2C2C2E),
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
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
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
