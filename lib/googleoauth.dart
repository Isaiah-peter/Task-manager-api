import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import './gen/env.g.dart';
import 'jwt_auth.dart';
import 'auth.dart';

Router get googleRouter {
  final router = Router();

  // Step 1: Redirect to Google
  router.get('/auth/google', (Request req) {
    final uri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': Env.clientid,
      'redirect_uri': Env.redirecturi,
      'response_type': 'code',
      'scope': 'openid email profile',
      'access_type': 'online',
    });

    return Response.found(uri.toString());
  });

  // Step 2: Handle Google Callback
  router.get('/auth/google/callback', (Request req) async {
    final code = req.url.queryParameters['code'];
    if (code == null) return Response.badRequest(body: 'No code from Google');

    // Step 3: Exchange code for token
    final tokenResp = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'code': code,
        'client_id': Env.clientid,
        'client_secret': Env.clientsecret,
        'redirect_uri': Env.redirecturi,
        'grant_type': 'authorization_code',
      },
    );

    final tokenData = jsonDecode(tokenResp.body);
    final accessToken = tokenData['access_token'];

    // Step 4: Get user info
    final userResp = await http.get(
      Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final userData = jsonDecode(userResp.body);
    final email = userData['email'];
    final firstName = userData['given_name'];
    final lastName = userData['family_name'];


    // Optional: Register user in your DB if not exists
    final userId = await findOrCreateUser(
      email: email,
      firstName: firstName,
      lastName: lastName,
    );

    // Step 5: Issue your own JWT
    final jwt = generateJWT(email, userId);

    return Response.ok(
      jsonEncode({'token': jwt, 'email': email}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
