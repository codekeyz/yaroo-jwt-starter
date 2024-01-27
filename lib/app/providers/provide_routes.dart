import 'dart:async';

import 'package:backend/backend.dart';
import 'package:yaroo/http/http.dart';
import 'package:yaroo/yaroo.dart';

import '../routes/api.dart' as api;
import '../routes/web.dart' as web;

class RouteProvider extends ServiceProvider {
  @override
  FutureOr<void> boot() {
    app.useRoutes(
      () => [
        /*|--------------------------------------------------------------------------
          | API Routes
          |--------------------------------------------------------------------------*/
        Route.group('api', [
          Route.post('/auth/login', (AuthController, #login)),
          Route.post('/auth/register', (AuthController, #register)),
        ]),
        Route.middleware('api:auth').group('api', api.routes),

        /*|--------------------------------------------------------------------------
          | Web Routes
          |--------------------------------------------------------------------------*/
        Route.middleware('web').group('/', web.routes),
      ],
    );
  }
}
