import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../db/mysql_connection.dart';

const _uuid = Uuid();

Router transactionsRouter() {
  final router = Router();

  // GET /api/transactions?userUuid=&limit=&accountUuid=&type=&beforeTimestamp=
  router.get('/', (Request req) async {
    final p = req.url.queryParameters;
    final userUuid = p['userUuid'] ?? '';
    final limit = int.tryParse(p['limit'] ?? '30') ?? 30;
    try {
      var sql = 'SELECT * FROM transactions WHERE user_uuid = ? AND deleted_at IS NULL';
      final args = <dynamic>[userUuid];
      if (p['accountUuid'] != null) {
        sql += ' AND (account_uuid = ? OR to_account_uuid = ?)';
        args.addAll([p['accountUuid'], p['accountUuid']]);
      }
      if (p['type'] != null) { sql += ' AND type = ?'; args.add(p['type']); }
      if (p['beforeTimestamp'] != null) {
        sql += ' AND date < ?';
        args.add(int.parse(p['beforeTimestamp']!));
      }
      sql += ' ORDER BY date DESC LIMIT ?';
      args.add(limit);
      final results = await Db.pool.query(sql, args);
      return _json(results.rows.map((r) => r.assoc()).toList());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // GET /api/transactions/recent?userUuid=&limit=
  router.get('/recent', (Request req) async {
    final p = req.url.queryParameters;
    final userUuid = p['userUuid'] ?? '';
    final limit = int.tryParse(p['limit'] ?? '20') ?? 20;
    try {
      final results = await Db.pool.query(
        'SELECT * FROM transactions WHERE user_uuid = ? AND deleted_at IS NULL ORDER BY date DESC LIMIT ?',
        [userUuid, limit]);
      return _json(results.rows.map((r) => r.assoc()).toList());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // GET /api/transactions/month-totals?userUuid=&yearMonth=YYYY-MM
  router.get('/month-totals', (Request req) async {
    final p = req.url.queryParameters;
    final userUuid = p['userUuid'] ?? '';
    final yearMonth = p['yearMonth'] ?? '';
    try {
      final parts = yearMonth.split('-');
      if (parts.length != 2) return _error('Invalid yearMonth', 400);
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final startMs = DateTime(year, month).millisecondsSinceEpoch;
      final nextMonth = month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);
      final endMs = nextMonth.millisecondsSinceEpoch - 1;

      final baseSql = 'SELECT COALESCE(SUM(base_amount),0) as t FROM transactions '
          'WHERE user_uuid = ? AND type = ? AND date >= ? AND date <= ? AND deleted_at IS NULL';
      final inc = await Db.pool.query(baseSql, [userUuid, 'income', startMs, endMs]);
      final exp = await Db.pool.query(baseSql, [userUuid, 'expense', startMs, endMs]);

      return _json({
        'income': double.tryParse(inc.rows.first.assoc()['t'] ?? '0') ?? 0.0,
        'expense': double.tryParse(exp.rows.first.assoc()['t'] ?? '0') ?? 0.0,
      });
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // GET /api/transactions/date-range?userUuid=&startMs=&endMs=&accountUuid=
  router.get('/date-range', (Request req) async {
    final p = req.url.queryParameters;
    final userUuid = p['userUuid'] ?? '';
    final startMs = int.tryParse(p['startMs'] ?? '') ?? 0;
    final endMs = int.tryParse(p['endMs'] ?? '') ?? DateTime.now().millisecondsSinceEpoch;
    try {
      var sql = 'SELECT * FROM transactions WHERE user_uuid = ? AND deleted_at IS NULL AND date >= ? AND date <= ?';
      final args = <dynamic>[userUuid, startMs, endMs];
      if (p['accountUuid'] != null) {
        sql += ' AND (account_uuid = ? OR to_account_uuid = ?)';
        args.addAll([p['accountUuid'], p['accountUuid']]);
      }
      sql += ' ORDER BY date DESC';
      final results = await Db.pool.query(sql, args);
      return _json(results.rows.map((r) => r.assoc()).toList());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // GET /api/transactions/:uuid
  router.get('/<uuid>', (Request req, String uuid) async {
    try {
      final r = await Db.pool.query(
        'SELECT * FROM transactions WHERE uuid = ? AND deleted_at IS NULL', [uuid]);
      if (r.rows.isEmpty) return _error('Not found', 404);
      return _json(r.rows.first.assoc());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // POST /api/transactions
  router.post('/', (Request req) async {
    try {
      final body = await _parseBody(req);
      final now = DateTime.now().millisecondsSinceEpoch;
      final txUuid = body['uuid'] as String? ?? _uuid.v4();
      final userUuid = body['user_uuid'] as String;

      await Db.pool.query('''
        INSERT INTO transactions (uuid, user_uuid, type, account_uuid, to_account_uuid,
          category_uuid, amount, base_amount, exchange_rate, currency_code, date,
          note, merchant, is_recurring, created_at, updated_at, sync_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'synced')
      ''', [
        txUuid, userUuid, body['type'],
        body['account_uuid'], body['to_account_uuid'], body['category_uuid'],
        (body['amount'] as num).toDouble(),
        (body['base_amount'] as num? ?? body['amount'] as num).toDouble(),
        (body['exchange_rate'] as num?)?.toDouble() ?? 1.0,
        body['currency_code'] ?? 'IDR',
        body['date'] ?? now,
        body['note'], body['merchant'],
        body['is_recurring'] == true ? 1 : 0,
        now, now,
      ]);

      await _recalculateBalances(userUuid);
      return _json({'uuid': txUuid, 'message': 'Transaction created'}, 201);
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // PUT /api/transactions/:uuid
  router.put('/<uuid>', (Request req, String uuid) async {
    try {
      final body = await _parseBody(req);
      final now = DateTime.now().millisecondsSinceEpoch;
      final userUuid = body['user_uuid'] as String;

      await Db.pool.query('''
        UPDATE transactions SET amount = ?, base_amount = ?,
          note = ?, merchant = ?, category_uuid = ?, updated_at = ?, sync_status = 'synced'
        WHERE uuid = ?
      ''', [
        (body['amount'] as num).toDouble(),
        (body['base_amount'] as num? ?? body['amount'] as num).toDouble(),
        body['note'], body['merchant'], body['category_uuid'], now, uuid,
      ]);

      await _recalculateBalances(userUuid);
      return _json({'message': 'Transaction updated'});
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  // DELETE /api/transactions/:uuid
  router.delete('/<uuid>', (Request req, String uuid) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final tx = await Db.pool.query(
        'SELECT user_uuid FROM transactions WHERE uuid = ?', [uuid]);
      if (tx.rows.isEmpty) return _error('Not found', 404);
      final userUuid = tx.rows.first.assoc()['user_uuid']!;

      await Db.pool.query(
        "UPDATE transactions SET deleted_at = ?, updated_at = ?, sync_status = 'synced' WHERE uuid = ?",
        [now, now, uuid]);

      await _recalculateBalances(userUuid);
      return _json({'message': 'Transaction deleted'});
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  return router;
}

Future<void> _recalculateBalances(String userUuid) async {
  final txResults = await Db.pool.query(
    'SELECT account_uuid, to_account_uuid, type, amount FROM transactions WHERE user_uuid = ? AND deleted_at IS NULL',
    [userUuid]);

  final Map<String, double> deltas = {};
  for (final row in txResults.rows) {
    final r = row.assoc();
    final acc = r['account_uuid']!;
    final toAcc = r['to_account_uuid'];
    final type = r['type']!;
    final amount = double.tryParse(r['amount'] ?? '0') ?? 0.0;

    deltas.putIfAbsent(acc, () => 0.0);
    if (type == 'income') {
      deltas[acc] = deltas[acc]! + amount;
    } else if (type == 'expense') {
      deltas[acc] = deltas[acc]! - amount;
    } else if (type == 'transfer') {
      deltas[acc] = deltas[acc]! - amount;
      if (toAcc != null && toAcc.isNotEmpty) {
        deltas.putIfAbsent(toAcc, () => 0.0);
        deltas[toAcc] = deltas[toAcc]! + amount;
      }
    }
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  for (final entry in deltas.entries) {
    final accResult = await Db.pool.query(
      'SELECT initial_balance FROM accounts WHERE uuid = ?', [entry.key]);
    if (accResult.rows.isEmpty) continue;
    final initial = double.tryParse(
      accResult.rows.first.assoc()['initial_balance'] ?? '0') ?? 0.0;
    await Db.pool.query(
      'UPDATE accounts SET current_balance = ?, updated_at = ? WHERE uuid = ?',
      [initial + entry.value, now, entry.key]);
  }
}

Response _json(dynamic data, [int status = 200]) => Response(
    status, body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
Response _error(String msg, int status) => Response(
    status, body: jsonEncode({'error': msg}), headers: {'Content-Type': 'application/json'});
Future<Map<String, dynamic>> _parseBody(Request req) async =>
    jsonDecode(await req.readAsString()) as Map<String, dynamic>;
