import 'package:backend/src/models/models.dart';
import 'package:backend/src/services/services.dart';
import 'package:yaroo/http/http.dart';

class UserController extends HTTPController {
  final UserService userSvc;

  UserController(this.userSvc);

  Future<Response> currentUser() async {
    final user = request.auth as User;
    return jsonResponse({'user': user.toJson()});
  }
}
