import 'package:flutter/material.dart';
import 'package:web3_demo/data/config/api_credentials.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';
import 'package:web3_demo/data/notifiers/support_chain_notifier.dart';
import 'package:web3_demo/data/notifiers/transaction_history_notifier.dart';
import 'package:web3_demo/data/services/blockchain_transaction_service.dart';
import 'package:web3_demo/utils/date_formatter.dart';
import 'package:web3_demo/widgets/date_header_widget.dart';
import 'package:web3_demo/widgets/transaction_list_item_widget.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Hardcoded test address
  static const String testAddress =
      '0x337d5Cb9a0D6892AA0450B4a37cFf19f97FD2fBA';

  // Whitelist of major EVM chains that support transaction queries
  // Based on testing: not all chains returned by supported-chains API work with transaction queries
  static const List<String> _supportedChainIndexes = [
    '1',      // Ethereum Mainnet
    '56',     // BSC (Binance Smart Chain)
    '137',    // Polygon
    '42161',  // Arbitrum One
    '10',     // Optimism
    '43114',  // Avalanche C-Chain
    '250',    // Fantom
    '8453',   // Base
    '324',    // zkSync Era
    '59144',  // Linea
    '534352', // Scroll
    '42220',  // Celo
    '100',    // Gnosis Chain
    '1284',   // Moonbeam
    '1285',   // Moonriver
    '25',     // Cronos
  ];

  late final BlockchainTransactionService _txService;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _txService = BlockchainTransactionService(config: okxApiConfig);
    _scrollController.addListener(_onScroll);

    // Load transactions once chains are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chainsNotifier.value.isNotEmpty) {
        _loadTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener for infinite scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near bottom (200px threshold), load more
      if (!transactionsLoadingMoreNotifier.value && _txService.hasMorePages) {
        _loadMoreTransactions();
      }
    }
  }

  /// Loads initial transactions
  Future<void> _loadTransactions({bool forceRefresh = false}) async {
    if (chainsNotifier.value.isEmpty) {
      transactionsErrorNotifier.value =
          'Please wait for blockchain chains to load first';
      return;
    }

    transactionsLoadingNotifier.value = true;
    transactionsErrorNotifier.value = null;

    try {
      // Use whitelist of supported chains instead of all chains
      final chainIndexes = _supportedChainIndexes;

      final transactions = await _txService.fetchTransactions(
        address: testAddress,
        chainIndexes: chainIndexes,
        forceRefresh: forceRefresh,
      );

      transactionsNotifier.value = transactions;
    } catch (e) {
      print('❌ Error loading transactions: $e');
      transactionsErrorNotifier.value =
          'Failed to load transactions. Please try again.';
    } finally {
      transactionsLoadingNotifier.value = false;
    }
  }

  /// Loads next page of transactions
  Future<void> _loadMoreTransactions() async {
    if (chainsNotifier.value.isEmpty) return;

    transactionsLoadingMoreNotifier.value = true;

    try {
      // Use whitelist of supported chains instead of all chains
      final chainIndexes = _supportedChainIndexes;

      final transactions = await _txService.fetchMoreTransactions(
        address: testAddress,
        chainIndexes: chainIndexes,
      );

      transactionsNotifier.value = transactions;
    } catch (e) {
      print('❌ Error loading more transactions: $e');
      transactionsErrorNotifier.value =
          'Failed to load more transactions. Please try again.';
    } finally {
      transactionsLoadingMoreNotifier.value = false;
    }
  }

  /// Builds the transaction list grouped by date
  Widget _buildTransactionList(List<BlockchainTransaction> transactions) {
    final groupedTransactions = DateFormatter.groupByDate(transactions);

    // Flatten into list of widgets (headers + items)
    final items = <Widget>[];
    groupedTransactions.forEach((date, txList) {
      items.add(DateHeaderWidget(date: date));
      items.addAll(
        txList.map(
          (tx) => TransactionListItemWidget(
            transaction: tx,
            userAddress: testAddress,
          ),
        ),
      );
    });

    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + 1, // +1 for bottom indicator
      itemBuilder: (context, index) {
        if (index == items.length) {
          // Bottom loading/end indicator
          return _buildBottomIndicator();
        }
        return items[index];
      },
    );
  }

  /// Builds bottom indicator (loading or end message)
  Widget _buildBottomIndicator() {
    return ValueListenableBuilder(
      valueListenable: transactionsLoadingMoreNotifier,
      builder: (context, isLoadingMore, _) {
        if (isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!_txService.hasMorePages && transactionsNotifier.value.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'No more transactions',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Builds empty state when no transactions
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions will appear here once available',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Builds error state with retry button
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _loadTransactions(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: chainsNotifier,
      builder: (context, chains, _) {
        // Check if chains are loaded
        if (chains.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading blockchain chains...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Chains loaded, show transaction UI
        return ValueListenableBuilder(
          valueListenable: transactionsLoadingNotifier,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ValueListenableBuilder(
              valueListenable: transactionsErrorNotifier,
              builder: (context, error, _) {
                if (error != null) {
                  return _buildErrorState(error);
                }

                return ValueListenableBuilder(
                  valueListenable: transactionsNotifier,
                  builder: (context, transactions, _) {
                    if (transactions.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () => _loadTransactions(forceRefresh: true),
                      child: _buildTransactionList(transactions),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
