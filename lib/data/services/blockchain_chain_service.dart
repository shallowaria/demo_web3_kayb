import 'package:web3_demo/data/api/okx_chain_api_client.dart';
import 'package:web3_demo/data/config/okx_api_config.dart';
import 'package:web3_demo/data/models/blockchain_chain.dart';

/// Service layer for blockchain chain operations
class BlockchainChainService {
  late final OkxChainApiClient _apiClient;
  List<BlockchainChain>? _cachedChains;

  BlockchainChainService({required OkxApiConfig config}) {
    _apiClient = OkxChainApiClient(config: config);
  }

  /// Fetches supported blockchain chains
  ///
  /// Uses cached data if available to avoid redundant API calls
  /// Returns a list of [BlockchainChain] objects
  Future<List<BlockchainChain>> fetchSupportedChains(
      {bool forceRefresh = false}) async {
    if (_cachedChains != null && !forceRefresh) {
      return _cachedChains!;
    }

    try {
      final chains = await _apiClient.getSupportedChains();
      _cachedChains = chains;
      return chains;
    } catch (e) {
      rethrow;
    }
  }

  /// Clears the cached chains data
  void clearCache() {
    _cachedChains = null;
  }
}
