import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../db/mysql_connection.dart';

const _uuid = Uuid();

Router usersRouter() {
  final router = Router();

  router.get('/active', (Request req) async {
    try {
      final r = await Db.pool.query(
        'SELECT * FROM user_profiles WHERE is_active = 1 LIMIT 1');
      if (r.rows.isEmpty) return _json(null);
      return _json(r.rows.first.assoc());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  router.get('/', (Request req) async {
    try {
      final r = await Db.pool.query(
        'SELECT * FROM user_profiles ORDER BY created_at DESC');
      return _json(r.rows.map((row) => row.assoc()).toList());
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  router.post('/', (Request req) async {
    try {
      final body = await _parseBody(req);
      final now = DateTime.now().millisecondsSinceEpoch;
      final userUuid = body['uuid'] as String? ?? _uuid.v4();
      await Db.pool.query('UPDATE user_profiles SET is_active = 0');
      await Db.pool.query('''
        INSERT INTO user_profiles (uuid, name, email, avatar_url, is_active, created_at, updated_at)
        VALUES (?, ?, ?, ?, 1, ?, ?)
        ON DUPLICATE KEY UPDATE name=VALUES(name), email=VALUES(email), is_active=1, updated_at=VALUES(updated_at)
      ''', [userUuid, body['name'] ?? 'User', body['email'], body['avatar_url'], now, now]);
      return _json({'uuid': userUuid, 'message': 'User created'}, 201);
    } catch (e) {
      return _error('Failed: $e', 500);
    }
  });

  router.put('/<uuid>/activate', (Request req, String uuid) async {
    try {
      await Db.pool.query('UPDATE user_profiles SET is_active = 0');
      await Db.pool.query(
        'UPDATE user_profiles SET is_active = 1 WHERE uuid = ?', [uuid]);
      return _json({'message': 'User activated'});
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
