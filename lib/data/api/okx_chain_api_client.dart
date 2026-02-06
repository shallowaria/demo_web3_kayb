import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:web3_demo/data/api/dio_client.dart';
import 'package:web3_demo/data/config/okx_api_config.dart';
import 'package:web3_demo/data/models/blockchain_chain.dart';

/// API client for OKX blockchain chain endpoints with authentication
class OkxChainApiClient {
  final Dio _dio = DioClient().dio;
  final OkxApiConfig config;

  static const String _supportedChainsUrl =
      'https://web3.okx.com/api/v5/wallet/chain/supported-chains';
  static const String _requestPath = '/api/v5/wallet/chain/supported-chains';

  OkxChainApiClient({required this.config});

  /// Generates authentication headers for OKX API requests
  Map<String, String> _generateAuthHeaders(String method, String requestPath,
      {String body = ''}) {
    // OKX API requires ISO 8601 format with milliseconds (3 digits), not microseconds
    final now = DateTime.now().toUtc();
    final timestamp = '${now.toIso8601String().split('.')[0]}.${now.millisecond.toString().padLeft(3, '0')}Z';

    // Create signature: timestamp + method + requestPath + body
    final signatureString = '$timestamp$method$requestPath$body';

    // HMAC SHA256 with secret key
    final key = utf8.encode(config.secretKey);
    final bytes = utf8.encode(signatureString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    // Base64 encode the signature
    final signature = base64.encode(digest.bytes);

    return {
      'OK-ACCESS-PROJECT': config.projectId,
      'OK-ACCESS-KEY': config.apiKey,
      'OK-ACCESS-SIGN': signature,
      'OK-ACCESS-TIMESTAMP': timestamp,
      'OK-ACCESS-PASSPHRASE': config.passphrase,
    };
  }

  /// Fetches the list of supported blockchain chains from OKX API
  ///
  /// Returns a list of [BlockchainChain] objects on success
  /// Throws [DioException] on network or server errors
  Future<List<BlockchainChain>> getSupportedChains() async {
    if (!config.isConfigured) {
      throw Exception(
          'OKX API not configured. Please provide project ID, API key, secret key, and passphrase.');
    }

    try {
      // Generate authentication headers
      final authHeaders = _generateAuthHeaders('GET', _requestPath);
      print('🔑 Making request to: $_supportedChainsUrl');
      print('🔑 Timestamp: ${authHeaders['OK-ACCESS-TIMESTAMP']}');
      print('🔑 Auth headers: ${authHeaders.keys.join(", ")}');

      final response = await _dio.get(
        _supportedChainsUrl,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200) {
        final chainResponse = BlockchainChainResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (chainResponse.isSuccess) {
          return chainResponse.data;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error:
                'API returned error code: ${chainResponse.code}, msg: ${chainResponse.msg}',
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ DioException type: ${e.type}');
      print('❌ Error message: ${e.message}');
      print('❌ Error: ${e.error}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw DioException(
          requestOptions: e.requestOptions,
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timeout - please check your internet connection',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw DioException(
          requestOptions: e.requestOptions,
          type: DioExceptionType.receiveTimeout,
          error: 'Receive timeout - server took too long to respond',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw DioException(
          requestOptions: e.requestOptions,
          type: DioExceptionType.connectionError,
          error: 'Network error - please check your internet connection',
        );
      }
      rethrow;
    }
  }
}
