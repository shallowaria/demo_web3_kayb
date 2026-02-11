/// Transaction direction from the perspective of the user
enum TransactionDirection {
  incoming,
  outgoing,
  contract,
}

/// Represents an address with amount in a transaction
class TransactionAddress {
  final String address;
  final String amount;

  TransactionAddress({
    required this.address,
    required this.amount,
  });

  factory TransactionAddress.fromJson(Map<String, dynamic> json) {
    return TransactionAddress(
      address: json['address'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'amount': amount,
    };
  }
}

/// Main transaction entity
class BlockchainTransaction {
  final String chainIndex;
  final String txHash;
  final String txTime; // Unix timestamp in milliseconds
  final List<TransactionAddress> from;
  final List<TransactionAddress> to;
  final String tokenAddress;
  final String amount;
  final String symbol;
  final String txStatus; // "success", "failed", "pending"
  final bool hitBlacklist;
  final String tag; // e.g., "erc20", "native"
  final String itype; // "0" = outgoing, "1" = incoming, "2" = contract

  BlockchainTransaction({
    required this.chainIndex,
    required this.txHash,
    required this.txTime,
    required this.from,
    required this.to,
    required this.tokenAddress,
    required this.amount,
    required this.symbol,
    required this.txStatus,
    required this.hitBlacklist,
    required this.tag,
    required this.itype,
  });

  /// Converts Unix timestamp (milliseconds) to DateTime
  DateTime get dateTime {
    final timestamp = int.tryParse(txTime) ?? 0;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if transaction was successful
  bool get isSuccess => txStatus.toLowerCase() == 'success';

  /// Check if transaction failed
  bool get isFailed => txStatus.toLowerCase() == 'failed';

  /// Check if transaction is pending
  bool get isPending => txStatus.toLowerCase() == 'pending';

  /// Determines transaction direction based on user address
  /// Primary method: uses itype field
  /// Fallback: compares user address with from/to arrays
  TransactionDirection getDirection(String userAddress) {
    // Primary: use itype field
    // "0" = outgoing, "1" = incoming, "2" = contract interaction
    if (itype == '1') return TransactionDirection.incoming;
    if (itype == '0') return TransactionDirection.outgoing;
    if (itype == '2') return TransactionDirection.contract;

    // Fallback: compare user address with from/to
    final userLower = userAddress.toLowerCase();
    final isFromUser =
        from.any((a) => a.address.toLowerCase() == userLower);
    final isToUser = to.any((a) => a.address.toLowerCase() == userLower);

    if (isToUser && !isFromUser) return TransactionDirection.incoming;
    if (isFromUser && !isToUser) return TransactionDirection.outgoing;
    return TransactionDirection.contract;
  }

  /// Returns display amount with +/- sign based on direction
  /// Formats the amount to a maximum of 8 decimal places, removing trailing zeros
  String getDisplayAmount(String userAddress) {
    final direction = getDirection(userAddress);
    final prefix = direction == TransactionDirection.incoming ? '+' : '-';

    // Parse amount string to double
    final amountValue = double.tryParse(amount) ?? 0.0;

    // Format to 8 decimal places and remove trailing zeros
    String formattedAmount;
    if (amountValue == 0) {
      formattedAmount = '0';
    } else if (amountValue < 0.00000001) {
      // Very small numbers: use scientific notation
      formattedAmount = amountValue.toStringAsExponential(2);
    } else {
      // Round to 8 decimal places
      formattedAmount = amountValue.toStringAsFixed(8);
      // Remove trailing zeros and decimal point if not needed
      formattedAmount = formattedAmount.replaceAll(RegExp(r'0+$'), '');
      formattedAmount = formattedAmount.replaceAll(RegExp(r'\.$'), '');
    }

    return '$prefix$formattedAmount';
  }

  /// Returns compact display amount that ensures symbol is always visible
  /// Uses scientific notation when amount + symbol would be too long
  /// maxLength: maximum characters for the entire display (amount + space + symbol)
  String getCompactDisplayAmount(String userAddress, {int maxLength = 18}) {
    final direction = getDirection(userAddress);
    final prefix = direction == TransactionDirection.incoming ? '+' : '-';
    final amountValue = double.tryParse(amount) ?? 0.0;

    // Reserve space for: prefix + space + symbol
    // e.g., "+  ETH" = 1 + 1 + symbol.length
    final symbolLength = symbol.isNotEmpty ? symbol.length : 5; // Reserve 5 for "Token"
    final reservedLength = 1 + 1 + symbolLength; // prefix + space + symbol
    final availableForAmount = maxLength - reservedLength;

    String formattedAmount;

    if (amountValue == 0) {
      formattedAmount = '0';
    } else {
      // Try normal formatting first
      if (amountValue < 0.00000001) {
        formattedAmount = amountValue.toStringAsExponential(2);
      } else {
        formattedAmount = amountValue.toStringAsFixed(8);
        formattedAmount = formattedAmount.replaceAll(RegExp(r'0+$'), '');
        formattedAmount = formattedAmount.replaceAll(RegExp(r'\.$'), '');
      }

      // Check if the formatted amount is too long
      if (formattedAmount.length > availableForAmount) {
        // Switch to scientific notation to save space
        if (amountValue >= 1e6) {
          // Large numbers: use scientific notation
          formattedAmount = amountValue.toStringAsExponential(2);
        } else if (amountValue >= 1000) {
          // Medium large numbers: try fewer decimals
          formattedAmount = amountValue.toStringAsFixed(2);
          formattedAmount = formattedAmount.replaceAll(RegExp(r'0+$'), '');
          formattedAmount = formattedAmount.replaceAll(RegExp(r'\.$'), '');

          // Still too long? Use scientific notation
          if (formattedAmount.length > availableForAmount) {
            formattedAmount = amountValue.toStringAsExponential(2);
          }
        } else {
          // Small numbers with many decimals: reduce precision
          int precision = 4;
          while (precision > 0) {
            formattedAmount = amountValue.toStringAsFixed(precision);
            formattedAmount = formattedAmount.replaceAll(RegExp(r'0+$'), '');
            formattedAmount = formattedAmount.replaceAll(RegExp(r'\.$'), '');

            if (formattedAmount.length <= availableForAmount) break;
            precision--;
          }

          // If still too long, use scientific notation
          if (formattedAmount.length > availableForAmount) {
            formattedAmount = amountValue.toStringAsExponential(2);
          }
        }
      }
    }

    return '$prefix$formattedAmount';
  }

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      chainIndex: json['chainIndex'] as String? ?? '',
      txHash: json['txHash'] as String? ?? '',
      txTime: json['txTime'] as String? ?? '0',
      from: (json['from'] as List<dynamic>?)
              ?.map((e) => TransactionAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      to: (json['to'] as List<dynamic>?)
              ?.map((e) => TransactionAddress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tokenAddress: json['tokenAddress'] as String? ?? '',
      amount: json['amount'] as String? ?? '0',
      symbol: json['symbol'] as String? ?? '',
      txStatus: json['txStatus'] as String? ?? 'pending',
      hitBlacklist: json['hitBlacklist'] as bool? ?? false,
      tag: json['tag'] as String? ?? '',
      itype: json['itype'] as String? ?? '2',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chainIndex': chainIndex,
      'txHash': txHash,
      'txTime': txTime,
      'from': from.map((e) => e.toJson()).toList(),
      'to': to.map((e) => e.toJson()).toList(),
      'tokenAddress': tokenAddress,
      'amount': amount,
      'symbol': symbol,
      'txStatus': txStatus,
      'hitBlacklist': hitBlacklist,
      'tag': tag,
      'itype': itype,
    };
  }
}

/// Wraps transactions per chain with cursor for pagination
class ChainTransactionData {
  final String chainIndex;
  final List<BlockchainTransaction> transactionList;
  final String? cursor; // Null or empty when no more pages

  ChainTransactionData({
    required this.chainIndex,
    required this.transactionList,
    this.cursor,
  });

  factory ChainTransactionData.fromJson(Map<String, dynamic> json) {
    return ChainTransactionData(
      chainIndex: json['chainIndex'] as String? ?? '',
      transactionList: (json['transactionList'] as List<dynamic>?)
              ?.map((e) =>
                  BlockchainTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cursor: json['cursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chainIndex': chainIndex,
      'transactionList': transactionList.map((e) => e.toJson()).toList(),
      'cursor': cursor,
    };
  }
}

/// API response wrapper for transaction history
class TransactionHistoryResponse {
  final String code;
  final String msg;
  final List<ChainTransactionData> data;

  TransactionHistoryResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  /// Check if API request was successful
  bool get isSuccess => code == '0';

  /// Flattens all chain transactions into a single list
  List<BlockchainTransaction> get allTransactions {
    final transactions = <BlockchainTransaction>[];
    for (final chainData in data) {
      transactions.addAll(chainData.transactionList);
    }
    return transactions;
  }

  /// Extracts cursors for pagination
  /// Returns the first non-empty cursor, or null if all are empty
  String? getCursor() {
    for (final chainData in data) {
      if (chainData.cursor != null && chainData.cursor!.isNotEmpty) {
        return chainData.cursor;
      }
    }
    return null;
  }

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      code: json['code'] as String? ?? '-1',
      msg: json['msg'] as String? ?? 'Unknown error',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ChainTransactionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
