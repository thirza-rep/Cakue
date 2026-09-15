import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/mysql_connection.dart';

Router monthlySummariesRouter() {
  final router = Router();

  router.get('/', (Request req) async {
    final p = req.url.queryParameters;
    final userUuid = p['userUuid'] ?? '';
    final yearMonth = p['yearMonth'];
    try {
      final results = yearMonth != null
          ? await Db.pool.query(
              'SELECT * FROM monthly_summaries WHERE user_uuid = ? AND year_month = ?',
              [userUuid, yearMonth])
          : await Db.pool.query(
              'SELECT * FROM monthly_summaries WHERE user_uuid = ? ORDER BY year_month DESC',
              [userUuid]);
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
