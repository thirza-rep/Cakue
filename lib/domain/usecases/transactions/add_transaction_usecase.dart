import 'package:uuid/uuid.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';

/// UseCase: Menambah transaksi baru
/// Tanggungjawab:
/// - Validasi input
/// - Generate UUID
/// - Update saldo rekening
/// - Update monthly_summaries (incremental)
class AddTransactionUseCase {
  final TransactionRepository _repository;
  final _uuid = const Uuid();

  AddTransactionUseCase(this._repository);

  Future<void> execute(AddTransactionParams params) async {
    // Validasi
    if (params.amount <= 0) {
      throw ArgumentError('Jumlah transaksi harus lebih dari 0');
    }
    if (params.accountUuid.isEmpty) {
      throw ArgumentError('Pilih rekening terlebih dahulu');
    }
    if (params.type == TransactionType.transfer && params.toAccountUuid == null) {
      throw ArgumentError('Pilih rekening tujuan untuk transfer');
    }

    final now = DateTime.now();
    final tx = TransactionEntity(
      uuid: _uuid.v4(),
      userUuid: params.userUuid,
      type: params.type,
      accountUuid: params.accountUuid,
      toAccountUuid: params.toAccountUuid,
      categoryUuid: params.categoryUuid,
      amount: params.amount,
      baseAmount: params.amount / params.exchangeRate,
      exchangeRate: params.exchangeRate,
      currencyCode: params.currencyCode,
      date: params.date,
      note: params.note,
      merchant: params.merchant,
      tags: params.tags,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    await _repository.addTransaction(tx);
  }
}

class AddTransactionParams {
  final String userUuid;
  final TransactionType type;
  final String accountUuid;
  final String? toAccountUuid;
  final String? categoryUuid;
  final double amount;
  final double exchangeRate;
  final String currencyCode;
  final DateTime date;
  final String? note;
  final String? merchant;
  final List<String>? tags;

  const AddTransactionParams({
    required this.userUuid,
    required this.type,
    required this.accountUuid,
    this.toAccountUuid,
    this.categoryUuid,
    required this.amount,
    this.exchangeRate = 1.0,
    required this.currencyCode,
    required this.date,
    this.note,
    this.merchant,
    this.tags,
  });
}
