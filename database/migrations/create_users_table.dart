import 'package:yaroorm/migration.dart';

class CreateUsersTable extends Migration {
  @override
  void up(List schemas) {
    final userSchema = Schema.create('users', (table) {
      return table
        ..id()
        ..string('name')
        ..string('email')
        ..integer('age')
        ..string('password')
        ..timestamps();
    });

    schemas.add(userSchema);
  }

  @override
  void down(List schemas) {
    schemas.add(Schema.dropIfExists('users'));
  }
}
