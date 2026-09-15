import 'package:mysql_client/mysql_client.dart';
void main() async {
  final pool = MySQLConnectionPool(
    host: '127.0.0.1', port: 3306, userName: 'cakue_user', password: 'cakue_password', databaseName: 'cakue_db', collation: 'utf8mb4_unicode_ci', maxConnections: 1
  );
  var res = await pool.execute('SELECT icon FROM categories LIMIT 1');
  for (final row in res.rows) {
    String icon = row.colAt(0)!;
    print('Code units: ${icon.codeUnits}');
  }
}
