import 'dart:async';
import '../api_client.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryMysql implements TransactionRepository {
  final ApiClient _api;

  TransactionRepositoryMysql(this._api);

  // ── Convert JSON → TransactionEntity ──────────────────────────────
  TransactionEntity _fromJson(Map<String, dynamic> j) {
    return TransactionEntity(
      uuid: j['uuid'] as String,
      userUuid: j['user_uuid'] as String,
      type: TransactionType.fromString(j['type'] as String),
      accountUuid: j['account_uuid'] as String,
      toAccountUuid: j['to_account_uuid'] as String?,
      categoryUuid: j['category_uuid'] as String?,
      amount: _toDouble(j['amount']),
      baseAmount: _toDouble(j['base_amount']),
      exchangeRate: _toDouble(j['exchange_rate'] ?? 1.0),
      currencyCode: j['currency_code'] as String? ?? 'IDR',
      date: DateTime.fromMillisecondsSinceEpoch(_toInt(j['date'])),
      note: j['note'] as String?,
      merchant: j['merchant'] as String?,
      isRecurring: (j['is_recurring'] as dynamic) == 1 || j['is_recurring'] == true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(_toInt(j['created_at'])),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(_toInt(j['updated_at'])),
    );
  }

  // ── Convert TransactionEntity → JSON ──────────────────────────────
  Map<String, dynamic> _toJson(TransactionEntity tx) => {
        'uuid': tx.uuid,
        'user_uuid': tx.userUuid,
        'type': tx.type.value,
        'account_uuid': tx.accountUuid,
        'to_account_uuid': tx.toAccountUuid,
        'category_uuid': tx.categoryUuid,
        'amount': tx.amount,
        'base_amount': tx.baseAmount,
        'exchange_rate': tx.exchangeRate,
        'currency_code': tx.currencyCode,
        'date': tx.date.millisecondsSinceEpoch,
        'note': tx.note,
        'merchant': tx.merchant,
        'is_recurring': tx.isRecurring,
      };

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    await _api.post('/transactions', _toJson(tx));
    _invalidate();
  }

  @override
  Future<void> updateTransaction(TransactionEntity tx) async {
    await _api.put('/transactions/${tx.uuid}', _toJson(tx));
    _invalidate();
  }

  @override
  Future<void> deleteTransaction(String uuid) async {
    await _api.delete('/transactions/$uuid');
    _invalidate();
  }

  @override
  Future<void> recalculateAccountBalances(String userUuid, [List<dynamic>? _]) async {
    // Recalculation now happens server-side on every mutation
    // This is a no-op on client side
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    required String userUuid,
    String? accountUuid,
    String? categoryUuid,
    String? type,
    int? beforeTimestamp,
    int limit = 30,
  }) async {
    final params = <String, String>{'userUuid': userUuid, 'limit': '$limit'};
    if (accountUuid != null) params['accountUuid'] = accountUuid;
    if (type != null) params['type'] = type;
    if (beforeTimestamp != null) params['beforeTimestamp'] = '$beforeTimestamp';

    final data = await _api.get('/transactions', queryParams: params);
    return (data as List).map((j) => _fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Stream<List<TransactionEntity>> watchRecentTransactions({
    required String userUuid,
    int limit = 20,
  }) {
    return _streamController.stream.asyncMap((_) async {
      final data = await _api.get('/transactions/recent',
          queryParams: {'userUuid': userUuid, 'limit': '$limit'});
      return (data as List).map((j) => _fromJson(j as Map<String, dynamic>)).toList();
    }).distinct();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required String userUuid,
    required DateTime start,
    required DateTime end,
    String? accountUuid,
  }) async {
    final params = <String, String>{
      'userUuid': userUuid,
      'startMs': '${start.millisecondsSinceEpoch}',
      'endMs': '${end.millisecondsSinceEpoch}',
    };
    if (accountUuid != null) params['accountUuid'] = accountUuid;

    final data = await _api.get('/transactions/date-range', queryParams: params);
    return (data as List).map((j) => _fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, double>> getMonthTotals({
    required String userUuid,
    required String yearMonth,
  }) async {
    final data = await _api.get('/transactions/month-totals',
        queryParams: {'userUuid': userUuid, 'yearMonth': yearMonth});
    final map = data as Map<String, dynamic>;
    return {
      'income': _toDouble(map['income']),
      'expense': _toDouble(map['expense']),
    };
  }

  @override
  Stream<Map<String, double>> watchMonthTotals({
    required String userUuid,
    required String yearMonth,
  }) {
    return _streamController.stream.asyncMap((_) async {
      return getMonthTotals(userUuid: userUuid, yearMonth: yearMonth);
    }).distinct();
  }

  // ── Reactive polling via StreamController ─────────────────────────
  static final _streamController = StreamController<void>.broadcast();

  /// Call this after mutations to trigger reactive UI refresh
  static void _invalidate() {
    _streamController.add(null);
  }

  static void invalidate() => _invalidate();
  static Stream<void> get invalidateStream => _streamController.stream;

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse('$v') ?? 0;
  }
}
