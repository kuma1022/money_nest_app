import 'package:flutter/material.dart';

class CustomInputFormFieldBySuggestion extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<dynamic> suggestions;
  final bool loading;
  final String notFoundText;
  final void Function(String) onChanged;
  final void Function(bool) onFocusChange;
  final void Function(dynamic) onSuggestionTap;

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
    required this.onSuggestionTap,
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
            decoration: InputDecoration(
              labelText: labelText,
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
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
          ),
          if (focusNode.hasFocus)
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : suggestions.isEmpty
                  ? ListTile(title: Text(notFoundText))
                  : ListView(
                      shrinkWrap: true,
                      children: suggestions.map((e) {
                        return ListTile(
                          title: Text(e.ticker!),
                          subtitle: Text(e.name),
                          onTap: () => onSuggestionTap(e),
                        );
                      }).toList(),
                    ),
            ),
        ],
      ),
    );
  }
}
