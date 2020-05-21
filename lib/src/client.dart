// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'queries.dart';
import 'package:graphql/client.dart';

const int DEFAULT_MIN_TIME_TO_LIVE = 30 * 1000; // 30 seconds

class KryptonClient {
  _KryptonState _state;
  String _endpoint;
  int _minTimeToLive;

  /// Public API
////////////////////////////////////////////////
  KryptonClient(String endpoint, {minTimeToLive = DEFAULT_MIN_TIME_TO_LIVE}) {
    _endpoint = endpoint;
    _state = new _KryptonState();
  }

  /// For information purpose, we alow the consumer of this library to get the value of endpoint he used to construct this class
  dynamic get endpoint {
    return this._endpoint;
  }

  DateTime get expiryDate => _state.expiryDate;

  Map<String, dynamic> get user => _state.user;

  Future<String> getToken() async {
    var limit = DateTime.now().add(new Duration(milliseconds: _minTimeToLive));
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

  Future<void> login(String email, String password) async {
    Map<String, dynamic> _variables = {'email': email, 'password': password};
    GraphQLClient _graphQLClient = _instanciateGraphQLClient();
    QueryResult result =
        await query(QueryEnum.login, _variables, _graphQLClient);
    if (result.data != null) {
      if (result.data['login'] != null) {
        _updateState(result.data['login']);
      } else if (result.data['refreshToken'] != null) {
        _updateState(result.data['refreshToken']);
      } else if (result.data['updateMe'] != null) {
        _updateState(result.data['updateMe']);
      }
    }
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

  void _updateState(Map<String, dynamic> dataItemContent) {
    if (dataItemContent != null) {
      _state = new _KryptonState(
          token: dataItemContent['token'],
          expiryDate: DateTime.parse(dataItemContent['expiryDate']),
          user: decodeToken(dataItemContent['token']));
    }
  }
}

class _KryptonState {
  String token;
  DateTime expiryDate;
  Map<String, dynamic> user;

  _KryptonState({token = '', expiryDate, user})
      : expiryDate = expiryDate ?? new DateTime.fromMicrosecondsSinceEpoch(0),
        user = user ?? new Map();
}
