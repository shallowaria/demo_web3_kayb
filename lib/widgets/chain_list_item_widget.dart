import 'package:flutter/material.dart';
import 'package:web3_demo/data/models/blockchain_chain.dart';
import 'package:web3_demo/utils/string_extension.dart';

/// A list item widget displaying blockchain chain information
class ChainListItemWidget extends StatelessWidget {
  final BlockchainChain chain;

  const ChainListItemWidget({super.key, required this.chain});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        child: ClipOval(
          child: Image.network(
            chain.logoUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.link, color: Colors.white70, size: 24);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              );
            },
          ),
        ),
      ),
      title: Text(
        chain.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        chain.shortName.toTitleCase(),
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
