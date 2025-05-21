import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import './lib/database.dart';

void main() async {
  await ConnectDB();

  final router = Router();

  router.get('/', (Request request) {
    return Response.ok("🟢 Task Manager API is running");
  });

  router.get('/list', (Request request) async {
    final task = await getTasks();

    return Response.ok(
      task.toString(),
      headers: {"ContentType": "application/json"},
    );
  });

  router.post('/add', (Request request) async {
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    final desc = data['desc'] ?? 'description';
    final due = data['due'] ?? '2098-11-12';
    final priority = data['priority'] ?? 'low';

    await addTask(desc, due, priority);
    return Response.ok("Task added sucessfully");
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, 6000);
  print("✅ Server listening on port ${server.port}");
}
