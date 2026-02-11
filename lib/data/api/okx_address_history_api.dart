import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:web3_demo/data/api/dio_client.dart';
import 'package:web3_demo/data/config/okx_api_config.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';

/// API client for OKX transaction history endpoints with authentication
class OkxAddressHistoryApiClient {
  final Dio _dio = DioClient().dio;
  final OkxApiConfig config;

  static const String _baseUrl = 'https://web3.okx.com';
  static const String _requestPath =
      '/api/v5/wallet/post-transaction/transactions-by-address';

  OkxAddressHistoryApiClient({required this.config});

  /// Generates authentication headers for OKX API requests
  /// Reused pattern from OkxChainApiClient
  Map<String, String> _generateAuthHeaders(
    String method,
    String requestPath, {
    String body = '',
  }) {
    // OKX API requires ISO 8601 format with milliseconds (3 digits), not microseconds
    final now = DateTime.now().toUtc();
    final timestamp = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}T'
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}Z';

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

  /// Fetches transactions for a specific address across multiple chains
  ///
  /// Required parameters:
  /// - [address]: Wallet address to query
  /// - [chainIndexes]: List of chain indexes (max 50)
  ///
  /// Optional parameters:
  /// - [cursor]: Pagination cursor from previous response
  /// - [limit]: Number of transactions per request (default 20, max 20 for multi-chain)
  ///
  /// Returns [TransactionHistoryResponse] on success
  /// Throws [DioException] on network or server errors
  Future<TransactionHistoryResponse> getTransactionsByAddress({
    required String address,
    required List<String> chainIndexes,
    String? cursor,
    int limit = 20,
  }) async {
    if (!config.isConfigured) {
      throw Exception(
        'OKX API not configured. Please provide project ID, API key, secret key, and passphrase.',
      );
    }

    if (chainIndexes.isEmpty) {
      throw ArgumentError('chainIndexes cannot be empty');
    }

    if (chainIndexes.length > 50) {
      throw ArgumentError('Maximum 50 chains allowed per request');
    }

    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'address': address,
        'chains': chainIndexes.join(','),
        'limit': limit.toString(),
      };

      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }

      // Build full URL with query parameters
      final uri = Uri.parse('$_baseUrl$_requestPath');
      final uriWithQuery = uri.replace(queryParameters: queryParams);

      // CRITICAL: Include query string in signature
      final authHeaders = _generateAuthHeaders(
        'GET',
        '$_requestPath?${uriWithQuery.query}',
      );

      print('🔑 Making request to: $uriWithQuery');
      print('🔑 Chains: ${chainIndexes.join(", ")}');
      print('🔑 Cursor: ${cursor ?? "none"}');

      final response = await _dio.get(
        uriWithQuery.toString(),
        options: Options(headers: authHeaders),
      );

      if (response.statusCode == 200) {
        final txResponse = TransactionHistoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (txResponse.isSuccess) {
          print('✅ Fetched ${txResponse.allTransactions.length} transactions');
          return txResponse;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error:
                'API returned error code: ${txResponse.code}, msg: ${txResponse.msg}',
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
