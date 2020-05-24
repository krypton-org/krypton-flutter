// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

enum QueryEnum { register, login, delete, refresh, logout }

// Requires dart >= 2.6.0
extension QueryExtension on QueryEnum {
  String get value {
    switch (this) {
      case QueryEnum.register:
        return _register;
      case QueryEnum.login:
        return _login;
      case QueryEnum.delete:
        return _delete;
      case QueryEnum.refresh:
        return _refresh;
      case QueryEnum.logout:
        return _logout;
      default:
        return null;
    }
  }
}

const String _register = r'''
  mutation register($fields: UserRegisterInput!) {
    register(fields: $fields)
  }
''';

const String _login = r'''
mutation login($email: String!, $password: String!) {
  login(email: $email, password: $password) {
    token
    expiryDate
  }
}
''';

const String _logout = r'''
mutation{
  logout
}
''';

const String _delete = r'''
  mutation deleteMe($password: String!) {
    deleteMe(password: $password)
  }
''';

const String _refresh = r'''
  mutation { refreshToken { token, expiryDate } }
''';
