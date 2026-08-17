import 'package:flutter/material.dart';

import '../models/main_tab.dart';

class MainBottomNavigationBar extends StatelessWidget {
  const MainBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F1F3))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: MainTab.values.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkResponse(
                  onTap: () => onTap(index),
                  radius: 32,
                  child: Semantics(
                    selected: isSelected,
                    label: tab.label,
                    button: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NavigationIcon(tab: tab, isSelected: isSelected),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          maxLines: 1,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF202124)
                                : const Color(0xFFB8BBC0),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.tab, required this.isSelected});

  final MainTab tab;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      isSelected ? tab.selectedIcon : tab.icon,
      color: isSelected ? const Color(0xFF202124) : const Color(0xFFB8BBC0),
      size: 29,
    );

    if (tab.badgeCount == null) {
      return icon;
    }

    return Badge(
      label: Text('${tab.badgeCount}'),
      backgroundColor: const Color(0xFFFF6F0F),
      textColor: Colors.white,
      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      largeSize: 22,
      offset: const Offset(7, -4),
      child: icon,
    );
  }
}
