/// Represents a blockchain chain returned from the OKX API
class BlockchainChain {
  final String name;
  final String logoUrl;
  final String shortName;
  final String chainIndex;

  const BlockchainChain({
    required this.name,
    required this.logoUrl,
    required this.shortName,
    required this.chainIndex,
  });

  factory BlockchainChain.fromJson(Map<String, dynamic> json) {
    return BlockchainChain(
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      shortName: json['shortName'] as String,
      chainIndex: json['chainIndex'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'shortName': shortName,
      'chainIndex': chainIndex,
    };
  }
}

/// Represents the full API response from OKX supported chains endpoint
class BlockchainChainResponse {
  final String code;
  final List<BlockchainChain> data;
  final String msg;

  const BlockchainChainResponse({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory BlockchainChainResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    final chains = dataList
        .map((item) => BlockchainChain.fromJson(item as Map<String, dynamic>))
        .toList();

    return BlockchainChainResponse(
      code: json['code'] as String,
      data: chains,
      msg: json['msg'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data.map((chain) => chain.toJson()).toList(),
      'msg': msg,
    };
  }

  bool get isSuccess => code == '0';
}
