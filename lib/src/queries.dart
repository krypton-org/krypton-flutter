// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:graphql/client.dart';

dynamic decodeToken(String token) {
  if (token == null) {
    //TODO: throw unexpected parse exception: user token is null, cannot decode it
    return null;
  }
  final parts = token.split('.');
  if (parts.length != 3) {
    //TODO: throw unexpected parse exception: user token is not in the right format: cannot decode it. Are you sure you are connected to Krypton Auth?
    return null;
  }
  final payload = parts[1];
  var normalized = base64Url.normalize(payload);
  var resp = utf8.decode(base64Url.decode(normalized));
  return json.decode(resp);
}

Future<QueryResult> query(QueryEnum queryEnum, Map<String, dynamic> variables,
    GraphQLClient graphQLClient) async {
  final QueryOptions _options = QueryOptions(
    documentNode: gql(queryEnum.value),
    variables: variables,
  );
  //TODO parse exception and throw standard exception and then parse specific errors throw specific exceptions
  // finally return QueryResult
  return await graphQLClient.query(_options);
}

enum QueryEnum {
  register,
  login,
  delete,
}

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

const String _delete = r'''
  mutation deleteMe($password: String!) {
    deleteMe(password: $password)
  }
''';
