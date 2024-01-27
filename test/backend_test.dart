import 'dart:convert';
import 'dart:io';

import 'package:backend/backend.dart';
import 'package:yaroo/yaroo.dart';
import 'package:yaroorm/yaroorm.dart';
import '../database/config.dart' as orm;

import 'backend_test.reflectable.dart';

void main() {
  initializeReflectable();

  DB.init(orm.config);

  late Spookie appTester;

  setUpAll(() async {
    await blogApp.bootstrap(listen: false);
    appTester = await blogApp.tester;
  });

  group('Backend API', () {
    const baseAPIPath = '/api';

    group('Auth', () {
      const authPath = '$baseAPIPath/auth';
      group('.register', () {
        final path = '$authPath/register';
        test('should error on invalid body', () async {
          attemptRegister(Map<String, dynamic> body, {dynamic errors}) async {
            return appTester
                .post(path, body)
                .expectStatus(HttpStatus.badRequest)
                .expectJsonBody({'location': 'body', 'errors': errors}).test();
          }

          // when empty body
          await attemptRegister({}, errors: [
            'name: The field is required',
            'email: The field is required',
            'age: The field is required',
            'password: The field is required',
          ]);

          // when only name provide
          await attemptRegister({
            'name': 'Foo'
          }, errors: [
            'email: The field is required',
            'age: The field is required',
            'password: The field is required',
          ]);

          // when invalid email
          await attemptRegister({
            'name': 'Foo',
            'email': 'bar'
          }, errors: [
            'email: The field is not a valid email address',
            'age: The field is required',
            'password: The field is required',
          ]);

          // when no password
          await attemptRegister(
            {'name': 'Foo', 'email': 'foo@bar.com'},
            errors: [
              'age: The field is required',
              'password: The field is required',
            ],
          );

          // when short password
          await attemptRegister(
            {
              'name': 'Foo',
              'email': 'foo@bar.com',
              'password': '344',
              'age': 'asdfjakld',
            },
            errors: [
              'age: The field must be a int type',
              'password: The field must be at least 8 characters long',
            ],
          );
        });

        test('should create user', () async {
          final userData = {
            'name': 'Foo User',
            'email': 'foo-${DateTime.now().millisecondsSinceEpoch}@bar.com',
            'password': 'foo-bar-mee-moo',
            'age': 34,
          };

          await appTester
              .post(path, userData)
              .expectStatus(HttpStatus.ok)
              .test();
        });

        test('should error on existing email', () async {
          final randomUser = await DB.query<User>().get();
          expect(randomUser, isA<User>());

          final data = {
            'email': randomUser!.email,
            'name': 'Foo Bar',
            'password': 'moooasdfmdf',
            'age': 24,
          };

          await appTester
              .post(path, data)
              .expectStatus(HttpStatus.badRequest)
              .expectJsonBody({
            'errors': ['Email already taken']
          }).test();
        });
      });

      group('.login', () {
        final path = '$authPath/login';

        test('should error on invalid body', () async {
          attemptLogin(Map<String, dynamic> body, {dynamic errors}) async {
            return appTester
                .post('$authPath/login', body)
                .expectStatus(HttpStatus.badRequest)
                .expectJsonBody({'location': 'body', 'errors': errors}).test();
          }

          await attemptLogin({}, errors: [
            'email: The field is required',
            'password: The field is required'
          ]);
          await attemptLogin({'email': 'foo-bar@hello.com'},
              errors: ['password: The field is required']);
          await attemptLogin(
            {'email': 'foo-bar'},
            errors: [
              'email: The field is not a valid email address',
              'password: The field is required'
            ],
          );
        });

        test('should error on in-valid credentials', () async {
          final randomUser = await DB.query<User>().get();
          expect(randomUser, isA<User>());

          final email = randomUser!.email;

          await appTester
              .post(path, {'email': email, 'password': 'wap wap wap'})
              .expectStatus(HttpStatus.unauthorized)
              .expectJsonBody({
                'errors': ['Email or Password not valid']
              })
              .test();

          await appTester
              .post(path, {'email': 'holy@bar.com', 'password': 'wap wap wap'})
              .expectStatus(HttpStatus.unauthorized)
              .expectJsonBody({
                'errors': ['Email or Password not valid']
              })
              .test();
        });

        test('should success on valid credentials', () async {
          final randomUser = await DB.query<User>().get();
          expect(randomUser, isA<User>());

          final baseTest = appTester.post(path, {
            'email': randomUser!.email,
            'password': 'foo-bar-mee-moo',
          });

          await baseTest
              .expectStatus(HttpStatus.ok)
              .expectJsonBody(contains('token'))
              .test();
        });
      });
    });

    group('User', () {
      String? authToken;
      User? currentUser;

      final usersApiPath = '$baseAPIPath/users';

      setUpAll(() async {
        currentUser = await DB.query<User>().get();
        expect(currentUser, isA<User>());

        final result = await appTester.post('$baseAPIPath/auth/login', {
          'email': currentUser!.email,
          'password': 'foo-bar-mee-moo',
        }).actual;

        authToken = jsonDecode(result.body)['token'];
        expect(authToken, isNotNull);
      });

      test('should reject if no auth header', () async {
        await appTester
            .get(usersApiPath)
            .expectStatus(HttpStatus.unauthorized)
            .expectJsonBody({'error': 'Unauthorized'}).test();
      });

      test('should return user for /users/me', () async {
        await appTester
            .token(authToken!)
            .get('$usersApiPath/me')
            .expectStatus(HttpStatus.ok)
            .expectJsonBody(isA<Map>().having(
                (p0) => User.fromJson(p0['user']), 'returns user', isA<User>()))
            .test();
      });
    });
  });
}
