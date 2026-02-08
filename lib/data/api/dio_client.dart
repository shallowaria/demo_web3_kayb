import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:web3_demo/data/config/proxy_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 【关键修复】无条件设置 adapter，确保能控制证书和代理行为
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        // 1. 忽略 SSL 证书错误 (解决真机 VPN 抓包/中间人证书导致的秒挂)
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

        // 2. 智能代理设置
        if (proxyConfig.enabled) {
          // 强制代理模式：使用配置文件中的代理地址
          // 适用于模拟器无法通过VPN访问的情况
          client.findProxy = (uri) => proxyConfig.proxyUrl;
        }
        // enabled = false 时，不设置 findProxy
        // HttpClient 将自动使用系统代理设置（包括手机的VPN配置）

        return client;
      },
    );
  }

  Dio get dio => _dio;
}
