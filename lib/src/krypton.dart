// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

import 'dart:async';
import 'package:graphql/client.dart';
import 'queries.dart';

class KryptonClient {
  var _endpoint;
  GraphQLClient _graphQLClient;

  void _init(dynamic endpoint) {
    this._endpoint = endpoint;
    this._graphQLClient = _graphQLClientFromEndpoint(endpoint);
  }

  /// Public API
////////////////////////////////////////////////
  KryptonClient.fromString(String endpoint) {
    this._init(endpoint);
  }

  KryptonClient.fromLink(Link endpoint) {
    this._init(endpoint);
  }
  // If you add more types as a constructor for endpoint here,
  // be sure to take them into account in _graphQLClientFromEndpoint.

  /// For information purpose, we alow the consumer of this library to get the value of endpoint he used to construct this class
  dynamic get endpoint {
    return this._endpoint;
  }

  Future<void> register(String email, String password,
      [Map<String, dynamic> fields]) async {
    Map<String, dynamic> _variables = {'email': email, 'password': password};
    if (fields != null) {
      _variables.addAll(fields);
    }
    QueryResult queryResult = await _query(QueryEnum.register, _variables);
  }
  ///////////////////////////////////////////////////

  GraphQLClient _graphQLClientFromEndpoint(dynamic endpoint) {
    if (endpoint is String) {
      final HttpLink _httpLink = HttpLink(
        uri: endpoint,
      );
      return GraphQLClient(
        cache: InMemoryCache(),
        link: _httpLink,
      );
    } else {
      // It is a Link
      return GraphQLClient(
        cache: InMemoryCache(),
        link: endpoint,
      );
    }
  }

  Future<QueryResult> _query(
      QueryEnum queryEnum, Map<String, dynamic> variables) async {
    final QueryOptions _options = QueryOptions(
      documentNode: gql(queryEnum.value),
      variables: variables,
    );
    return await this._graphQLClient.query(_options);
  }
}
