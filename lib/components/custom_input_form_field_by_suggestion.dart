import 'package:flutter/material.dart';

class CustomInputFormFieldBySuggestion extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<Widget> suggestions;
  final bool loading;
  final String notFoundText;
  final bool disabled;
  final void Function(String) onChanged;
  final void Function(bool) onFocusChange;

  const CustomInputFormFieldBySuggestion({
    super.key,
    required this.labelText,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.loading,
    required this.notFoundText,
    required this.onChanged,
    required this.onFocusChange,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: onFocusChange,
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onChanged: onChanged,
            enabled: !disabled,
          ),
          if (focusNode.hasFocus && controller.text.isNotEmpty)
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2C2C2E), // Dark dropdown list
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : suggestions.isEmpty
                  ? ListTile(title: Text(notFoundText, style: const TextStyle(color: Colors.white)))
                  : ListView(shrinkWrap: true, children: suggestions), // Suggestions need to be styled individually or assume they inherit text color
            ),
        ],
      ),
    );
  }
}
