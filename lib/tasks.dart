import 'package:postgres/postgres.dart';
import 'database.dart';



Future<void> addTask(String desc, String due, String priority, int userId) async {
  await ConnectDB();
  await conn.execute(
    Sql.named(
      'INSERT INTO tasks (description, due, priority, status, user_id) VALUES (@desc, @due, @priority, @status, @userId)',
    ),
    parameters: {
      'desc': desc,
      'due': due,
      'priority': priority,
      'status': 'Pending',
      'userId': userId
    },
  );
}

Future<List<Map<String, dynamic>>> getTasksForUser(int uid) async {
  await ConnectDB();
  final result = await conn.execute(
    Sql.named('SELECT * FROM tasks Where user_id = @uid ORDER BY id'),
    parameters: {uid: uid}
  );
  return result
      .map(
        (row) => {
          'id': row[0],
          'description': row[1],
          'due': row[2].toString().split(' ')[0],
          'priority': row[3],
          'status': row[4],
        },
      )
      .toList();
}

Future<void> markDone(int id, int uid) async {
  await ConnectDB();
  await conn.execute(
    Sql.named('UPDATE tasks SET status = \'Done\' WHERE id = @id AND user_id = @uid'),
    parameters: {'id': id, "uid": uid},
  );
}

Future<void> deleteTask(int id, int uid) async {
  await ConnectDB();
  await conn.execute(
    Sql.named('DELETE FROM tasks WHERE id = @id AND user_id = @uid'), 
    parameters: {'id': id, 'uid': uid},
  );
}
