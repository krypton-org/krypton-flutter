// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'package:krypton/src/exceptions.dart';
import 'dart:convert';
import 'queries.dart';
import 'package:graphql/client.dart';

const int DEFAULT_MIN_TIME_TO_LIVE = 30 * 1000; // 30 seconds

class KryptonClient {
  _KryptonState _state;
  String endpoint;
  int minTimeToLive;

  /// Public API
  ////////////////////////////////////////////////
  KryptonClient(this.endpoint,
      {this.minTimeToLive = DEFAULT_MIN_TIME_TO_LIVE}) {
    _state = new _KryptonState();
  }

  DateTime get expiryDate => _state.expiryDate;

  Map<String, dynamic> get user => _state.user;

  Future<String> getToken() async {
    var limit = DateTime.now().add(new Duration(milliseconds: minTimeToLive));
    if (_state.token != '' && _state.expiryDate.isBefore(limit)) {
      await this.refreshToken();
    }
    return _state.token;
  }

  Future<String> getAuthorizationHeader() async {
    return 'Bearer ' + await this.getToken();
  }

  Future<void> refreshToken() async {
    GraphQLClient _graphQLClient = _instanciateGraphQLClient();
    await query(QueryEnum.refresh, null, _graphQLClient);
  }

  Future<bool> isLoggedIn() async {
    var now = DateTime.now();
    if (_state.token != '' && _state.expiryDate.isAfter(now)) {
      return true;
    } else {
      try {
        await this.refreshToken();
      } catch (err) {
        return false;
      }
      return true;
    }
  }

  Future<void> register(String email, String password,
      [Map<String, dynamic> newFields]) async {
    Map<String, dynamic> _variables = {
      'fields': {'email': email, 'password': password}
    };
    if (newFields != null) {
      _variables['fields'].addAll(newFields);
    }
    GraphQLClient _graphQLClient = _instanciateGraphQLClient();
    await query(QueryEnum.register, _variables, _graphQLClient);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    Map<String, dynamic> _variables = {'email': email, 'password': password};
    GraphQLClient _graphQLClient = _instanciateGraphQLClient();
    await query(QueryEnum.login, _variables, _graphQLClient);
    return _state.user;
  }

  Future<Map<String, dynamic>> logout() async {
    GraphQLClient _graphQLClient =
        _instanciateGraphQLClient(authTokenRequired: true);
    await query(QueryEnum.logout, {}, _graphQLClient);
    return _state.user;
  }

  Future<void> delete(String password) async {
    Map<String, dynamic> _variables = {'password': password};
    GraphQLClient _graphQLClient =
        _instanciateGraphQLClient(authTokenRequired: true);
    await query(QueryEnum.delete, _variables, _graphQLClient);
    _state = new _KryptonState();
  }

  ///////////////////////////////////////////////////

  GraphQLClient _instanciateGraphQLClient({bool authTokenRequired = false}) {
    Link _link = HttpLink(
      uri: endpoint,
    );
    if (authTokenRequired) {
      final AuthLink _authLink = AuthLink(
        getToken: getAuthorizationHeader,
      );
      _link = _authLink.concat(_link);
    }
    return GraphQLClient(
      cache: InMemoryCache(),
      link: _link,
    );
  }

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

  Future<dynamic> query(QueryEnum queryEnum, Map<String, dynamic> variables,
      GraphQLClient graphQLClient) async {
    final QueryOptions _options = QueryOptions(
      documentNode: gql(queryEnum.value),
      variables: variables,
    );
    QueryResult result = await graphQLClient.query(_options);
    if (result.exception != null) {
      throw _convertToKryptonException(result.exception);
    }
    if (result.data != null) {
      _updateAuthData(result.data);
    }
    return result.data;
  }

  void _updateState(Map<String, dynamic> dataItemContent) {
    _state = new _KryptonState(
        token: dataItemContent['token'],
        expiryDate: DateTime.parse(dataItemContent['expiryDate']),
        user: decodeToken(dataItemContent['token']));
  }

  Exception _convertToKryptonException(OperationException exception) {
    if (exception.graphqlErrors != null &&
        exception.graphqlErrors.length > 0 &&
        exception.graphqlErrors[0].raw['type'] != null) {
      String type = exception.graphqlErrors[0].raw['type'];
      switch (type) {
        case "AlreadyLoggedInError":
          return new AlreadyLoggedInException();
        case "EmailAlreadyConfirmedError":
          return new EmailAlreadyConfirmedException();
        case "EmailAlreadyExistsError":
          return new EmailAlreadyExistsException();
        case "EmailNotSentError":
          return new EmailNotSentException();
        case "UpdatePasswordTooLateError":
          return new UpdatePasswordTooLateException();
        case "UnauthorizedError":
          return new UnauthorizedException();
        case "UserNotFoundError":
          return new UserNotFoundException();
        case "UserValidationError":
          return new UserValidationException();
        case "WrongPasswordError":
          return new WrongPasswordException();
        default:
          return new KryptonException();
      }
    } else {
      return exception;
    }
  }

  void _updateAuthData(Map<String, dynamic> data) {
    if (data['login'] != null) {
      _updateState(data['login']);
    } else if (data['refreshToken'] != null) {
      _updateState(data['refreshToken']);
    } else if (data['updateMe'] != null) {
      _updateState(data['updateMe']);
    }
  }
}

class _KryptonState {
  String token;
  DateTime expiryDate;
  Map<String, dynamic> user;

  _KryptonState({this.token = '', expiryDate, user})
      : expiryDate = expiryDate ?? new DateTime.fromMicrosecondsSinceEpoch(0),
        user = user ?? new Map();
}
