import 'package:postgres/postgres.dart';

import './gen/env.g.dart';

late final Connection conn;
Future<void> ConnectDB() async {
  final endpoint = Endpoint(
    host: Env.dbHost,
    port: Env.dbPort,
    database: Env.dbName,
    username: Env.dbUser,
    password: Env.dbPassword,
  );

  conn = await Connection.open(
    endpoint,
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );
}

Future<void> closeDB() async {
  if (conn.isOpen) {
    await conn.close();
  }
}



