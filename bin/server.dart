import 'package:shelf/shelf.dart';
import '../lib/jwt_auth.dart';

Middleware checkjwt = (Handler innerHandler) {
  return (Request request) async {
    final token = request.headers['Authorization']?.replaceFirst('Bearer', '');

    final payload = verifyJWT(token);

    if (payload == null)
      return Response.forbidden("invalid token or expire token");

    return innerHandler(
      request.change(
        context: {'userId': payload['userId'], 'username': payload['username']},
      ),
    );
  };
};
