import 'package:flutter_api_services/exceptions/ServiceException.dart';

class AuthenticationException extends ServiceException {
  static final String WRONG_CREDENTIALS = 'wrong-credentials';
  static final String USER_NOT_FOUND = 'user-not-found';
  static final String TOO_MANY_REQUESTS = 'too-many-requests';
  static final String USER_ALREADY_IN_EXISTS = 'email-already-in-use';
  static final String REQUIRE_RECENTE_LOGIN = 'requires-recent-login';

  const AuthenticationException({code, message})
      : super(code: code, message: message);
}
