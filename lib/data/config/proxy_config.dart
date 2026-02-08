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
/// **For Real Devices (Recommended):**
/// Set enabled: false to use system VPN settings
/// This allows the app to respect phone's VPN configuration
///
/// **For Android Emulator:**
/// If emulator cannot access through VPN, enable proxy:
///   enabled: true
///   host: '10.0.2.2' (special IP to access host machine)
///   port: 7897 (or your proxy port)
///
/// Common proxy ports:
/// - Clash: 7897 (HTTP/HTTPS)
/// - V2Ray: 10809 (HTTP), 10808 (SOCKS5)
/// - Shadowsocks: 1080 (SOCKS5)
const ProxyConfig proxyConfig = ProxyConfig(
  enabled:
      false, // false = use system VPN (for real devices), true = use custom proxy (for emulator)
  host: '10.0.2.2', // '10.0.2.2' for Android emulator, '127.0.0.1' for desktop
  port: 7897, // Your proxy port (only used when enabled is true)
);
