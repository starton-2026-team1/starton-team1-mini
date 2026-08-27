import 'package:flutter/material.dart';

class RefreshableEmptyState extends StatelessWidget {
  const RefreshableEmptyState({
    required this.message,
    required this.onRefresh,
    this.textStyle,
    super.key,
  });

  final String message;
  final RefreshCallback onRefresh;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(message, style: textStyle)),
          ),
        ],
      ),
    );
  }
}
