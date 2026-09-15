import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/mysql_connection.dart';

Router categoriesRouter() {
  final router = Router();
  router.get('/', (Request req) async {
    final type = req.url.queryParameters['type'];
    try {
      final results = type != null
          ? await Db.pool.query(
              'SELECT * FROM categories WHERE type = ? ORDER BY COALESCE(parent_uuid, uuid), name',
              [type])
          : await Db.pool.query(
              'SELECT * FROM categories ORDER BY COALESCE(parent_uuid, uuid), name');
      return _json(results.rows.map((r) => r.assoc()).toList());
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
