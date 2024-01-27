import 'package:yaroo/foundation/validation.dart';

class CreateUserDTO extends BaseDTO {
  @ezMinLength(3)
  String get name;

  @ezEmail()
  String get email;

  int get age;

  @ezMinLength(8)
  String get password;
}

class LoginUserDTO extends BaseDTO {
  @ezEmail()
  String get email;

  String get password;
}
