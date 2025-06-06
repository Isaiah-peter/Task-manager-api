import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';
import 'database.dart';
import 'jwt_auth.dart';

Future<bool> createUser(
  String username,
  String password,
  String email,
  String firstname,
  String lastname,
) async {
  await ConnectDB();
  final hashpassword = BCrypt.hashpw(password, BCrypt.gensalt());
  try {
    await conn.execute(
      Sql.named(
        "INSERT INTO users (username, password, email, fistname, lastname) VALUES (@u, @p, @e, @f, @l)",
      ),
      parameters: {
        'u': username,
        'p': hashpassword,
        'e': email,
        'f': firstname,
        'l': lastname,
      },
    );
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<String?> loginUSer(String username, String password) async {
  await ConnectDB();
  try {
    final result = await conn.execute(
      Sql.named("SELECT * FROM users WHERE users.username = @u"),
      parameters: {'u': username},
    );

    if (result.isNotEmpty) {
      final userid = result.first[0] as int;
      final bool checkPassword = BCrypt.checkpw(
        password,
        result.first[2] as String,
      );
      return checkPassword ? generateJWT(username, userid) : null;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<int> findOrCreateUser({
  required String email,
  required String firstName,
  required String lastName,
}) async {
  // Check if user already exists
  final existing = await conn.execute(
    Sql.named('SELECT id FROM users WHERE email = @e'),
    parameters: {'e': email},
  );

  if (existing.isNotEmpty) return existing.first[0] as int;

  // Insert new user
  await conn.execute(
    Sql.named('''
      INSERT INTO users (username, password, email, fistname, lastname)
      VALUES (@u, @p, @e, @f, @l)
    '''),
    parameters: {
      'u': firstName,
      'p': 'oauth',  // or generate a secure placeholder
      'e': email,
      'f': firstName,
      'l': lastName,
    },
  );

  // Get new user ID
  final result = await conn.execute(
    Sql.named('SELECT id FROM users WHERE email = @e'),
    parameters: {'e': email},
  );

  return result.first[0] as int;
}

