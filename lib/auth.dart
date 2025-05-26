import 'package:postgres/postgres.dart';
import 'database.dart';
import 'jwt_auth.dart';

Future<bool> createUser(String username, String password) async {
  try {
    await conn.execute(
      Sql.named("INSERT INTO users (username, password) VALUE (@u, @p)"),
      parameters: {'u': username, 'p': password},
    );
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> loginUSer(String username, String password) async {
  try {
    final result = await conn.execute(
      Sql.named(
        "SELECT * FROM users WHERE users.username = @u AND users.password = @p",
      ),
      parameters: {'u': username, 'p': password},
    );

    if (result.isNotEmpty) {
      final userid = result.first[0] as int;
      return generateJWT(username, userid);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
