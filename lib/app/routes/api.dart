import 'package:backend/src/controllers/controllers.dart';
import 'package:yaroo/yaroo.dart';

List<RouteDefinition> routes = [
  /// Users
  Route.group('users', [
    Route.get('/me', (UserController, #currentUser)),
  ]),
];
