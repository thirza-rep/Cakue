import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../db/mysql_connection.dart';

const _uuid = Uuid();

Router budgetsRouter() {
  final router = Router();

  router.get('/', (Request req) async {
    final userUuid = req.url.queryParameters['userUuid'] ?? '';
    try {
      final r = await Db.pool.query(
        'SELECT * FROM budgets WHERE user_uuid = ?', [userUuid]);
      return _json(r.rows.map((row) => row.assoc()).toList());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  router.post('/', (Request req) async {
    try {
      final body = await _parseBody(req);
      final now = DateTime.now().millisecondsSinceEpoch;
      final budgetUuid = body['uuid'] as String? ?? _uuid.v4();
      await Db.pool.query('''
        INSERT INTO budgets (uuid, user_uuid, category_uuid, amount, period_type, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE amount=VALUES(amount), updated_at=VALUES(updated_at)
      ''', [budgetUuid, body['user_uuid'], body['category_uuid'],
            (body['amount'] as num).toDouble(),
            body['period_type'] ?? 'monthly', now, now]);
      return _json({'uuid': budgetUuid, 'message': 'Budget saved'}, 201);
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  router.delete('/<uuid>', (Request req, String uuid) async {
    try {
      await Db.pool.query('DELETE FROM budgets WHERE uuid = ?', [uuid]);
      return _json({'message': 'Budget deleted'});
    } catch (e) {
      return _error('Failed: $e', 500);
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
