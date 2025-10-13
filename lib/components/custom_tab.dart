import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';

// Tab
class CustomTab extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> tabViews;

  const CustomTab({super.key, required this.tabs, required this.tabViews});

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  int tabIndex = 0;

  void _onTabTap(int idx) {
    setState(() {
      tabIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E6EA)),
          ),
          child: Row(
            children: widget.tabs.asMap().entries.map((entry) {
              int idx = entry.key;
              String tab = entry.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTap(idx),
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tabIndex == idx
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                            fontSize: AppTexts.fontSizeMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: widget.tabViews[tabIndex],
        ),
      ],
    );
  }
}
