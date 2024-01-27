import 'package:path/path.dart' as path;
import 'package:yaroorm/yaroorm.dart';

import './migrations/create_users_table.dart';

final config = YaroormConfig(
  'test_db',
  connections: [
    DatabaseConnection(
      'test_db',
      DatabaseDriverType.sqlite,
      database: path.absolute('database', 'db.sqlite'),
    ),
  ],
  migrations: [CreateUsersTable()],
);
