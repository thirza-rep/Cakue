import '../entities/transaction_entity.dart';

/// Abstract repository interface (domain layer)
/// Implementasi konkret ada di data layer
abstract class TransactionRepository {
  /// Tambah transaksi baru
  Future<void> addTransaction(TransactionEntity tx);

  /// Update transaksi
  Future<void> updateTransaction(TransactionEntity tx);

  /// Soft delete transaksi
  Future<void> deleteTransaction(String uuid);

  /// Hitung ulang saldo seluruh rekening berdasarkan histori transaksi
  Future<void> recalculateAccountBalances(String userUuid, [List<dynamic>? preloadedTxs]);

  /// Ambil list transaksi dengan pagination
  Future<List<TransactionEntity>> getTransactions({
    required String userUuid,
    String? accountUuid,
    String? categoryUuid,
    String? type,
    int? beforeTimestamp,
    int limit = 30,
  });

  /// Stream transaksi terbaru (reactive)
  Stream<List<TransactionEntity>> watchRecentTransactions({
    required String userUuid,
    int limit = 20,
  });

  /// Transaksi dalam rentang tanggal
  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required String userUuid,
    required DateTime start,
    required DateTime end,
    String? accountUuid,
  });

  /// Total berdasarkan tipe dan bulan (menggunakan monthly_summaries)
  Future<Map<String, double>> getMonthTotals({
    required String userUuid,
    required String yearMonth,
  });

  /// Stream total bulanan (reactive)
  Stream<Map<String, double>> watchMonthTotals({
    required String userUuid,
    required String yearMonth,
  });
}
