import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'gen/env.g.dart';

String generateJWT(String username) {
  final jwt = JWT({username: username}, issuer: 'taskmanage');

  return jwt.sign(SecretKey(Env.secretKey), expiresIn: Duration(days: 7));
}

String? verifyJWT(String? token) {
  if (token == null) return null;

  try {
    final jwt = JWT.verify(token, SecretKey(Env.secretKey));
    return jwt.payload['username'] as String?;
  } catch (e) {
    return null;
  }
}
