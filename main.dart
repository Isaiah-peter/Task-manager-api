import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:task_manager/auth.dart';
import './lib/database.dart';
import './lib/tasks.dart';
import './bin/server.dart';

void main() async {
  await ConnectDB();

  final router = Router();
  final protected = Router();

  router.get('/', (Request request) {
    return Response.ok("🟢 Task Manager API is running");
  });

  router.post('/auth/signup', (Request request) async {
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    final username = data['username'] ?? '';
    final password = data['password'] ?? '';
    final email = data['email'] ?? '';
    final firstname = data['firstname'] ?? '';
    final lastname = data['lastname'] ?? '';

    final ok = await createUser(username, password, email, firstname, lastname);
    print(ok);
    return ok
        ? Response.ok("User successfully created")
        : Response(400, body: "username or password or emailing missing");
  });

  router.post('/auth/login', (Request request) async {
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    final username = data['username'] ?? '';
    final password = data['password'] ?? '';

    final token = await loginUSer(username, password);
    return token != null
        ? Response.ok("Successfully login")
        : Response(400, body: "Invalid credentials");
  });

  protected.get('/tasks', (Request request) async {
    final userId = request.context['userId'] as int;
    final task = await getTasksForUser(userId);

    return Response.ok(
      jsonEncode(task),
      headers: {"ContentType": "application/json"},
    );
  });

  protected.post('/add', (Request request) async {
    final userId = request.context['userId'] as int;
    final payload = await request.readAsString();
    final data = Uri.splitQueryString(payload);

    final desc = data['desc'] ?? 'description';
    final due = data['due'] ?? '2098-11-12';
    final priority = data['priority'] ?? 'low';

    await addTask(desc, due, priority, userId);
    return Response.ok("Task added sucessfully");
  });

  protected.put("/task/<id>/done", (Request request, String id) async {
    final userId = request.context['userId'] as int;
    await markDone(int.parse(id), userId);
    Response.ok("task successfully done");
  });

  protected.delete("/task/<id>", (Request request, String id) async {
    final userId = request.context['userId'] as int;
    await deleteTask(int.parse(id), userId);
    Response.ok("task successfully deleted $id.");
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(Cascade().add(router).add(checkjwt(protected)).handler);

  final server = await serve(handler, InternetAddress.anyIPv4, 6000);
  print("✅ Server listening on port ${server.port}");
}
