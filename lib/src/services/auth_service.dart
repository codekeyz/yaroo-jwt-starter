import 'dart:io';

import 'package:backend/src/models/models.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:yaroo/http/http.dart';

class AuthService {
  final String jwtKey;
  final String issuer;

  const AuthService(this.jwtKey, this.issuer);

  JWTKey get _jwtKey => SecretKey(jwtKey);

  String getAccessTokenForUser(User user) {
    final userData = user.toJson();
    final jwt = JWT(userData,
        issuer: issuer, subject: user.id!.toString(), jwtId: 'access-token');

    return jwt.sign(
      _jwtKey,
      algorithm: JWTAlgorithm.HS256,
      expiresIn: Duration(hours: 1),
    );
  }

  /// this resolves the token from either signed cookies or
  /// request headers and returns the User ID
  int? validateRequest(Request request) {
    String? authToken;
    if (request.headers.containsKey(HttpHeaders.authorizationHeader)) {
      authToken =
          (request.headers[HttpHeaders.authorizationHeader] as Iterable<String>)
              .first
              .split(' ')
              .last;
    }

    if (authToken == null) return null;

    try {
      final jwt = JWT.verify(authToken, _jwtKey);
      if (jwt.jwtId != 'access-token') return null;
      return int.tryParse('${jwt.subject}');
    } catch (e) {
      return null;
    }
  }
}
