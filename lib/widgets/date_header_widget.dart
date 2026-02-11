import 'package:flutter/material.dart';

/// Simple header widget for date sections in grouped transaction list
class DateHeaderWidget extends StatelessWidget {
  final String date;

  const DateHeaderWidget({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        date,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
