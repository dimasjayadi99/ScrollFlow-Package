import 'package:flutter/material.dart';

class DefaultLoadMoreErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const DefaultLoadMoreErrorWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load more'),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
