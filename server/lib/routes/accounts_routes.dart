import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../db/mysql_connection.dart';

const _uuid = Uuid();

Router accountsRouter() {
  final router = Router();

  // GET /api/accounts
  router.get('/', (Request req) async {
    try {
      final results = await Db.pool.query(
        'SELECT * FROM accounts WHERE deleted_at IS NULL AND is_active = 1 ORDER BY created_at ASC',
      );
      return _json(results.rows.map((r) => r.assoc()).toList());
    } catch (e) {
      return _error('Failed to fetch accounts: $e', 500);
    }
  });

  // GET /api/accounts/:uuid
  router.get('/<uuid>', (Request req, String uuid) async {
    try {
      final results = await Db.pool.query(
        'SELECT * FROM accounts WHERE uuid = ?', [uuid]);
      if (results.rows.isEmpty) return _error('Not found', 404);
      return _json(results.rows.first.assoc());
    } catch (e) {
      return _error('Failed to fetch account: $e', 500);
    }
  });

  // POST /api/accounts
  router.post('/', (Request req) async {
    try {
      final body = await _parseBody(req);
      final now = DateTime.now().millisecondsSinceEpoch;
      final accountUuid = body['uuid'] as String? ?? _uuid.v4();
      final initialBalance = (body['initial_balance'] as num?)?.toDouble() ?? 0.0;

      await Db.pool.query('''
        INSERT INTO accounts (uuid, user_uuid, name, type, currency_code,
          initial_balance, current_balance, color, icon, is_active,
          created_at, updated_at, sync_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, 'synced')
        ON DUPLICATE KEY UPDATE name=VALUES(name), updated_at=VALUES(updated_at)
      ''', [
        accountUuid, body['user_uuid'] ?? '', body['name'] ?? '',
        body['type'] ?? 'bank', body['currency_code'] ?? 'IDR',
        initialBalance, initialBalance,
        body['color'], body['icon'], now, now,
      ]);

      return _json({'uuid': accountUuid, 'message': 'Account created'}, 201);
    } catch (e) {
      return _error('Failed to create account: $e', 500);
    }
  });

  // PUT /api/accounts/:uuid/balance
  router.put('/<uuid>/balance', (Request req, String uuid) async {
    try {
      final body = await _parseBody(req);
      final balance = (body['balance'] as num).toDouble();
      final now = DateTime.now().millisecondsSinceEpoch;
      await Db.pool.query(
        'UPDATE accounts SET current_balance = ?, updated_at = ? WHERE uuid = ?',
        [balance, now, uuid]);
      return _json({'message': 'Balance updated'});
    } catch (e) {
      return _error('Failed to update balance: $e', 500);
    }
  });

  // DELETE /api/accounts/:uuid (soft delete)
  router.delete('/<uuid>', (Request req, String uuid) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await Db.pool.query(
        'UPDATE accounts SET deleted_at = ?, updated_at = ?, is_active = 0 WHERE uuid = ?',
        [now, now, uuid]);
      return _json({'message': 'Account deleted'});
    } catch (e) {
      return _error('Failed to delete account: $e', 500);
    }
  });

  return router;
}

Response _json(dynamic data, [int status = 200]) => Response(
    status, body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

Response _error(String msg, int status) => Response(
    status, body: jsonEncode({'error': msg}), headers: {'Content-Type': 'application/json'});

Future<Map<String, dynamic>> _parseBody(Request req) async =>
    jsonDecode(await req.readAsString()) as Map<String, dynamic>;
