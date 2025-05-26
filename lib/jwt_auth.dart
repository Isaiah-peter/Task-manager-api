import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'gen/env.g.dart';

String generateJWT(String username, int id) {
  final jwt = JWT({"username": username, "userId": id}, issuer: 'taskmanage');

  return jwt.sign(SecretKey(Env.secretKey), expiresIn: Duration(days: 7));
}

Map<String, dynamic>? verifyJWT(String? token) {
  if (token == null) return null;

  try {
    final jwt = JWT.verify(token, SecretKey(Env.secretKey));
    return jwt.payload;
  } catch (e) {
    return null;
  }
}
