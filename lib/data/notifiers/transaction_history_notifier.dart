import 'package:flutter/foundation.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';

/// Module-level ValueNotifiers for transaction state

/// List of all transactions
final ValueNotifier<List<BlockchainTransaction>> transactionsNotifier =
    ValueNotifier([]);

/// Loading state for initial load
final ValueNotifier<bool> transactionsLoadingNotifier = ValueNotifier(false);

/// Loading state for pagination (load more)
final ValueNotifier<bool> transactionsLoadingMoreNotifier =
    ValueNotifier(false);

/// Error message state
final ValueNotifier<String?> transactionsErrorNotifier = ValueNotifier(null);
