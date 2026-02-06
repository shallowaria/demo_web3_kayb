import 'package:flutter/material.dart';
import 'package:web3_demo/data/models/blockchain_chain.dart';

/// Notifier for the list of blockchain chains
final ValueNotifier<List<BlockchainChain>> chainsNotifier = ValueNotifier([]);

/// Notifier for the loading state when fetching chains
final ValueNotifier<bool> chainsLoadingNotifier = ValueNotifier(false);

/// Notifier for error messages when fetching chains fails
final ValueNotifier<String?> chainsErrorNotifier = ValueNotifier(null);
