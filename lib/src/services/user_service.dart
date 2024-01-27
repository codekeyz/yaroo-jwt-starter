import 'package:yaroorm/yaroorm.dart';
import 'package:backend/src/models/models.dart';

class UserService {
  Query<User> get _userQuery => DB.query<User>();

  Future<User> newUser(
    String name,
    String email,
    String password,
    int age,
  ) async {
    final user = User(name, email, age, password: password);
    return user.save();
  }

  Future<User?> getUser(int userId) async => _userQuery.get(userId);

  Future<User?> findUserByEmail(String email) async {
    return _userQuery.whereEqual('email', email).findOne();
  }
}
