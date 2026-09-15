import 'dart:io';
import 'package:mysql_client/mysql_client.dart';

/// Singleton MySQL connection pool untuk Cakue Backend
class Db {
  static MySQLConnectionPool? _pool;

  static MySQLConnectionPool get pool {
    _pool ??= MySQLConnectionPool(
      host: _env('MYSQL_HOST', 'cakue-db'),
      port: int.parse(_env('MYSQL_PORT', '3306')),
      userName: _env('MYSQL_USER', 'cakue_user'),
      password: _env('MYSQL_PASSWORD', 'cakue_password'),
      databaseName: _env('MYSQL_DB', 'cakue_db'),
      maxConnections: 10,
    );
    return _pool!;
  }

  static String _env(String key, String fallback) =>
      Platform.environment[key] ?? fallback;
}

/// Helper: execute query dengan named params (:name syntax)
/// Converts positional [args] to named params :p0, :p1, :p2...
extension DbPoolExt on MySQLConnectionPool {
  Future<IResultSet> query(String sql, [List<dynamic> args = const []]) {
    if (args.isEmpty) {
      return execute(sql, {});
    }
    // Convert ? placeholders to :p0, :p1, ... and build map
    int idx = 0;
    final Map<String, dynamic> params = {};
    final namedSql = sql.replaceAllMapped(RegExp(r'\?'), (m) {
      final key = 'p$idx';
      params[key] = args[idx];
      idx++;
      return ':$key';
    });
    return execute(namedSql, params);
  }
}
