import 'package:flutter/material.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';

/// Reusable widget for individual transaction display
class TransactionListItemWidget extends StatelessWidget {
  final BlockchainTransaction transaction;
  final String userAddress;

  const TransactionListItemWidget({
    super.key,
    required this.transaction,
    required this.userAddress,
  });

  /// Shortens address to format: 0x1234...5678
  String _shortenAddress(String address) {
    if (address.length <= 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Gets transaction type label based on direction
  String _getTypeLabel() {
    final direction = transaction.getDirection(userAddress);
    final symbol = transaction.symbol.isNotEmpty ? transaction.symbol : 'Token';

    switch (direction) {
      case TransactionDirection.incoming:
        return 'Receive $symbol';
      case TransactionDirection.outgoing:
        return 'Send $symbol';
      case TransactionDirection.contract:
        return 'Contract Interaction';
    }
  }

  /// Gets subtitle text (from/to address or tx hash)
  String _getSubtitle() {
    final direction = transaction.getDirection(userAddress);

    switch (direction) {
      case TransactionDirection.incoming:
        // Show from address
        if (transaction.from.isNotEmpty) {
          return _shortenAddress(transaction.from.first.address);
        }
        return _shortenAddress(transaction.txHash);

      case TransactionDirection.outgoing:
        // Show to address
        if (transaction.to.isNotEmpty) {
          return _shortenAddress(transaction.to.first.address);
        }
        return _shortenAddress(transaction.txHash);

      case TransactionDirection.contract:
        // Show tx hash for contract interactions
        return _shortenAddress(transaction.txHash);
    }
  }

  /// Gets amount color based on direction
  Color _getAmountColor() {
    final direction = transaction.getDirection(userAddress);

    if (transaction.isFailed) {
      return Colors.grey;
    }

    switch (direction) {
      case TransactionDirection.incoming:
        return Colors.green;
      case TransactionDirection.outgoing:
        return Colors.red;
      case TransactionDirection.contract:
        return Colors.orange;
    }
  }

  /// Gets status badge widget for pending/failed transactions
  Widget? _getStatusBadge() {
    if (transaction.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pending',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (transaction.isFailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Failed',
          style: TextStyle(
            color: Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final direction = transaction.getDirection(userAddress);
    final displayAmount = transaction.getCompactDisplayAmount(userAddress);
    final amountColor = _getAmountColor();
    final statusBadge = _getStatusBadge();

    // Get first letter of symbol for avatar
    final symbolLetter = transaction.symbol.isNotEmpty
        ? transaction.symbol[0].toUpperCase()
        : 'T';

    // Determine avatar background color based on direction
    Color avatarColor;
    switch (direction) {
      case TransactionDirection.incoming:
        avatarColor = Colors.green.withValues(alpha: 0.2);
        break;
      case TransactionDirection.outgoing:
        avatarColor = Colors.red.withValues(alpha: 0.2);
        break;
      case TransactionDirection.contract:
        avatarColor = Colors.orange.withValues(alpha: 0.2);
        break;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: Text(
          symbolLetter,
          style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        _getTypeLabel(),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        _getSubtitle(),
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: SizedBox(
        width: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$displayAmount ${transaction.symbol}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
            if (statusBadge != null) ...[
              const SizedBox(height: 4),
              statusBadge,
            ],
          ],
        ),
      ),
    );
  }
}
