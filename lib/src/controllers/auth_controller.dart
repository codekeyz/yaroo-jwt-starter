import 'dart:io';

import 'package:yaroo/http/http.dart';
import 'package:yaroo/http/meta.dart';
import 'package:bcrypt/bcrypt.dart';

import '../models/dto/dto.dart';
import '../services/services.dart';

class AuthController extends HTTPController {
  final AuthService _authService;
  final UserService _userService;

  AuthController(this._authService, this._userService);

  Future<Response> login(@body LoginUserDTO data) async {
    final user = await _userService.findUserByEmail(data.email);
    if (user == null) return invalidLogin;

    final match = BCrypt.checkpw(data.password, user.password);
    if (!match) return invalidLogin;

    final token = _authService.getAccessTokenForUser(user);
    return response.json({'token': token});
  }

  Future<Response> register(@body CreateUserDTO data) async {
    final user = await _userService.findUserByEmail(data.email);
    if (user != null) {
      return response.json(
        _makeError(['Email already taken']),
        statusCode: HttpStatus.badRequest,
      );
    }

    final hashedPass = BCrypt.hashpw(data.password, BCrypt.gensalt());
    await _userService.newUser(data.name, data.email, hashedPass, data.age);

    return response.ok();
  }

  Response get invalidLogin => response.unauthorized(
        data: _makeError(['Email or Password not valid']),
      );

  Map<String, dynamic> _makeError(List<String> errors) => {'errors': errors};
}
