// Copyright (c) 2020, the Krypton project authors.
// For full authorship information, refer to the version control history at
// https://github.com/krypton-org/krypton-flutter or visit the AUTHORS file.
// All rights reserved. Use of this source code is governed by the
// MIT license that can be found in the LICENSE file.

// enum QueryEnum { register, login, delete, refresh, logout }

// // Requires dart >= 2.6.0
// extension QueryExtension on QueryEnum {
//   String get value {
//     switch (this) {
//       case QueryEnum.register:
//         return _register;
//       case QueryEnum.login:
//         return _login;
//       case QueryEnum.delete:
//         return _delete;
//       case QueryEnum.refresh:
//         return _refresh;
//       case QueryEnum.logout:
//         return _logout;
//       default:
//         return null;
//     }
//   }
// }

// const String _register = r'''
//   mutation register($fields: UserRegisterInput!) {
//     register(fields: $fields)
//   }
// ''';

// const String _login = r'''
// mutation login($email: String!, $password: String!) {
//   login(email: $email, password: $password) {
//     token
//     expiryDate
//   }
// }
// ''';

// const String _logout = r'''
// mutation{
//   logout
// }
// ''';

// const String _delete = r'''
//   mutation deleteMe($password: String!) {
//     deleteMe(password: $password)
//   }
// ''';

// const String _refresh = r'''
//   mutation { refreshToken { token, expiryDate } }
// ''';

abstract class Query {
  Map<String, dynamic> _variables;

  Query(this._variables);

  Map<String, dynamic> toJson() => {
        'query': _getQuery(),
        'variables': _variables,
      };

  String _getQuery();
}

abstract class QueryWithRequestedFields extends Query {
  List<String> _requestedFields;

  QueryWithRequestedFields(variables, this._requestedFields) : super(variables);

  String _getRequestedFieldsFragment() => '''
            fragment requestedFields on UserPublicInfo {
                ${_requestedFields.join(" ")}
            }
        ''';
  Map<String, dynamic> toJson() => {
        'query': _getQuery() + ' ' + _getRequestedFieldsFragment(),
        'variables': _variables,
      };
}

class RefreshQuery extends Query {
  RefreshQuery() : super({});
  @override
  String _getQuery() => '''
        mutation { refreshToken { token, expiryDate } }
    ''';
}

class RegisterQuery extends Query {
  RegisterQuery(variables) : super(variables);

  String _getQuery() => r'''
        mutation register($fields: UserRegisterInput!) {
            register(fields: $fields)
        }
    ''';
}

class LoginQuery extends Query {
  LoginQuery(variables) : super(variables);

  String _getQuery() => r'''
        mutation login($email: String!, $password: String!) {
            login(email: $email, password: $password) {
                token
                expiryDate
            }
        }
    ''';
}

class LogoutQuery extends Query {
  LogoutQuery() : super({});

  String _getQuery() => r'''
        mutation{
          logout
        }
    ''';
}

class UpdateQuery extends Query {
  UpdateQuery(variables) : super(variables);

  String _getQuery() => r'''
        mutation updateMe($fields: UserUpdateInput!) {
            updateMe(fields: $fields) {
                token
                expiryDate
            }
        }
    ''';
}

class DeleteQuery extends Query {
  DeleteQuery(variables) : super(variables);

  String _getQuery() => r'''
        mutation deleteMe($password: String!) {
            deleteMe(password: $password)
        }
    ''';
}

class EmailAvailableQuery extends Query {
  EmailAvailableQuery(variables) : super(variables);

  String _getQuery() => r'''
        query emailAvailable($email: String!) {
            emailAvailable(email: $email)
        }
    ''';
}

class SendVerificationEmailQuery extends Query {
  SendVerificationEmailQuery() : super({});

  String _getQuery() => r'''
        query {
            sendVerificationEmail
        }
    ''';
}

class PublicKeyQuery extends Query {
  PublicKeyQuery() : super({});

  String _getQuery() => r'''
        query {
            publicKey
        }
    ''';
}

class SendPasswordRecoveryQuery extends Query {
  SendPasswordRecoveryQuery(variables) : super(variables);

  String _getQuery() => r'''
        query sendPasswordRecoveryEmail($email: String!) {
            sendPasswordRecoveryEmail(email: $email)
        }
    ''';
}

class UserOneQuery extends QueryWithRequestedFields {
  UserOneQuery(variables, requestedFields) : super(variables, requestedFields);

  String _getQuery() => r'''
        query userOne($filter: FilterFindOneUserPublicInfoInput!) {
            userOne(filter: $filter){
                ...requestedFields
            }
        }  
    ''';
}

class UserByIdsQuery extends QueryWithRequestedFields {
  UserByIdsQuery(variables, requestedFields)
      : super(variables, requestedFields);

  String _getQuery() => r'''
        query userByIds($ids: [MongoID]!) {
            userByIds(_ids: $ids){
                ...requestedFields
            }
        }
    ''';
}

class UserManyQuery extends QueryWithRequestedFields {
  UserManyQuery(variables, requestedFields) : super(variables, requestedFields);

  String _getQuery() => r'''
        query userMany($filter: FilterFindManyUserPublicInfoInput!, $limit: Int) {
            userMany(filter: $filter, limit: $limit){
                ...requestedFields
            }
        }
    ''';
}

class UserCountQuery extends Query {
  UserCountQuery(variables) : super(variables);

  String _getQuery() {
    if (_variables['filter'] != null) {
      return r'''
                query userCount($filter: FilterUserPublicInfoInput!) {
                    userCount(filter: $filter)
                }
            ''';
    } else {
      return r'''
                query {
                    userCount
                }
            ''';
    }
  }
}

class UserPaginationQuery extends QueryWithRequestedFields {
  UserPaginationQuery(variables, requestedFields)
      : super(variables, requestedFields);

  String _getQuery() => r'''
        query userPagination($filter: FilterFindManyUserPublicInfoInput!, $page: Int!, $perPage: Int!) {
            userPagination(filter: $filter, page: $page, perPage: $perPage){
                ...requestedFields
            }
        }
    ''';

  @override
  String _getRequestedFieldsFragment() => '''
            fragment requestedFields on UserPublicInfoPagination {
                items{
                    ${_requestedFields.join(" ")}
                }
                pageInfo{
                    currentPage
                    perPage
                    pageCount
                    itemCount
                    hasNextPage
                    hasPreviousPage
                }
            }
        ''';
}
