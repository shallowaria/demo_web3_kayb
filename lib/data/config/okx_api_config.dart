/// Configuration for OKX API authentication
class OkxApiConfig {
  final String apiKey;
  final String secretKey;
  final String passphrase;

  const OkxApiConfig({
    required this.apiKey,
    required this.secretKey,
    required this.passphrase,
  });

  /// Check if configuration is complete
  bool get isConfigured =>
      apiKey.isNotEmpty && secretKey.isNotEmpty && passphrase.isNotEmpty;
}
