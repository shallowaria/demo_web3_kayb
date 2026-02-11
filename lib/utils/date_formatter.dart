import 'package:intl/intl.dart';
import 'package:web3_demo/data/models/blockchain_transaction.dart';

/// Utility class for date operations on transactions
class DateFormatter {
  /// Date format: YYYY/MM/DD
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');

  /// Formats a DateTime to YYYY/MM/DD string
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Groups transactions by date (YYYY/MM/DD), sorted descending (newest first)
  /// Returns a Map where keys are date strings and values are lists of transactions
  static Map<String, List<BlockchainTransaction>> groupByDate(
    List<BlockchainTransaction> transactions,
  ) {
    final grouped = <String, List<BlockchainTransaction>>{};

    for (final transaction in transactions) {
      final dateKey = formatDate(transaction.dateTime);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    // Sort by date descending (newest first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  /// Checks if a DateTime is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}
