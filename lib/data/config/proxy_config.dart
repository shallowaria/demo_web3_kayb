/// Network proxy configuration for accessing external APIs
class ProxyConfig {
  final bool enabled;
  final String host;
  final int port;

  const ProxyConfig({
    this.enabled = false,
    this.host = '127.0.0.1',
    this.port = 7897,
  });

  /// Get proxy URL in format "PROXY host:port"
  String get proxyUrl => 'PROXY $host:$port';

  bool get isConfigured => enabled && host.isNotEmpty && port > 0;
}

/// Default proxy configuration
///
/// Common proxy ports:
/// - Clash: 7897 (HTTP/HTTPS)
/// - V2Ray: 10809 (HTTP), 10808 (SOCKS5)
/// - Shadowsocks: 1080 (SOCKS5)
///
/// To enable proxy:
/// 1. Set enabled: true
/// 2. Configure host (usually 127.0.0.1 for local proxy)
/// 3. Configure port (check your proxy tool settings)
const ProxyConfig proxyConfig = ProxyConfig(
  enabled: true, // Set to true to enable proxy
  host: '10.0.2.2', // Android emulator special IP to access host machine (use 127.0.0.1 for desktop)
  port: 7897, // Proxy port (change to your proxy port)
);
