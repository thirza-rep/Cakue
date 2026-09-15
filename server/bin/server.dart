import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../lib/routes/accounts_routes.dart';
import '../lib/routes/transactions_routes.dart';
import '../lib/routes/categories_routes.dart';
import '../lib/routes/users_routes.dart';
import '../lib/routes/monthly_summaries_routes.dart';
import '../lib/routes/budgets_routes.dart';

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8000');

  final router = Router();

  // Mount route groups
  router.mount('/api/accounts', accountsRouter().call);
  router.mount('/api/transactions', transactionsRouter().call);
  router.mount('/api/categories', categoriesRouter().call);
  router.mount('/api/users', usersRouter().call);
  router.mount('/api/monthly-summaries', monthlySummariesRouter().call);
  router.mount('/api/budgets', budgetsRouter().call);

  // Health check
  router.get('/health', (Request req) {
    return Response.ok('{"status":"ok","service":"cakue-api"}',
        headers: {'Content-Type': 'application/json'});
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        ACCESS_CONTROL_ALLOW_ORIGIN: '*',
        ACCESS_CONTROL_ALLOW_HEADERS: 'Content-Type, Authorization',
        ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, OPTIONS',
      }))
      .addHandler(router.call);

  final server = await io.serve(handler, '0.0.0.0', port);
  print('✅ Cakue API Server running at http://${server.address.host}:${server.port}');
}
