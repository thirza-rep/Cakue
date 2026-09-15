import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

@freezed
abstract class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String uuid,
    required String userUuid,
    required TransactionType type,
    required String accountUuid,
    String? toAccountUuid,
    String? categoryUuid,
    required double amount,
    required double baseAmount,
    required double exchangeRate,
    required String currencyCode,
    required DateTime date,
    String? note,
    String? merchant,
    String? receiptImagePath,
    List<String>? tags,
    @Default(false) bool isRecurring,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @Default('pending') String syncStatus,
  }) = _TransactionEntity;
}

enum TransactionType {
  income,
  expense,
  transfer;

  String get label {
    switch (this) {
      case TransactionType.income: return 'Pemasukan';
      case TransactionType.expense: return 'Pengeluaran';
      case TransactionType.transfer: return 'Transfer';
    }
  }

  String get value {
    switch (this) {
      case TransactionType.income: return 'income';
      case TransactionType.expense: return 'expense';
      case TransactionType.transfer: return 'transfer';
    }
  }

  static TransactionType fromString(String s) {
    switch (s) {
      case 'income': return TransactionType.income;
      case 'expense': return TransactionType.expense;
      case 'transfer': return TransactionType.transfer;
      default: return TransactionType.expense;
    }
  }
}
