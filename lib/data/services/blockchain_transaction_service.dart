import 'package:web3_demo/data/api/okx_address_history_api.dart';
import 'package:web3_demo/data/config/okx_api_config.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';

/// Service layer managing transaction operations and pagination state
class BlockchainTransactionService {
  final OkxAddressHistoryApiClient _apiClient;

  // In-memory cache: address -> transactions
  final Map<String, List<BlockchainTransaction>> _transactionCache = {};

  // Pagination state: address -> next cursor
  final Map<String, String?> _nextCursor = {};

  // Has more pages flag
  bool _hasMorePages = true;

  BlockchainTransactionService({required OkxApiConfig config})
    : _apiClient = OkxAddressHistoryApiClient(config: config);

  /// Indicates if more data is available for pagination
  bool get hasMorePages => _hasMorePages;

  /// Fetches initial transactions for an address across multiple chains
  ///
  /// Parameters:
  /// - [address]: Wallet address to query
  /// - [chainIndexes]: List of chain indexes to query
  /// - [forceRefresh]: If true, clears cache and fetches fresh data
  ///
  /// Returns list of transactions from cache or API
  Future<List<BlockchainTransaction>> fetchTransactions({
    required String address,
    required List<String> chainIndexes,
    bool forceRefresh = false,
  }) async {
    // Clear cache if force refresh
    if (forceRefresh) {
      _transactionCache.remove(address);
      _nextCursor.remove(address);
      _hasMorePages = true;
    }

    // Return cached data if available and not force refresh
    if (!forceRefresh && _transactionCache.containsKey(address)) {
      return _transactionCache[address]!;
    }

    try {
      // Fetch from API
      final response = await _apiClient.getTransactionsByAddress(
        address: address,
        chainIndexes: chainIndexes,
        limit: 20,
      );

      // Store transactions in cache
      final transactions = response.allTransactions;
      _transactionCache[address] = transactions;

      // Store cursor for pagination
      final cursor = response.getCursor();
      _nextCursor[address] = cursor;

      // Update hasMorePages flag
      _hasMorePages = cursor != null && cursor.isNotEmpty;

      // Sort by date descending (newest first)
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return transactions;
    } catch (e) {
      print('❌ Error fetching transactions: $e');
      rethrow;
    }
  }

  /// Fetches next page of transactions using cursor
  ///
  /// Parameters:
  /// - [address]: Wallet address to query
  /// - [chainIndexes]: List of chain indexes to query
  ///
  /// Returns updated list of all transactions (cached + new)
  Future<List<BlockchainTransaction>> fetchMoreTransactions({
    required String address,
    required List<String> chainIndexes,
  }) async {
    // Check if we have a cursor
    final cursor = _nextCursor[address];
    if (cursor == null || cursor.isEmpty) {
      print('⚠️ No cursor available for pagination');
      _hasMorePages = false;
      return _transactionCache[address] ?? [];
    }

    try {
      // Fetch next page from API
      final response = await _apiClient.getTransactionsByAddress(
        address: address,
        chainIndexes: chainIndexes,
        cursor: cursor,
        limit: 20,
      );

      // Get new transactions
      final newTransactions = response.allTransactions;

      // Append to cache
      final existingTransactions = _transactionCache[address] ?? [];
      final allTransactions = [...existingTransactions, ...newTransactions];
      _transactionCache[address] = allTransactions;

      // Update cursor
      final nextCursor = response.getCursor();
      _nextCursor[address] = nextCursor;

      // Update hasMorePages flag
      _hasMorePages = nextCursor != null && nextCursor.isNotEmpty;

      // Sort by date descending (newest first)
      allTransactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return allTransactions;
    } catch (e) {
      print('❌ Error fetching more transactions: $e');
      rethrow;
    }
  }

  /// Clears all cached data and resets pagination state
  void clearCache() {
    _transactionCache.clear();
    _nextCursor.clear();
    _hasMorePages = true;
  }
}
