// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:graphql/client.dart';
import 'queries.dart';

class KryptonClient {
  Map<String, dynamic> _state;
  String _endpoint;

  /// Public API
////////////////////////////////////////////////
  KryptonClient(String endpoint) {
    _endpoint = endpoint;
    _state = Map();
  }

  /// For information purpose, we alow the consumer of this library to get the value of endpoint he used to construct this class
  dynamic get endpoint {
    return this._endpoint;
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
    QueryResult result =
        await _query(QueryEnum.register, _variables, _graphQLClient);
    print(result.data);
  }

  Future<void> login(String email, String password) async {
    Map<String, dynamic> _variables = {'email': email, 'password': password};
    GraphQLClient _graphQLClient = _instanciateGraphQLClient();
    QueryResult result =
        await _query(QueryEnum.login, _variables, _graphQLClient);
    if (result.data != null) {
      _updateState(result.data['login']);
    }
    print(result.data);
  }

  Future<void> delete(String password) async {
    Map<String, dynamic> _variables = {'password': password};
    GraphQLClient _graphQLClient =
        _instanciateGraphQLClient(authTokenRequired: true);
    QueryResult result =
        await _query(QueryEnum.delete, _variables, _graphQLClient);
    print(result.data);
    _state.clear();
  }
  ///////////////////////////////////////////////////

  void _updateState(Map<String, dynamic> dataItemContent) {
    if (dataItemContent != null) {
      _state['token'] = dataItemContent['token'];
      _state['expiryDate'] = dataItemContent['expiryDate'];
      _state['user'] = _decodeToken(dataItemContent['token']);
    }
  }

  dynamic _decodeToken(String token) {
    if(token == null) {
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

  GraphQLClient _instanciateGraphQLClient({bool authTokenRequired = false}) {
    Link _link = HttpLink(
      uri: endpoint,
    );
    if (authTokenRequired) {
      final AuthLink _authLink = AuthLink(
        getToken: () async => "Bearer ${_state['token']}",
      );
      _link = _authLink.concat(_link);
    }
    return GraphQLClient(
      cache: InMemoryCache(),
      link: _link,
    );
  }

  Future<QueryResult> _query(QueryEnum queryEnum,
      Map<String, dynamic> variables, GraphQLClient graphQLClient) async {
    final QueryOptions _options = QueryOptions(
      documentNode: gql(queryEnum.value),
      variables: variables,
    );
    //TODO parse exception and throw standard exception and then parse specific errors throw specific exceptions
    // finally return QueryResult
    return await graphQLClient.query(_options);
  }
}
