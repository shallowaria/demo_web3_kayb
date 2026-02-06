import 'package:flutter/material.dart';
import 'package:web3_demo/data/config/api_credentials.dart';
import 'package:web3_demo/data/notifiers/support_chain_notifier.dart';
import 'package:web3_demo/data/services/blockchain_chain_service.dart';
import 'package:web3_demo/widgets/chain_list_item_widget.dart';

class SupportChainPage extends StatefulWidget {
  const SupportChainPage({super.key});

  @override
  State<SupportChainPage> createState() => _SupportChainPageState();
}

class _SupportChainPageState extends State<SupportChainPage> {
  late final BlockchainChainService _chainService;

  @override
  void initState() {
    super.initState();
    _chainService = BlockchainChainService(config: okxApiConfig);
    _loadChains();
  }

  Future<void> _loadChains({bool forceRefresh = false}) async {
    chainsLoadingNotifier.value = true;
    chainsErrorNotifier.value = null;

    try {
      final chains = await _chainService.fetchSupportedChains(forceRefresh: forceRefresh);
      chainsNotifier.value = chains;
    } catch (e) {
      chainsErrorNotifier.value = e.toString();
    } finally {
      chainsLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: chainsLoadingNotifier,
      builder: (context, isLoading, _) {
        if (isLoading && chainsNotifier.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ValueListenableBuilder<String?>(
          valueListenable: chainsErrorNotifier,
          builder: (context, error, _) {
            if (error != null && chainsNotifier.value.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load chains',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _loadChains(forceRefresh: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ValueListenableBuilder(
              valueListenable: chainsNotifier,
              builder: (context, chains, _) {
                if (chains.isEmpty) {
                  return const Center(
                    child: Text('No chains available'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _loadChains(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: chains.length,
                    itemBuilder: (context, index) {
                      return ChainListItemWidget(chain: chains[index]);
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
